USE [GPS_PM]
GO

/****** Object:  StoredProcedure [dbo].[KR_Daily_IncentiveRedemptionDataTransfer]    Script Date: 31/07/2018 09:01:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE [dbo].[KR_Daily_IncentiveRedemptionDataTransfer] 
AS

BEGIN

	/*
	10/05/2017 PF created this sp for GPS to get the Incentive and Redemption transactions from KANTAR_DB.
	*/

	set nocount on;

	DECLARE @GPSUser NVARCHAR(50)
	DECLARE @GPSTimeStamp DATETIME
	DECLARE @MaxSeq INT
	DECLARE @CountryID UNIQUEIDENTIFIER
	DECLARE @CountryISO2A NVARCHAR(2)
	DECLARE @MaxTransactionID BIGINT
	DECLARE @CreationDate DATETIME


	BEGIN TRANSACTION



	SET @CountryISO2A = 'KR'
	SET @GPSUser = 'kantar_db_user_' + @CountryISO2A + '_TransactionDailyUpdate'
	PRINT @GPSUser
	SET @GPSTimeStamp = DateADD(dd, 1, GetDate()) --Need to add a day to GetDate as Asia are eight hours ahead and the job runs at 19:10 UK time and would return the UK server date
	SET @CreationDate = GetDate()

	SELECT @CountryID = CountryID FROM Country WHERE CountryISO2A = @CountryISO2A
	PRINT @CountryID



		if exists (	SELECT * FROM tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#tmpIncentiveTrans')) 
			BEGIN  
				DROP TABLE #tmpIncentiveTrans
			END

			CREATE TABLE #tmpIncentiveTrans
						(
					[IndividualID] [nvarchar](255) NULL,
					[IndividualGUID] [uniqueidentifier] NULL,
					[PointCode] [nvarchar](255) NULL,
					[PointGUID] uniqueidentifier NULL,
					[Comments] [nvarchar](255) NULL,
					[GroupId] NVARCHAR(20) NULL,
					[PackageStatus] [nvarchar](255) NULL,
					[PackageID] [uniqueidentifier] NULL,
					[PackageStateID] [uniqueidentifier] NULL,
					[Points] [float] NULL,
					[ipPoints] [float] NULL,
					[SentDate] [smalldatetime] NULL,
					[TransactionDate] [smalldatetime] NULL,
					[TypeOfTransaction] [nvarchar](20) NULL,
					[IncentiveAccountTransactionInfoID] [uniqueidentifier] NULL,
					[AccountID] [uniqueidentifier] NULL,
					[IncentiveTransactionID] [uniqueidentifier] NULL,
					[TransactionsPerDay] [tinyint] NULL,
					[CountryID] [uniqueidentifier] NULL,
					[IncentiveType] [nvarchar](50) NULL,
					[TransactionID] [bigint] NULL,
					[RewardDeliveryTypeCode] [tinyint] NULL,
					[RewardDeliveryTypeID] [uniqueidentifier] NULL
				) ON [PRIMARY]

			--END


		/*******************************************************************************************
		Step 1 - Get the Incentive and redemption transactions from Kantar_DB on the linked server
		********************************************************************************************/


		SELECT @maxseq=MaxSEQ FROM [KTSNGSQL901].Kantar_DB.dbo.STF_MAX_SEQ_GPS
		--SELECT MaxSEQ FROM [KTSNGSQL901].Kantar_DB.dbo.STF_MAX_SEQ_GPS

		INSERT INTO #tmpIncentiveTrans (GroupID, TransactionDate, PointCode, Points, Comments, CountryID)
		SELECT 
			CONVERT(NVARCHAR(20), H_NO)+ '2' as GroupID
			, UP_DATE AS TransactionDate
			, CONVERT(NVARCHAR(20), COD_PUNTOS) + '2' AS PointCode
			, POINT-B_POINT AS Points
			, 'From Website' AS Comments
			, @CountryID
		FROM [KTSNGSQL901].Kantar_DB.dbo.TB_REMNANTPOINT_HIS 
		WHERE SEQ>@maxseq
				AND COD_PUNTOS NOT IN ('100','105','110','115','120','125','130')
				AND H_NO<>''

		/************************************************************************************************************
		Step 2 - Get the IndividualGUID (GroupContactID) and IndivdiualID from the Group MainContact for the Transactions and check data
		*************************************************************************************************************/


		--SELECT t.GroupID, c.GroupContact_Id
		UPDATE #tmpIncentiveTrans
			SET 
				IndividualGUID = c.GroupContact_ID,
				IndividualID = i.IndividualID
		FROM Collective c
			INNER JOIN #tmpIncentiveTrans t ON c.Sequence = CONVERT(INT, t.GroupID)
			INNER JOIN Individual i ON c.GroupContact_ID = i.GUIDReference
		WHERE c.CountryId = @CountryID

		
		/*****************************************************************************
		Step 3 - Get the account ID's and update the Temp table
		*****************************************************************************/

		--SELECT *
		UPDATE #tmpIncentiveTrans SET AccountID = i.GUIDReference
			FROM #tmpIncentiveTrans t 
			INNER JOIN Individual i ON i.GUIDReference = t.IndividualGUID 
				AND t.CountryID = i.CountryId
		 WHERE AccountID IS NULL


		/*****************************************************************************
		Step 4 - Set Redemptions Transactions to Debit and Incentives to Credit 
		*****************************************************************************/

		--SELECT * 
		UPDATE 	#tmpIncentiveTrans SET TypeOfTransaction = ip.[Type], [PointGUID] = ip.GUIDReference
				--CASE 
				--	WHEN Points > 0 THEN 'Credit'
				--	ELSE 'Debit'
				--END,
				--ipPoints = ip.Value
			FROM #tmpIncentiveTrans t
				INNER JOIN IncentivePoint ip ON t.PointCode = Code
				INNER JOIN Respondent r ON ip.GUIDReference = r.GUIDReference
			WHERE r.CountryID = @CountryID --(SELECT CountryID FROM COuntry WHERE CountryISO2A = 'KR')
			AND IndividualGUID IS NOT NULL
			--SET [TypeOfTransaction] = 

		UPDATE 	#tmpIncentiveTrans SET TypeOfTransaction = ip.[Type], [PointGUID] = ip.GUIDReference
				--CASE  
				--	WHEN Points > 0 THEN 'Credit'
				--	ELSE 'Debit'
				--END,
				--ipPoints = ip.Value
			FROM #tmpIncentiveTrans t
				INNER JOIN IncentivePoint ip ON t.PointCode = RewardCode
				INNER JOIN Respondent r ON ip.GUIDReference = r.GUIDReference
			WHERE r.CountryID = @CountryID --(SELECT CountryID FROM COuntry WHERE CountryISO2A = 'KR')
			AND IndividualGUID IS NOT NULL
			AND TypeOfTransaction IS NULL


	

		/****************************************************************************************************
		Step 5 - Get NewID values for each transaction 
		*****************************************************************************************************/

		UPDATE #tmpIncentiveTrans SET IncentiveAccountTransactionInfoID = NewID(), [IncentiveTransactionID] = NewID()
			WHERE IndividualGUID IS NOT NULL



		/****************************************************************************************************
		Step 6 - Make sure that transactions have a unique timestamp
				This process will add a minute to each transaction for a Individual ID if there are multiple 
				transactions in one day. 
		*****************************************************************************************************/

		if exists (	select * from tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#t1')) 
			BEGIN  
				DROP TABLE #t1
				--CREATE TABLE #t1 (
				--	IncentiveAccountTransationInfoID UNIQUEIDENTIFIER
				--	, IndividualID NVARCHAR(20)
				--	, TransactionDate SMALLDATETIME
				--	, MinsAdded SMALLDATETIME
				--	, SentDate SMALLDATETIME
				--	, RowNumber SMALLINT
				--  , TransactionID Bigint
				--  , TypeOfTransaction NVARCHAR(50)
				--	)
			END


		----INSERT INTO #t1
		SELECT IncentiveAccountTransactionInfoID
			, IndividualID
			, TransactionDate
			, DATEADD(mi, ROW_NUMBER() OVER(Partition BY IndividualID, TransactionDate ORDER BY IndividualID, TransactionDate ASC)-1, TransactionDate) AS MinsAdded
			--, CASE 
			--	WHEN TypeOfTransaction = 'Debit' THEN DATEADD(mi, 30, TransactionDate) 
			--	ELSE NULL
			--END AS SentDate
			, DATEADD(mi, 30, TransactionDate) AS SentDate
			, ROW_NUMBER() OVER(Partition BY IndividualID, TransactionDate ORDER BY IndividualID, TransactionDate ASC) AS RowNumber
			, ROW_NUMBER() OVER(ORDER BY IncentiveAccountTransactionInfoID) AS TransactionID
			, TypeOfTransaction
		INTO #t1
		FROM #tmpIncentiveTrans t
				--INNER JOIN IncentivePoint ip ON t.PointCode = RewardCode
				INNER JOIN Respondent r ON t.PointGUID = r.GUIDReference
		WHERE r.CountryID = @CountryID --(SELECT CountryID FROM COuntry WHERE CountryISO2A = 'KR')
			AND AccountID IS NOT NULL


		--Set the sentDate to the transactionDate plus the number of minutes equal to the max number of transactions on a given date per IndividualID

		--SELECT t.IndividualID, t.TransactionDate, mx.MaxRow
		UPDATE #t1 SET SentDate = DATEADD(mi, mx.MaxRow+1, t.TransactionDate)
			FROM #t1 t INNER JOIN (
				SELECT IndividualID, TransactionDate,  max(RowNumber) As MaxRow
					FROM #t1 
				GROUP BY IndividualID, TransactionDate
				) mx ON t.IndividualID = mx.IndividualID AND t.TransactionDate = mx.TransactionDate
			--WHERE TypeOfTransaction = 'Debit'


		--SELECT * FROM #t1 ORDER BY IndividualID, MinsAdded


		/****************************************************************************************************
		If only 1 row per transaction date/time, Rownumber will = 1 but we don't need to add any time to the transaction
		****************************************************************************************************/
		SELECT @MaxTransactionID = Max(TransactionID) FROM IncentiveAccountTransaction WHERE Country_Id = @CountryID

		--SELECT *
		UPDATE #tmpIncentiveTrans SET TransactionDate = MinsAdded, TransactionID = t2.TransactionID + @MaxTransactionID, SentDate = t2.SentDate
			FROM #tmpIncentiveTrans t1
				INNER JOIN #t1 t2 ON t1.IncentiveAccountTransactionInfoID = t2.IncentiveAccountTransactionInfoID



		/**************************************************************************************************************
		Step 7 - Get the RewardDeliveryTypeID and insert into #tmpIncentiveTrans
		This will be the default value of 1
		***************************************************************************************************************/

		--SELECT *
		UPDATE #tmpIncentiveTrans SET RewardDeliveryTypeID = rw.RewardDeliveryTypeId, PackageID = NewID()
			FROM #tmpIncentiveTrans t
				INNER JOIN [dbo].[RewardDeliveryType] rw ON rw.Code = 1
				INNER JOIN IncentivePoint ip ON t.PointCode = RewardCode
				INNER JOIN Respondent r ON ip.GUIDReference = r.GUIDReference
		WHERE r.CountryID = @CountryID --(SELECT CountryID FROM COuntry WHERE CountryISO2A = 'KR')
			AND IndividualGUID IS NOT NULL


		/**************************************************************************************************************************
		Step 8 - Get the PackageID and associated fields, and insert into [KWSLOSQL001\KWSLOSQL2012].GPS_PM.Temp.KR_Redemptions_PF
		***************************************************************************************************************************/

		--SELECT *
		UPDATE #tmpIncentiveTrans SET PackageStateID = sd.ID
			FROM #tmpIncentiveTrans t
				INNER JOIN [dbo].[StateDefinition] sd ON sd.Code = 'PackageSent'
				INNER JOIN IncentivePoint ip ON t.PointCode = RewardCode
				INNER JOIN Respondent r ON ip.GUIDReference = r.GUIDReference AND sd.Country_Id = r.CountryID
		WHERE r.CountryID = @CountryID --(SELECT CountryID FROM COuntry WHERE CountryISO2A = 'KR')
			AND IndividualGUID IS NOT NULL



		 /****************************************************************************************************
		Step 9 - Final visual check of the data in the temp table
		*****************************************************************************************************/
		INSERT INTO [Temp].KR_DailyIncentiveTrans_PF
		SELECT *, @CreationDate FROM #tmpIncentiveTrans  
		--WHERE TypeOfTransaction is not NULL
		--	WHERE IndividualID is not NULL
		--	AND PointGUID IS NOT NULL 
			ORDER BY IndividualID, TransactionDate


		 /****************************************************************************************************
		Step 10 - If all is ready. Finally Insert data into the transactional tables
		*****************************************************************************************************/

		INSERT INTO IncentiveAccountTransactionInfo
		(IncentiveAccountTransactionInfoId, Ammount, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, GiftPrice,
		 Discriminator, Point_Id, RewardDeliveryType_Id, Country_Id)
			 SELECT
				--t.IndividualID
				IncentiveAccountTransactionInfoID
				, CASE 
						WHEN TypeOfTransaction= 'Incentive' THEN Points  --note Incentives can be either positive or negative
						WHEN TypeOfTransaction = 'Reward' THEN Abs(Points) -- rewards should all be stored as positive. The UI and Views will convert to negative when shown or used in a balance calculation
				END AS Points
				, @GPSUser
				, @CreationDate
				, TransactionDate
				, NULL
				, CASE 
						WHEN TypeOfTransaction ='Reward' THEN 'DebitTransactionInfo'
						ELSE 'TransactionInfo'
					END AS Discriminator
				, pointGUID
				, NULL
				, r.CountryID
			FROM #tmpIncentiveTrans t 
				INNER JOIN IncentivePoint ip ON t.PointGUID = ip.GUIDReference
				INNER JOIN Respondent r ON t.PointGUID = r.GUIDReference
				INNER JOIN Individual i ON i.IndividualId = t.IndividualID AND r.CountryID = i.CountryId
			 WHERE r.CountryID = @CountryID
			 AND IndividualGUID IS NOT NULL
			 AND PointGUID IS NOT NULL
			 --ORDER BY IndividualID, IncentiveAccountTransactionInfoID


		--Default Transaction source = 4C053910-489E-4DEA-9654-9C7F1A121D7E

		INSERT INTO IncentiveAccountTransaction
		(IncentiveAccountTransactionId, CreationDate, SynchronisationDate, TransactionDate, Comments, Balance,
		 GPSUser, GPSUpdateTimestamp, CreationTimeStamp, PackageId, TransactionInfo_Id, TransactionSource_Id,
		 Depositor_Id, Panel_Id, DeliveryAddress_Id, Account_Id, [Type], Country_Id, GiftPrice, CostPrice,
		 ProviderExtractionDate, BatchId, TransactionId, ParentTransactionId)
			  SELECT
					t.IncentiveTransactionID
					, @CreationDate
					, NULL
					, TransactionDate
					, 'KantarDB Transaction Daily Update'
					, 0
					, @GPSUser
					, @CreationDate
					, TransactionDate
					, NULL
					, IncentiveAccountTransactionInfoID
					, ts.TransactionSourceId
					, CASE TypeOfTransaction 
						WHEN 'Incentive' THEN i.GUIDReference
						ELSE NULL
					END AS Depositor_ID
					, NULL
					, NULL
					, i.GUIDReference
					, CASE TypeOfTransaction 
						WHEN 'Incentive' THEN 'Credit'
						ELSE 'Debit'
					END
					, i.CountryId
					, NULL --GiftPrice
					, NULL --CostPrice
					, NULL
					, NULL
					, TransactionID
					, NULL
					--, secsAdded
				FROM #tmpIncentiveTrans t
					INNER JOIN Respondent r ON t.PointGUID = r.GUIDReference
					INNER JOIN Individual i ON i.IndividualId = t.IndividualID AND r.CountryID = i.CountryId
					INNER JOIN TransactionSource ts ON ts.Country_ID = i.CountryID AND ts.Code = 'S'
				WHERE IndividualGUID IS NOT NULL
				AND PointGUID IS NOT NULL
				AND r.CountryID = @CountryID


		/***********************************************************
		Step 11 - Insert data into the Package if it's a redemption
		***********************************************************/


		INSERT INTO Package
			(GUIDReference, State_Id, Reward_Id, Debit_Id, Country_Id, DateSent, CreationTimeStamp,
			 GPSUser, GPSUpdateTimestamp)
		SELECT
			PackageID
			, PackageStateID
			, PointGUID
			, IncentiveTransactionID
			, @CountryID
			, SentDate
			, TransactionDate
			, @GPSUser
			, @CreationDate
			--, t.PointCode
		FROM #tmpIncentiveTrans t
			INNER JOIN Respondent r ON PointGUID = r.GUIDReference
		WHERE r.CountryID = @CountryID 
			AND t.PackageID IS NOT NULL
		 	AND IndividualGUID IS NOT NULL
			 AND PointGUID IS NOT NULL
		 --ORDER BY PointCode

