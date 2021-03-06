CREATE PROCEDURE [dbo].[ImportLumiTransactions]
	@CountryCode AS VARCHAR(3) = ''
	,@FileName AS VARCHAR(200) =''
	,@ImportType VARCHAR(100) = 'LumiTransactions'
	,@JobId UNIQUEIDENTIFIER  
	,@InsertedRows AS BIGINT OUTPUT
AS
/***********************************************************
Created By : Suresh P, Created On: 25July2016.
Updates:
25-Jul-2016: Changes Related to GPSUser and Transaction count
12-Aug-2016: Enhancements to this PBI - 40969 (should not stop import for any errors)
03-Feb-2017: Updates regarding bug-43458
14-Feb-2017: PBI 43459 Implementation. changing [End time] to [Upload time].
 
EXEC [LumiTransactionsImport] 'AE' , 'test1.xlsx', 'LumiTransactions', newid() , 0
***********************************************************/
BEGIN
	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	DECLARE @ImportDate DATETIME = @Getdate
	DECLARE @GPSUser VARCHAR(20) = 'Lumi'
	DECLARE @State VARCHAR(10)='2'  -- Completed (Always by default)
	DECLARE @CallLength VARCHAR(100) = '00:00:00.0000000'  -- default value
	DECLARE @IsErrorOccured AS BIT = 0
	DECLARE @ErrorSource VARCHAR(500) = 'LumiTransactions'
	DECLARE @CountryId AS UNIQUEIDENTIFIER
	DECLARE @PanelGuid AS UNIQUEIDENTIFIER
	DECLARE @PanelCode AS INT = 1 -- UAE Household Panel
	DECLARE @PanelName AS NVARCHAR(200)
	DECLARE @AuditId AS BIGINT
	DECLARE @Incoming BIT = 1 -- default value
	
		
	PRINT 'STARTED'
		
		SELECT @CountryId = CountryId
		FROM Country WHERE CountryISO2A = @CountryCode

		SELECT @PanelName =  [Name] 
		,@PanelGuid = GUIDReference
		from Panel Where  PanelCode = @PanelCode and Country_Id = @CountryId

		DECLARE @ContactMechanismID as UniqueIdentifier
		SELECT  @ContactMechanismID = GUIDReference 
		FROM ContactMechanismType CM
		Where [Types] = 'SmartPhone' -- ContactMechanismCode = '102'

		DECLARE @ReasonType_Id UniqueIdentifier
		select @ReasonType_Id = CR.GUIDReference from  dbo.CommunicationEventReasonType  CR
		join translation t on T.TranslationId = DescriptionTranslation_Id
		where Country_Id= @CountryId   -- 'F204EDD9-C711-4415-9C61-DC82976415E2' 
		and [KeyName] = 'DescMonthlybarcodescan'  -- 'Lumi Transactions'

		--	select * from [SSIS].LumiTransactionsImport
		
		-- DELETE Empty rows
		DELETE FROM [SSIS].LumiTransactionsImport
		Where ISNULL([Entry ID],'') = ''
		and  ISNULL([Username],'') = ''
		and  ISNULL([Entry Type],'') = ''
		and  ISNULL([Upload time],'') = ''
		and  ISNULL([Start time],'') = ''
		and  ISNULL([End time],'') = ''
			
	-- Update staging data.

	 -------- Counts Calucations   --------------------
	 DECLARE @TotalRows BIGINT = 0
	 DECLARE @EligibleRows BIGINT = 0
	 DECLARE @PreviouslyProcessedRows BIGINT = 0
	 DECLARE @ErrorRowCount BIGINT = 0 -- to be calulated at runtime.

	 DECLARE @CompletedTransactions BIGINT = 0 

		SELECT  @CompletedTransactions = Count([Entry Type]) 
		FROM [SSIS].LumiTransactionsImport 
		WHERE [Entry Type] = 'Complete'
	 	
		 SELECT  @TotalRows = Count([Entry ID]) 
		 FROM [SSIS].LumiTransactionsImport 

		UPDATE temp
		SET IsProcessed = 1
		FROM [SSIS].LumiTransactionsImport temp 
		JOIN  LumiTransactionHistory hist  ON temp.[Entry ID] = hist.EntryID 
		WHERE [Entry Type] = 'Complete'

		SELECT @PreviouslyProcessedRows = count(*) FROM [SSIS].LumiTransactionsImport temp 
		WHERE IsProcessed = 1
		 
		--  @EligibleRows : Completed transations which were not processed previously.
		SELECT  @EligibleRows = Count([Entry ID]) 
		FROM [SSIS].LumiTransactionsImport 
		WHERE [Entry Type] = 'Complete'	AND [Username] is not null and ltrim([Username]) <>'' 
		AND ISNULL(IsProcessed,0) <> 1

		------- Counts Calucations close --------------------------
	
		-- Log Audit Summary 				
		INSERT INTO [LumiFileImportAuditSummary] (
		CountryCode,PanelID,PanelName,[Filename],FileImportDate,GPSUser,TotalRows,CompletedTransactions, PreviouslyProcessedRows,[CommunicationRows],[Status],Comments,ImportType, JobId)
		VALUES ( @CountryCode,@PanelGuid,@PanelName,@FileName,@ImportDate,@GPSUser,@TotalRows,@CompletedTransactions,@PreviouslyProcessedRows,0,'Processing',NULL,@ImportType, @JobId)

		SET @AuditId = @@Identity
		--

	BEGIN TRY
		 --DECLARE @RoleName VARCHAR(50) = (CASE WHEN @CountryCode in ('GB', 'IE')
		 -- THEN 'MainContactRoleName' ELSE 'MainShopperRoleName'  END )
		
		DECLARE @ValidIndividuals AS TABLE 
		(
			Communication_Id  UNIQUEIDENTIFIER,
			Username VARCHAR(20),
			IndividualId VARCHAR(20) ,
			CandidateId UNIQUEIDENTIFIER,
			Panel_Id UNIQUEIDENTIFIER
		)
		INSERT INTO @ValidIndividuals (Communication_Id, Username,IndividualId,CandidateId,Panel_Id)

		SELECT NEWID(), LumiUserId, IndividualId, CandidateId, Panel_Id
		FROM
			( 	-- hh type panels
				SELECT AV.Value as LumiUserId ,I.IndividualId, I.GUIDReference as CandidateId,
				P.Panel_Id, P.GUIDReference as PanelistId
				FROM Attribute A  
				Join AttributeValue AV ON A.GUIDReference = AV.DemographicId
				Join Individual I ON I.GUIDReference = AV.CandidateId
				Join CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
				join Panelist P ON P.PanelMember_Id = CM.Group_Id
				WHERE A.[Key] = 'LUMIUSERNAME'

				UNION ALL  

				-- ind type panels
				SELECT AV.Value as LumiUserId ,I.IndividualId, I.GUIDReference as CandidateId,
				P.Panel_Id, P.GUIDReference as PanelistId
				FROM Attribute A  
				Join AttributeValue AV ON A.GUIDReference = AV.DemographicId
				Join Individual I ON I.GUIDReference = AV.CandidateId
				join Panelist P ON P.PanelMember_Id = I.GUIDReference
				WHERE A.[Key] = 'LUMIUSERNAME'

			) as LumiUsers


 		----------------------------------------
		-- Validations
		----------------------------------------
		-- Both ERROS: 1 & 2   Invalid UserNames / Upload time  

		DECLARE @BothErrors AS TABLE
		(
			[EntryId] Varchar(50),
			[Username] Varchar(200),
			[EndTime] Varchar(50)
		)

		INSERT INTO @BothErrors
		SELECT temp.EntryId,temp.[Username], temp.EndTime
		FROM 
		( SELECT 
		  [Entry ID] EntryId, [Username],[Upload time] EndTime
		  FROM SSIS.LumiTransactionsImport 
		  WHERE [Entry Type] = 'Complete'  and  [Username] is not null and ltrim([Username]) <>'' 
		  AND ISNULL(IsProcessed,0) <> 1		  
		) temp
		LEFT JOIN @ValidIndividuals VI ON temp.[Username] = VI.[Username]
		WHERE VI.[Username] IS NULL 
		AND  TRY_PARSE(EndTime AS DATE USING 'de-CH') IS NULL -- format: DD.MM.YYYY
		

		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'Username / EndTime'
			,'0'
			,'Error: Invalid User Name and Upload time for Entry ID = ' + [EntryId] + ', Upload time: ' + [EndTime]  + ', User name - ' + ISNULL([Username], '') 
			,@ImportDate
			,@JobId
		FROM @BothErrors
		
		SET  @ErrorRowCount =  @ErrorRowCount +  @@ROWCOUNT
		
		
		/*--------------------------------------*/
		-- ERROR : 1. Invalid UserNames				
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'Username'
			,'0'
			,'Error: Invalid User name (' + ISNULL(temp.[Username], '') + ').  Entry ID = ' + EntryId  +''
			,@ImportDate
			,@JobId
		FROM 
		( SELECT 
		  [Entry ID] EntryId, [Username]
		  FROM SSIS.LumiTransactionsImport 
		  WHERE [Entry Type] = 'Complete'  and  [Username] is not null and ltrim([Username]) <>'' 
		  AND ISNULL(IsProcessed,0) <> 1		  
		) temp
		LEFT JOIN @ValidIndividuals VI ON temp.[Username] = VI.[Username]
		WHERE VI.[Username] IS NULL 
		AND EntryId NOT IN (
			SELECT EntryId FROM @BothErrors
		)
		 
		SET  @ErrorRowCount = @ErrorRowCount +  @@ROWCOUNT
		
		
		--IF (@@ROWCOUNT > 0)
			--SET @IsErrorOccured = 1

		 
		-- ERROR : 2. Invalid Upload time  (null or not a date ... )
		-------
		BEGIN TRY
		
			INSERT INTO [dbo].[FileImportErrorLog] 
			(	CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
			SELECT @CountryCode
				,@ImportType
				,@FileName
				,NULL --,VI.Panel_Id
				,'Upload time'
				,'0'			
				,'Error: Invalid Upload time for Entry ID = ' + [Entry Id] + ', Upload time: ' + [Upload time]  +  
				', User name - ' + ISNULL(temp.[Username], '') 
				,@ImportDate
				,@JobId
			FROM SSIS.LumiTransactionsImport temp
			WHERE  [Entry Type] = 'Complete'  and  TRY_PARSE([Upload time] AS DATE USING 'de-CH') IS NULL -- format: DD.MM.YYYY
			AND ISNULL(IsProcessed,0) <> 1	
			AND [Entry ID] NOT IN  (
				SELECT EntryId FROM @BothErrors
			)

			SET  @ErrorRowCount = @ErrorRowCount +  @@ROWCOUNT

			--IF (@@ROWCOUNT > 0)
			--	SET @IsErrorOccured = 1
				
		END TRY
		BEGIN CATCH
			INSERT INTO [dbo].[FileImportErrorLog] 
			(
				CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
			values( @CountryCode
				,@ImportType
				,@FileName
				,NULL
				,@ErrorSource
				,'0'			
				,'Invalid Upload time' 
				,@ImportDate
				,@JobId
				)
			
			--	SET  @ErrorRowCount = @ErrorRowCount +  @@ROWCOUNT
		
			--IF (@@ROWCOUNT > 0)
			--	SET @IsErrorOccured = 1

		END CATCH
		
		/*--------------------------------------*/	
		---
	END TRY

	BEGIN CATCH
		PRINT 'VALIDATION ERRROR OCCURED:'

		INSERT INTO [dbo].[FileImportErrorLog] (CountryCode,ImportType,[FileName],PanelCode,ErrorSource
			,ErrorCode,ErrorDescription,ErrorDate,JobId)
		SELECT @CountryCode,@ImportType,@FileName,NULL,'Unknown'
			,ERROR_NUMBER(),ERROR_MESSAGE(),@ImportDate,@JobId

		UPDATE [LumiFileImportAuditSummary]
		SET [Status] = 'Error'
			,Comments = N'' + ERROR_MESSAGE()
			,[CommunicationRows] = @InsertedRows
		WHERE AuditId = @AuditId

		--IF (@@ROWCOUNT > 0)
		--	SET @IsErrorOccured = 1

		PRINT ERROR_MESSAGE();
	END CATCH

--  @EligibleRows : Completed transations which were not processed previously and after filtering errors
	SET @EligibleRows = @EligibleRows -  @ErrorRowCount

	print 'ErrorRowCount' + Convert(varchar(5), @ErrorRowCount)
	print 'EligibleRows' + Convert(varchar(5), @EligibleRows)

	PRINT 'Is ErrorOccured :'
	PRINT @IsErrorOccured

	-- PERFORM ACTUAL LOGIC
	--IF @IsErrorOccured = 0 --  NO ISSUES WITH DATA
	--BEGIN
		BEGIN TRANSACTION;
		BEGIN TRY
			PRINT 'PROCESS STARTED'
			--	select * from lumiTransactionHistory
		 INSERT INTO lumiTransactionHistory
		 ([FileName],EntryID,Username,BusinessId,ImportDate)
		
		 SELECT @FileName ,[Entry ID], temp.Username, IndividualId , @ImportDate
		 FROM SSIS.LumiTransactionsImport temp
		JOIN  ( select AV.Value Username, IndividualId
			FROM Attribute A  
			Join AttributeValue AV ON A.GUIDReference = AV.DemographicId
			Join Individual I ON I.GUIDReference = AV.CandidateId
			Join CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
			join Panelist P ON P.PanelMember_Id = CM.Group_Id
			WHERE A.[Key] = 'LUMIUSERNAME'
			)  usr ON usr.Username = temp.Username
		 where  TRY_PARSE([Upload time] AS DATE USING 'de-CH') IS NOT NULL 
		 AND ISNULL(IsProcessed,0) <> 1	
		 AND temp.[Entry Type] = 'Complete'

			 SELECT MAX([Entry ID]) EntryId, [Username], 
			 Count(1) as TransactionCount,
			 MAX(Convert(datetime, [Upload time],104 )) EndTime
			 INTO #tempCommunications
			  FROM SSIS.LumiTransactionsImport 
			  WHERE [Entry Type] = 'Complete'
			  AND [Username] is not null and ltrim([Username]) <>'' 
			  AND ISNULL(IsProcessed,0) <> 1	
			  AND TRY_PARSE([Upload time] AS DATE USING 'de-CH') IS NOT NULL 
			  GROUP BY [Username]  


			 -- Create new data
			INSERT INTO CommunicationEvent (
				GUIDReference
				,CreationDate
				,Incoming
				,[STATE]
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,CallLength 
				,ContactMechanism_Id
				,Country_Id
				,Candidate_Id
				)
			SELECT VI.Communication_Id
				,temp.EndTime
				,@Incoming
				,@STate				
				,@GPSUser
				,@ImportDate
				,@ImportDate
				,@CallLength 
				,@ContactMechanismID
				,@CountryId
				,VI.CandidateId
			FROM 
			(SELECT EntryId, [Username], TransactionCount, EndTime
			FROM  #tempCommunications) temp
			--( SELECT 
			--	 MAX([Entry ID]) EntryId, [Username],
			--	 MAX(Convert(datetime, [Upload time],104 )) EndTime
			--	  FROM SSIS.LumiTransactionsImport 
			--	  WHERE [Entry Type] = 'Complete'
			--	  AND [Username] is not null and ltrim([Username]) <>'' 
			--	  AND ISNULL(IsProcessed,0) <> 1	
			--	  AND TRY_PARSE([Upload time] AS DATE USING 'de-CH') IS NOT NULL 
			--	  GROUP BY [Username]  
			--) temp
			JOIN @ValidIndividuals VI ON temp.[Username] = VI.[Username]
			
			SET @InsertedRows = @@ROWCOUNT

			 INSERT INTO CommunicationEventReason (
				GUIDReference
				,Comment
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,ReasonType_Id
				,Country_Id
				,Communication_Id
				,panel_id
				)
			SELECT NEWID()
				, 'Records: ' +  convert(Varchar(200), temp.TransactionCount)  
				,@GPSUser
				,@ImportDate
				,@ImportDate
				,@ReasonType_Id
				,@CountryId
				,VI.Communication_Id
				,VI.Panel_Id
			FROM
			(SELECT EntryId, [Username], TransactionCount, EndTime
			FROM  #tempCommunications) temp
			JOIN @ValidIndividuals VI ON temp.[Username] = VI.[Username]


			PRINT '@InsertedRows : ' + convert(VARCHAR(10), isnull(@InsertedRows,0))

			UPDATE [LumiFileImportAuditSummary]
			SET [Status] = 'Completed'
				,TotalRows = @TotalRows
				--,PreviouslyProcessedRows = @PreviouslyProcessedRows
				,ErrorCount = @ErrorRowCount
				,EligibleRowCount = @EligibleRows
				,[CommunicationRows] = @InsertedRows
				,Comments =   (CASE WHEN  @ErrorRowCount > 0 THEN 'Few Errors Occured.' ELSE NULL END)
			WHERE AuditId = @AuditId
			
			COMMIT TRANSACTION;
		END TRY

		BEGIN CATCH
			PRINT 'CRITICAL ERROR OCCURED'
			ROLLBACK TRANSACTION;

			INSERT INTO [dbo].[FileImportErrorLog] (
				CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
			SELECT @CountryCode
				,@ImportType
				,@FileName
				,NULL
				,'Unknown'+ CAST(ERROR_LINE() AS VARCHAR)
				,ERROR_NUMBER()
				,ERROR_MESSAGE()
				,@ImportDate
				,@JobId

			PRINT ERROR_MESSAGE();

			UPDATE [LumiFileImportAuditSummary]
			SET [Status] = 'Error'
				,Comments = N'' + ERROR_MESSAGE()
				,[CommunicationRows] = @InsertedRows
				,TotalRows = @TotalRows
			WHERE AuditId = @AuditId
		END CATCH

		
--	END
	--ELSE
	--BEGIN
	--	 Update [LumiFileImportAuditSummary]
	--	  SET [Status] = 'Error',
	--	  Comments = 'Input file has invalid data.',
	--	  [CommunicationRows] = 0
	--	  Where AuditId = @AuditId
	--END
	SELECT @InsertedRows
END
GO
