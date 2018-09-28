
CREATE PROCEDURE [dbo].[ImportHitListForInsert] (

	@CountryCode AS VARCHAR(3) = 'GB'

	--,@PanelCode AS INT = 0

	,@FileName AS VARCHAR(200)

	,@JobId AS VARCHAR(200)

	,@ImportType AS VARCHAR(100) = 'HitListImport'

	--,@InsertedRows AS BIGINT OUTPUT

	)

	/*##########################################################################

Author	: Rajender Reddy A

Date	: 08-JAN-2015 - Initial Version

Purpose : File Imported data related to HitList is available in Temp table.

		  This Procedure validated each column from the Temp table and inserts into Target table.

Updates: 

		21/05/2015: Added @Category_MonthlyReceive ,@Category_MonthlyPurchase

EXECUTE SP:

  DECLARE @InsertedRows BIGINT = 0 

	EXEC [[ImportHitListForInsert]]  'TW', 4, 'COMPST-MP.CSV',  @InsertedRows =0 

##########################################################################*/

AS

BEGIN
BEGIN TRY

	

	DECLARE @InsertedRows AS BIGINT

	DECLARE @GPSUser VARCHAR(20) = 'HitListUser'

	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(getdate(),@CountryCode))

	DECLARE @ImportDate DATETIME = @Getdate 

	--DECLARE @ImportType VARCHAR(100)  = 'PurchaseSummaryCounts'

	DECLARE @CountryId AS UNIQUEIDENTIFIER

	DECLARE @IsErrorOccured AS BIT = 0

	--DECLARE @PanelGUID AS UNIQUEIDENTIFIER

	--DECLARE @PanelistId AS UNIQUEIDENTIFIER

	--DECLARE @paneltype AS VARCHAR(20)

	--DECLARE @PanelName AS VARCHAR(50)

	DECLARE @AuditId AS BIGINT



	BEGIN TRY

		SELECT @CountryId = CountryId

		FROM Country

		WHERE CountryISO2A = @CountryCode



		PRINT 'COUNTRY ID: '

		PRINT @CountryId



		--SELECT @PanelGUID = GUIDReference

		--	,@PanelName = NAME

		--	,@paneltype = [Type]

		--FROM Panel

		--WHERE PanelCode = @PanelCode

		--	AND Country_Id = @CountryId



		--PRINT 'PANEL GUID: '

		--PRINT @PanelGUID



		-- Log Audit Summary 				

		INSERT INTO [FileImportAuditSummary] (

			CountryCode

			,PanelID

			,PanelName

			,[Filename]

			,FileImportDate

			,GPSUser

			,TotalRows

			,PassedRows

			,[Status]

			,Comments

			,ImportType

			,JobId

			)

		VALUES (

			@CountryCode

			,NULL

			,NULL

			,@FileName

			,@ImportDate

			,@GPSUser

			,0

			,0

			,'Processing'

			,NULL

			,@ImportType

			,@JobId

			)



		SET @AuditId = @@Identity





		

		--------------------------------------

		-- VALIDATIONS  -- ERROR LOG

		--------------------------------------

		

		

-- ERROR : 0. HouseHold Number validation (within the file)



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

		SELECT DISTINCT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'HHNO'			

			,'0'

			,' Error: Household Number doesnot exist : ' + convert(VARCHAR(10), HT.HHNO)

			,@ImportDate

			,@JobId

	     FROM dbo.temphitlist HT

		LEFT JOIN Collective C ON C.Sequence = HT.HHNO 		

			--AND C.Country_Id = @CountryId

			WHERE   C.Sequence IS NULL and jobid=@JobId

       UNION



       SELECT DISTINCT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'HHNO'			

			,'0'

			,' Error: Household Number is NULL for Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

			 FROM dbo.temphitlist HT WHERE HT.HHNO  iS NULL and jobid=@JobId



		IF @@ROWCOUNT > 0

			SET @IsErrorOccured = 1





 ----ERROR : 1. PERIOD is NULL (within the file)

	--	INSERT INTO [dbo].[FileImportErrorLog] (

	--		CountryCode

	--		,ImportType

	--		,[FileName]

	--		,PanelCode

	--		,ErrorSource

	--		,ErrorCode

	--		,ErrorDescription

	--		,ErrorDate

	--		,JobId

	--		)

	--	 SELECT DISTINCT @CountryCode

	--		,@ImportType

	--		,@FileName

	--		,NULL

	--		,'PERIOD'			

	--		,'0'

	--		,' Error: Period is NULL for HHNO: ' + isnull(HT.HHNO, '')

	--		,@ImportDate

	--		,@JobId

	--		FROM dbo.temphitlist HT 

	--	LEFT JOIN ( select 

	--	distinct CONVERT(varchar(50),yearPeriodValue) +  right('00'+CONVERT(varchar(50),periodPeriodValue),2) AS YearPeriod

	--	from CalendarDenorm  where CountryISO2A=@CountryCode) CAL

	--	ON CAL.YearPeriod=HT.period where YearPeriod IS NULL



	--	IF @@ROWCOUNT > 0

	--		SET @IsErrorOccured = 1



