USE [GPS_PM]
GO

/****** Object:  StoredProcedure [dbo].[ID_Weekly_IncentiveRedemptionPurchaseSummaryDataTransfer]    Script Date: 06/02/2018 09:01:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
 
CREATE Procedure [dbo].[ID_Weekly_IncentiveRedemptionPurchaseSummaryDataTransfer]

AS

BEGIN


	DECLARE @Sunday DATETIME
	DECLARE @YR int
	DECLARE @PD int
	DECLARE @CountryISO2A NVARCHAR(3)
	DECLARE @CountryID UNIQUEIDENTIFIER
	DECLARE @SummaryCategoryID UNIQUEIDENTIFIER
	DECLARE @CollaborationCode NVARCHAR(5)
	DECLARE @CollaborationMethodID UNIQUEIDENTIFIER
	DECLARE @Category NVARCHAR(100)
	DECLARE @CalendarID UNIQUEIDENTIFIER
	DECLARE @CalendarPeriodID UNIQUEIDENTIFIER
	DECLARE @PanelID UNIQUEIDENTIFIER
	DECLARE @PanelCode TINYINT
	DECLARE @GPSUser NVARCHAR(50)
	DECLARE @GPSTimeStamp DATETIME
	DECLARE @TransactionSourceID UNIQUEIDENTIFIER
	DECLARE @MaxTransactionID BIGINT
	DECLARE @IncentiveCode INT
	DECLARE @Points INT

	--DECLARE @TransactionSourceCode NVARCHAR(50) -- this variable is not needed, just take the default value
	
	--Get the previous week's,  Year, period, week from the Country calendar for the date which the sp is running
	--for example if the job runs on Sunday of period 2018.1 then the calendar information, and data, will be for period 2017.13

	SELECT @Sunday = CONVERT(date, getDate()-7) --DATEADD(dd, 0, DATEDIFF(dd, 0, GetDate()))
	--SET @Sunday = '2018-01-07' --Testing variable

	SET @GPSTimeStamp = GetDate() --@Sunday+1 --the job runs on Sunday in the UK, but this is actually Monday in Asia so need to add a day
	SET @CountryISO2A = 'ID'
	SET @GPSUser = 'DataEntry_' + @CountryISO2A + '_WeeklyPurchaseCount_IncentivesUpdate'
	--SET @TransactionSourceCode = 'S'
	SET @IncentiveCode = 301
	SET @Points = 100

	SELECT @CountryID = CountryID FROM Country WHERE CountryISO2A = @CountryISO2A
	SELECT @TransactionSourceID = TransactionSourceId FROM TransactionSource  WHERE Country_ID = @CountryID AND IsDefault = 1
	-- Code = @TransactionSourceCode

	PRINT @CountryID
	PRINT @Sunday
	PRINT @GPSTimeStamp

	--SET @Yr = 2018
	--SET @pd = 1

	SELECT DISTINCT @CalendarID = CalendarID, @CalendarPeriodID = periodPeriodID, @yr = YearPeriodValue, @PD = periodPeriodValue
		 FROM CalendarDenorm 
	WHERE PeriodStartDate <= @Sunday
		AND PeriodEndDate >= @Sunday
		AND OwnerCountryID = @CountryID

	PRINT @CalendarID
	PRINT @CalendarPeriodID

	--SELECT * FROM CalendarPeriod WHERE CalendarID = '350AC676-DAD1-482A-957A-226725619BE7' AND PeriodID = '6CDEA93F-D924-4DDE-BAF0-8EAFB4360130'


	PRINT @yr
	PRINT @pd

	--Call stored procedure on the DataEntry database in JAK to prepare the data for the current period -1
	EXEC [KTJABSQL902].DataEntry.dbo.GPS_COMPST_TB_SP @yr, @pd

	if exists (	select * from tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#tmpPurchaseSummary')) 
		BEGIN  
			DROP TABLE #tmpPurchaseSummary
		END

			CREATE TABLE  #tmpPurchaseSummary  
			(
				BusinessID nvarchar(50)
				, GroupID nvarchar(50)
				, PurchaseCount SMALLINT
				, Category NVARCHAR(100)
				, PanelCode TINYINT
				, [Year] SMALLINT
				, [Period] TINYINT
				, [Week] TINYINT
				, YPW NVARCHAR(10)
				, TransactionDate DATETIME
				, WeekEndDate DATETIME
				, Points SMALLINT
				, IncentiveCode SMALLINT
				, IncentiveGUID UNIQUEIDENTIFIER
				, CalendarID UNIQUEIDENTIFIER
				, CalendarPeriodID UNIQUEIDENTIFIER
				, CalendarWeekPeriodID UNIQUEIDENTIFIER
				, CandidateID UNIQUEIDENTIFIER
				, IncentiveAccountTransactionID UNIQUEIDENTIFIER
				, IncentiveAccountTransactionInfoID UNIQUEIDENTIFIER
				, PanelGUID UNIQUEIDENTIFIER
				, TransactionID BigINT
				, PanelistID UNIQUEIDENTIFIER
				, SummaryCategoryID UNIQUEIDENTIFIER
				, CountryID UNIQUEIDENTIFIER
				, CountryISO2A NVARCHAR(3)
				, CollaborationMethodologyID UNIQUEIDENTIFIER
				, TransactionSourceID UNIQUEIDENTIFIER
				, Balance INT
				CONSTRAINT BusinessID_PK PRIMARY KEY CLUSTERED ( BusinessID, GroupID, [Year], Period, [Week], Category)
			)

	INSERT INTO #tmpPurchaseSummary (BusinessID, GroupID, PanelCode, [Year], Period, [Week], Category, PurchaseCount, YPW, IncentiveCode, Points, CalendarPeriodID, CalendarID,
		CountryID, CountryISO2A)
		SELECT
 			SUBSTRING(CONVERT(NVARCHAR(10), BusinessID), 1, 6) + '-' + SUBSTRING(CONVERT(NVARCHAR(10), BusinessID), 7, 2)
			, SUBSTRING(CONVERT(NVARCHAR(10), BusinessID), 1, 6)
			, PanelID
			, [Year]
			, Period
			, [Week]
			, Category
			, PurchaseCountValue
			, CONVERT(NVARCHAR(4), [Year]) + '.' + CONVERT(NVARCHAR(3), Period) + '.' + CONVERT(NVARCHAR(3), [Week])
			, @IncentiveCode
			, @Points
			, @CalendarPeriodID AS CalendarPeriodID
			, @CalendarID AS CalendarID
			, @CountryID AS CountryID
			, @CountryISO2A
		FROM [KTJABSQL902].DataEntry.dbo.GPS_COMPST_TB
		WHERE BusinessID is NOT NULL

	--SELECT * FROM #tmpPurchaseSummary
	--SELECT * FROM CalendarDenorm WHERE OwnerCountryID = (SELECT CountryID FROM Country WHERE COuntryISO2A = 'ID')
	
	 UPDATE #tmpPurchaseSummary SET CalendarWeekPeriodID = WeekPeriodID
		FROM #tmpPurchaseSummary t
			INNER JOIN CalendarDenorm cd ON t.YPW = cd.YearPeriodWeek AND cd.OwnerCountryID = @CountryID

	UPDATE #tmpPurchaseSummary SET CandidateID = i.GUIDReference
		FROM #tmpPurchaseSummary t INNER JOIN Individual i ON t.BusinessID = i.IndividualID AND t.CountryID = i.CountryID

	UPDATE #tmpPurchaseSummary SET WeekEndDate = c.WeekEndDate
		FROM #tmpPurchaseSummary t 
		INNER JOIN CalendarDenorm c 
			ON t.[Year] = c.YearPeriodValue
			AND t.Period = c.PeriodPeriodValue
			AND t.[Week] = c.WeekPeriodValue
			AND t.CountryID = c.OwnerCountryID
 
	UPDATE #tmpPurchaseSummary SET IncentiveGUID = ip.GUIDReference, SummaryCategoryID = sc.SummaryCategoryId
		FROM #tmpPurchaseSummary t 
		INNER JOIN incentivePoint ip ON ip.Code = @IncentiveCode
		INNER JOIN Respondent r ON t.CountryID = r.CountryID
		INNER JOIN Summary_Category sc 
			ON sc.Code = t.Category 
			AND sc.Country_Id = t.CountryID

	--Panel
	UPDATE #tmpPurchaseSummary SET PanelGUID = p.GUIDReference
		FROM #tmpPurchaseSummary t
		INNER JOIN Panel p ON t.PanelCode = p.PanelCode AND t.CountryID = p.Country_ID

	--Panelists Individual panels
	UPDATE #tmpPurchaseSummary SET PanelistID = pl.GUIDReference, CollaborationMethodologyID = pl.CollaborationMethodology_Id
		FROM #tmpPurchaseSummary t
		INNER JOIN Panelist pl ON t.CandidateID = pl.PanelMember_ID AND pl.Country_ID = t.CountryID AND t.PanelGUID = pl.Panel_Id


	--Panelist's Group panels
	UPDATE #tmpPurchaseSummary SET PanelistID = pl.GUIDReference, CollaborationMethodologyID = pl.CollaborationMethodology_Id
		FROM #tmpPurchaseSummary t
		INNER JOIN Collective c ON t.GroupID = c.Sequence AND t.CountryID = c.CountryId
		INNER JOIN Panelist pl ON c.GUIDReference = pl.PanelMember_ID AND pl.Country_ID = t.CountryID AND t.PanelGUID = pl.Panel_Id

	--SELECT * FROM #tmpPurchaseSummary

	--Total Values per week
	PRINT 'Update existing'
	--Update any values that are already in PanelistSummaryCount for the period being imported, but do not have the same values for the PurchaseCount

	UPDATE [dbo].[PanelistSummaryCount] SET SummaryCount = t.PurchaseCount
		FROM #tmpPurchaseSummary t
			INNER JOIN [PanelistSummaryCount] p 
				ON t.PanelistID = p.PanelistID
				AND t.CalendarID = p.CalendarPeriod_CalendarID
				AND t.CalendarWeekPeriodID = p.CalendarPeriod_PeriodID
				AND t.CountryID = p.Country_ID
				AND t.SummaryCategoryID = p.SummaryCategoryID
				AND t.PanelGUID = p.Panel_ID
			WHERE t.PanelistID is NOT NULL --AND Category = 'S_COMPERF'
			AND t.PurchaseCount <> p.SummaryCount

	--Insert any New values
	PRINT 'Insert new'
	INSERT INTO [dbo].[PanelistSummaryCount] (GUIDReference, PanelistId, SummaryCategoryId, SummaryCount, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, 
		Panel_Id, CalendarPeriod_CalendarId, CalendarPeriod_PeriodId, Country_Id, CallLength, CollaborationMethodology_Id)
		SELECT 
			NewID()
			, t.PanelistID
			, t.SummaryCategoryID
			, PurchaseCount
			, @GPSUser
			, @GPSTimeStamp
			, @GPSTimeStamp
			, PanelGUID
			, CalendarID
			, CalendarWeekPeriodID
			, CountryID
			, NULL
			, CollaborationMethodologyID
		FROM #tmpPurchaseSummary t
			LEFT JOIN [PanelistSummaryCount] p 
				ON t.PanelistID = p.PanelistID
				AND t.CalendarID = p.CalendarPeriod_CalendarID
				AND t.CalendarWeekPeriodID = p.CalendarPeriod_PeriodID
				AND t.CountryID = p.Country_ID
				AND t.SummaryCategoryID = p.SummaryCategoryID
				AND t.PurchaseCount = p.SummaryCount
				AND t.PanelGUID = p.Panel_ID
			WHERE t.PanelistID is NOT NULL -- AND Category = 'S_COMPERF'
			AND p.GUIDReference is NULL

--SELECT * FROM #tmpPurchaseSummary

/**************************************************************************************************************
Allocate Incentives
------------------- 
***	Note that you have to be careful when allocating Incentives.
	
	If an incentive of code 301 with a Points allocation of 100 exists for the
	Individual for the imported week, then don't reallocate
***
***************************************************************************************************************/

	if exists (	select * from tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#tmpIncentiveTransaction')) 
		BEGIN  
			DROP TABLE #tmpIncentiveTransaction
		END

	CREATE TABLE #tmpIncentiveTransaction (
					IncentiveAccountTransactionInfoID UNIQUEIDENTIFIER
					, Points INT
					, TransactionDate DATETIME
					, IncentiveGUID UNIQUEIDENTIFIER
					, CountryID UNIQUEIDENTIFIER
					, IncentiveAccountTransactionID UNIQUEIDENTIFIER
					, Comments NVARCHAR(500)
					, TransactionSourceId UNIQUEIDENTIFIER
					, CandidateID UNIQUEIDENTIFIER
					, PanelistID UNIQUEIDENTIFIER
					, PanelGUID UNIQUEIDENTIFIER
					, TransactionID BIGINT
					)

	INSERT INTO #tmpIncentiveTransaction(TransactionDate, Points, IncentiveGUID, TransactionSourceID, CandidateID, PanelistID, PanelGUID, CountryID, Comments)
		SELECT DISTINCT 
			@Sunday
			, Points
			, IncentiveGUID
			, @TransactionSourceID
			, CandidateID
			, PanelistID
			, PanelGUID
			, CountryID
			, 'ID Weekly Purchase Summary Import' --, @CountryISO2A + ' Weekly Purchase Summary Import'
		FROM #tmpPurchaseSummary
		WHERE PanelistID IS NOT NULL
		ORDER BY CandidateID

	UPDATE #tmpIncentiveTransaction SET IncentiveAccountTransactionInfoID = NewID(), IncentiveAccountTransactionID = NewID()