----SELECT * FROM IncentivePoint ip
----	INNER jOIN Respondent r ON ip.GUIDReference = r.GUIDReference
----WHERE CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'KR')
----AND RewardCode is not NULL
----ORDER BY RewardCode

/************************************************************************
Step 12 - For redemptions insert data into the StateDefinitionHistory table
*************************************************************************/

		--Package preseted to PackagePending
		INSERT INTO StateDefinitionHistory
		(GUIDReference, GPSUser, CreationDate, GPSUpdateTimestamp, CreationTimeStamp,
		 Comments, CollaborateInFuture, From_Id, To_Id, ReasonForchangeState_Id, Country_Id, Candidate_Id, 
		 Belonging_Id, Panelist_Id, GroupMembership_Id, Action_Id, Order_Country_Id, Package_Id, ImportFile_Id, 
		 ImportFilePendingRecord_Id, Order_Id)
		SELECT 
			NewID()
			, @GPSUser
			, @CreationDate
			, SentDate
			, @CreationDate
			, NULL
			, 0
			, (SELECT ID FROM [dbo].[StateDefinition] sd WHERE Code = 'PackagePreseted' AND sd.Country_Id = @CountryID)
			, (SELECT ID FROM [dbo].[StateDefinition] sd WHERE Code = 'PackagePending' AND sd.Country_Id = @CountryID)
			, NULL
			, @CountryID
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, PackageID
			, NULL
			, NULL
			, NULL
		FROM #tmpIncentiveTrans t
		INNER JOIN Package p ON t.PackageID = p.GUIDReference
		WHERE t.PackageID IS NOT NULL
		 	AND IndividualGUID IS NOT NULL
			 AND PointGUID IS NOT NULL

		--Package PackagePending to current state
		INSERT INTO StateDefinitionHistory
		(GUIDReference, GPSUser, CreationDate, GPSUpdateTimestamp, CreationTimeStamp,
		 Comments, CollaborateInFuture, From_Id, To_Id, ReasonForchangeState_Id, Country_Id, Candidate_Id, 
		 Belonging_Id, Panelist_Id, GroupMembership_Id, Action_Id, Order_Country_Id, Package_Id, ImportFile_Id, 
		 ImportFilePendingRecord_Id, Order_Id)
		SELECT 
			NewID()
			, @GPSUser
			, @CreationDate
			, SentDate
			, @CreationDate
			, NULL
			, 0
			, (SELECT ID FROM [dbo].[StateDefinition] sd WHERE Code = 'PackagePending' AND sd.Country_Id = @CountryID)
			, PackageStateID
			, NULL
			, @CountryID
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, PackageID
			, NULL
			, NULL
			, NULL
		FROM #tmpIncentiveTrans t
				INNER JOIN Package p ON t.PackageID = p.GUIDReference
		WHERE t.PackageID IS NOT NULL
			AND IndividualGUID IS NOT NULL
			 AND PointGUID IS NOT NULL

	COMMIT TRAN

	select @maxseq=MAX(SEQ) From [KTSNGSQL901].Kantar_DB.dbo.TB_REMNANTPOINT_HIS
	Update [KTSNGSQL901].Kantar_DB.dbo.STF_MAX_SEQ_GPS set MaxSEQ=@maxseq, UpdateDate=@CreationDate 



END


--ROLLBACK TRAN








--GO