---- ERROR : 1.1. PERIOD is not the current period (within the file)

--		INSERT INTO [dbo].[FileImportErrorLog] (

--			CountryCode

--			,ImportType

--			,[FileName]

--			,PanelCode

--			,ErrorSource

--			,ErrorCode

--			,ErrorDescription

--			,ErrorDate

--			,JobId

--			)

--		 SELECT DISTINCT @CountryCode

--			,@ImportType

--			,@FileName

--			,NULL

--			,'PERIOD'			

--			,'0'

--			,' Error: PERIOD is not the current period for HHNO: ' + isnull(HT.HHNO, '')

--			,@ImportDate

--			,@JobId

--			FROM dbo.temphitlist HT 

--		LEFT JOIN ( select 

--		distinct CONVERT(varchar(50),yearPeriodValue) +  right('00'+CONVERT(varchar(50),periodPeriodValue),2) AS YearPeriod

--		from CalendarDenorm  where CountryISO2A='GB') CAL

--		ON CAL.YearPeriod=HT.period where YearPeriod IS NULL



--		IF @@ROWCOUNT > 0

--			SET @IsErrorOccured = 1



-- ERROR : 1.1. PERIOD is not the current period (within the file)

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

		 SELECT DISTINCT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'PERIOD'			

			,'0'

			,' Error: Invalid Periods : Period -' + isnull(HT.PERIOD, '')

			,@ImportDate

			,@JobId

			from dbo.temphitlist HT 

  where period not  in 

  (

 select  distinct

 CONVERT(varchar(50), (case when periodPeriodValue =1 then CONVERT(varchar(50),yearPeriodValue-1) else yearPeriodValue end ))   + 

  right('00'+CONVERT(varchar(50), (case when periodPeriodValue = 1 then 13 else periodPeriodValue-1  end )) ,2) PrevPeriod

  from CalendarDenorm

  where @Getdate between periodStartDate and periodEndDate and CountryISO2A=@CountryCode and CalendarDescription='Nation-GB-Calendar'

  ) and jobid=@JobId



		IF @@ROWCOUNT > 0

			SET @IsErrorOccured = 1





-- Type 2: Duplicates (w.r.t Target table)

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

			,'Data Issue'

			,'0'

			,' Error: Duplicates records , Target table already contain these records for HouseHold Number : ' + isnull(THT.HHNO, '') + ' Period: ' + isnull(THT.Period, '')

			,@ImportDate

			,@JobId

		from DBO.HitList DHT

         INNER JOIN dbo.temphitlist THT  ON DHT.HOUSEHOLD_NUMBER=THT.HHNO AND DHT.PERIOD=THT.PERIOD and jobid=@JobId

		

		IF @@ROWCOUNT > 0

		  SET @IsErrorOccured = 1