--/****************************************************************************************************
--Create a unique transactionID per row where we have a CandidateID and a PanellistID.
--*****************************************************************************************************/

	if exists (	select * from tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#t2')) 
		BEGIN  
			DROP TABLE #t2
			--CREATE TABLE #t2 (
			--	IncentiveAccountTransationInfoID UNIQUEIDENTIFIER
			--  , TransactionID Bigint
			--	)
		END

	PRINT 'Determine TransactionID'

	SELECT IncentiveAccountTransactionInfoID
		, ROW_NUMBER() OVER(ORDER BY IncentiveAccountTransactionInfoID) AS TransactionID
	INTO #t2
	FROM #tmpIncentiveTransaction WHERE CandidateID IS NOT NULL AND PanelistID IS NOT NULL

	SELECT @MaxTransactionID = Max(TransactionID) FROM IncentiveAccountTransaction WHERE Country_Id = @CountryID

	PRINT 'Update #tmpPurchaseSummary with TransactionID'
		
	UPDATE #tmpIncentiveTransaction SET TransactionID = t2.TransactionID + @MaxTransactionID
			FROM #t2 t2 INNER JOIN #tmpIncentiveTransaction p ON t2.IncentiveAccountTransactionInfoID = p.IncentiveAccountTransactionInfoID

	----this is for testing/checking data 
	--INSERT INTO [Temp].KR_WeeklyTestingPurchaseSummary_PF 
	--		SELECT * FROM #tmpIncentiveTransaction
	--select * from individual where guidreference = 'D697CBAA-FE86-C797-D12E-08D41454A63D'

	PRINT 'INSERT INTO IncentiveAccountTransactionInfo'

	INSERT INTO IncentiveAccountTransactionInfo
			SELECT
			IncentiveAccountTransactionInfoID
			, Points
			, @GPSUser
			, @GPSTimeStamp
			, t.TransactionDate
			, NULL
			, 'TransactionInfo'
			, IncentiveGUID
			, NULL
			, CountryID
		FROM #tmpIncentiveTransaction t 
		LEFT JOIN
			( 
				SELECT 
					iat.IncentiveAccountTransactionID
					, iat.TransactionDate
					, iat.Account_ID
					, iat.Panel_ID
					, iat.Country_ID
					, ia.Point_ID
					FROM IncentiveAccountTransaction iat
					INNER JOIN IncentiveAccountTransactionInfo ia
					ON iat.TransactionInfo_ID = ia.IncentiveAccountTransactionInfoID
					--WHERE GPSUser = 'DataEntry_ID_WeeklyPurchaseCount_IncentivesUpdate' 
			) i
			ON i.TransactionDate = t.TransactionDate
			AND i.Account_Id = t.CandidateID
			AND i.Panel_Id = t.PanelGUID
			AND i.Country_Id = t.CountryID
			AND i.Point_ID = t.IncentiveGUID
		WHERE CandidateID IS NOT NULL 
			AND PanelistID IS NOT NULL
			AND i.IncentiveAccountTransactionId IS NULL
		--ORDER BY IncentiveAccountTransactionInfoID

	--SELECT * FROM #tmpIncentiveTransaction

		----Default Transaction source = 4C053910-489E-4DEA-9654-9C7F1A121D7E
	PRINT 'INSERT INTO IncentiveAccountTransaction'	
			
	INSERT INTO IncentiveAccountTransaction
			SELECT
				t.IncentiveAccountTransactionID
				, t.TransactionDate
				, NULL
				, t.TransactionDate
				, t.Comments
				, 0
				, @GPSUser
				, @GPSTimeStamp
				, t.TransactionDate
				, NULL
				, IncentiveAccountTransactionInfoID
				, TransactionSourceId
				, CandidateID AS Depositor_ID
				, PanelGUID
				, NULL
				, CandidateID
				, 'Credit'
				, CountryId
				, NULL --GiftPrice
				, NULL --CostPrice
				, NULL
				, NULL
				, t.TransactionID
				, NULL
				--, secsAdded
		FROM #tmpIncentiveTransaction t
		LEFT JOIN
			( 
				SELECT 
					iat.IncentiveAccountTransactionID
					, iat.TransactionDate
					, iat.Account_ID
					, iat.Panel_ID
					, iat.Country_ID
					, ia.Point_ID
					FROM IncentiveAccountTransaction iat
					INNER JOIN IncentiveAccountTransactionInfo ia
					ON iat.TransactionInfo_ID = ia.IncentiveAccountTransactionInfoID
			) i
			ON i.TransactionDate = t.TransactionDate
			AND i.Account_Id = t.CandidateID
			AND i.Panel_Id = t.PanelGUID
			AND i.Country_Id = t.CountryID
			AND i.Point_ID = t.IncentiveGUID
		WHERE CandidateID IS NOT NULL 
			AND PanelistID IS NOT NULL
			AND i.IncentiveAccountTransactionId IS NULL




	/***********************************************
	Testing scripts 2017 period 12 used for testing
	************************************************/
	--SELECT * FROM #tmpPurchaseSummary t
	--	INNER JOIN IncentiveAccount ia ON t.CandidateID = ia.IncentiveAccountId ORDER BY BusinessID, Category, Year, Period, Week DESC

	--UPDATE PanelistSUmmaryCount SET SummaryCount = 12 WHERE GUIDReference = '93D5FB54-E9F2-4F4C-80CE-BC44A540096F' --COMPERF Update test 1 Row to update - value should be 16 after update
	--UPDATE PanelistSUmmaryCount SET SummaryCount = 16 WHERE GUIDReference = '6DE44C62-66E5-45BF-BB08-2B8A01004735' --COMALI Update test 1 Row to update - value should be 8 after update
	--DELETE  FROM PanelistSummaryCount WHERE PanelistID = 'E139FF32-8F67-C465-2C5F-08D3D89FDAAF' --8 COMPERF/COMALI records inserted

	--Checking the tests

	--SELECT * FROM PanelistSummaryCount p
	--	INNER JOIN Summary_Category sc ON p.SummaryCategoryId = sc.SummaryCategoryId
	--	 WHERE GUIDReference = '93D5FB54-E9F2-4F4C-80CE-BC44A540096F'

	--SELECT * FROM PanelistSummaryCount p
	--	INNER JOIN Summary_Category sc ON p.SummaryCategoryId = sc.SummaryCategoryId
	--	 WHERE GUIDReference = '6DE44C62-66E5-45BF-BB08-2B8A01004735'

	--SELECT * FROM PanelistSummaryCount p
	--	INNER JOIN Summary_Category sc ON p.SummaryCategoryId = sc.SummaryCategoryId
	--	 WHERE PanelistID = 'E139FF32-8F67-C465-2C5F-08D3D89FDAAF'

	--SELECT * 
	----DELETE 
	--FROM [dbo].[PanelistSummaryCount]  p
	--	INNER JOIN Summary_Category sc ON p.SummaryCategoryId = sc.SummaryCategoryId
	--WHERE p.COuntry_ID = 'bc36d6a7-57a0-42bf-abf0-3d24db894598'
	--ORDER BY PanelistID, sc.Code
	--CalendarPeriod_CalendarId = '350AC676-DAD1-482A-957A-226725619BE7'
	--	AND CalendarPeriod_PeriodId = '99F2625E-A6D2-4EDB-AADA-F1B46CC87CB9'


END




GO