-- Type 3:  Numeric Check (within the file)

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

			,'Data Issue'

			,'0'

			,' Error: ELIGCODEs are non-numeric numbers for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from  dbo.temphitlist HT

        WHERE ISNUMERIC(ELIGCODE_1) NOT  LIKE '%[1-9]%' and jobid=@JobId



		UNION



		SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: ELIGCODEs are non-numeric numbers for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from  dbo.temphitlist HT

        WHERE ISNUMERIC(ELIGCODE_2) NOT  LIKE '%[1-9]%' and jobid=@JobId



		UNION



		SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: ELIGCODEs are non-numeric numbers for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from dbo.temphitlist HT

        WHERE ISNUMERIC(ELIGCODE_3) NOT  LIKE '%[1-9]%' and jobid=@JobId

		

		IF @@ROWCOUNT > 0

		  SET @IsErrorOccured = 1





		  -- Type 4:  Numeric Check (within the file)

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

			,'Data Issue'

			,'0'

			,' Error: Spend/PMI codes are non floats for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from  dbo.temphitlist HT

        WHERE ISNUMERIC(REPLACE(SPEND_1,'.',''))=0 and jobid=@JobId



		UNION



		SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: Spend/PMI codes are non floats for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from  dbo.temphitlist HT

 WHERE ISNUMERIC(REPLACE(SPEND_2,'.',''))=0 and jobid=@JobId



		UNION



		SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: Spend/PMI codes are non floats for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from dbo.temphitlist HT

 WHERE ISNUMERIC(REPLACE(SPEND_3,'.',''))=0 and jobid=@JobId

 UNION

 SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: Spend/PMI codes are non floats for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from  dbo.temphitlist HT

        WHERE ISNUMERIC(REPLACE(PMI_1,'.',''))=0 and jobid=@JobId



		UNION



		SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: Spend/PMI codes are non floats for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from  dbo.temphitlist HT

 WHERE ISNUMERIC(REPLACE(PMI_2,'.',''))=0 and jobid=@JobId



		UNION



		SELECT @CountryCode

			,@ImportType

			,@FileName

			,NULL

			,'Data Issue'

			,'0'

			,' Error: Spend/PMI codes are non floats for HouseHold Number : ' + isnull(HT.HHNO, '') + ' Period: ' + isnull(HT.Period, '')

			,@ImportDate

			,@JobId

		from dbo.temphitlist HT

 WHERE ISNUMERIC(REPLACE(PMI_3,'.',''))=0 and jobid=@JobId

		

		IF @@ROWCOUNT > 0

		  SET @IsErrorOccured = 1



		 



	END TRY



	BEGIN CATCH

		PRINT 'VALIDATION ERRROR OCCURED:'



		--ROLLBACK TRANSACTION

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

			,'Unknown'

			,ERROR_NUMBER()

			,ERROR_MESSAGE()

			,@ImportDate

			,@JobId



		PRINT ERROR_MESSAGE();



		UPDATE [FileImportAuditSummary]

		SET [Status] = 'Error'

			,Comments = N'' + ERROR_MESSAGE()

			,PassedRows = @InsertedRows

		WHERE AuditId = @AuditId



		IF @@ROWCOUNT > 0

			SET @IsErrorOccured = 1

	END CATCH



	PRINT 'Is ErrorOccured :'

	PRINT @IsErrorOccured



	-- PERFORM ACTUAL LOGIC

	IF @IsErrorOccured = 0 --  NO ISSUES WITH DATA

	BEGIN

		BEGIN TRY

			PRINT 'PROCESS STARTED'



			-- Create new data

			INSERT INTO dbo.HitList (

				PERIOD

				,HOUSEHOLD_NUMBER

				,[TYPE]

				,REASON

				,SPEND_1

				,SPEND_2

				,SPEND_3

				,HOUSEHOLD_SIZE

				,ELIGCODE_1

				,ELIGCODE_2

				,ELIGCODE_3

				,GPSUser

				,GPSUpdateTimestamp

				,CreationTimeStamp

				,PMI_1

				,PMI_2

				,PMI_3

				)

			SELECT PERIOD,

					HHNO,

					[TYPE],

					REASON,

					SPEND_1,

					SPEND_2,

					SPEND_3,

					HHSIZE,

					ELIGCODE_1,

					ELIGCODE_2,

					ELIGCODE_3,

					@GPSUser,

					@Getdate,

					@Getdate,

					PMI_1,

					PMI_2,

					PMI_3

			FROM dbo.temphitlist AS TEMP where jobid=@JobID

					

			



			SET @InsertedRows = @@ROWCOUNT



			PRINT '@InsertedRows : ' + convert(VARCHAR(10), @InsertedRows)



			UPDATE [FileImportAuditSummary]

			SET [Status] = 'Completed'

				,PassedRows = @InsertedRows

			WHERE AuditId = @AuditId

		END TRY



		BEGIN CATCH

			PRINT 'CRITICAL ERROR OCCURED'



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

				,'Unknown'

				,ERROR_NUMBER()

				,ERROR_MESSAGE()

				,@ImportDate

				,@JobId



			PRINT ERROR_MESSAGE();



			UPDATE [FileImportAuditSummary]

			SET [Status] = 'Error'

				,Comments = substring(N'' + ERROR_MESSAGE(), 1, 400)

				,PassedRows = @InsertedRows

			WHERE AuditId = @AuditId

		END CATCH

	END

	ELSE

	BEGIN

		UPDATE [FileImportAuditSummary]

		SET [Status] = 'Error'

			,Comments = 'Input file has invalid data.'

			,PassedRows = 0

		WHERE AuditId = @AuditId

	END

			-- Results : 

			-- select * from [dbo].[FileImportErrorLog]





	SET @InsertedRows = ISNULL(@InsertedRows,0)


END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH 
END
