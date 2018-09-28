CREATE PROCEDURE [dbo].[ImportPanelistEligibility] (
	@CountryCode AS VARCHAR(3) = ''
	,@PanelCode AS INT = 0
	,@FileName AS VARCHAR(200) =''
	,@InsertUpdate AS VARCHAR(1) = 'I'   -- 'U'
	,@JobId AS VARCHAR(100) = NULL
	,@ImportType VARCHAR(100) = 'PanelistEligibility'  -- 'PanelistWeightingValue'
	,@updatedRows AS BIGINT OUTPUT
	)
/*##########################################################################
	Author	: Suresh P
	Date	: 3-MAR-2015 - Initial Version
	Purpose : File Imported data related to Panelist Eligibility and Weighting value update is available in Temp table.
			  This Procedure validates each column from the Temp table and inserts into Target table PanelistEligibility.
			  *** Applies to Asia countries only.
	Updates: 
	14 Apr 2015: updated Calendar retrival, commented week part, as it is not required for YYYYPP processing.
	1 Apr 2016 : Bug- 38992 : Implemented Update functionality for PanelistEligibility.

	EXECUTE SP:
	  DECLARE @updatedRows BIGINT = 0 
		EXEC [ImportPanelistEligibility]  'TW', 4, 'PanelistEligibility-MP.CSV','I','PanelistEligibility', @updatedRows =0 
##########################################################################*/
AS
BEGIN
BEGIN TRY
	--DECLARE @updatedRows BIGINT = 0 -- 
	--DECLARE @CountryCode AS VARCHAR(2) = 'TW'
	--DECLARE @PanelCode AS INT = 4
	--DECLARE @FileName AS VARCHAR(200) = 'PanelistEligibility-MP.CSV'

	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	DECLARE @GPSUser VARCHAR(20) = 'ImportUser'
	DECLARE @ImportDate DATETIME = @Getdate 
	DECLARE @CountryId AS UNIQUEIDENTIFIER
	DECLARE @IsErrorOccured AS BIT = 0
	DECLARE @PanelGUID AS UNIQUEIDENTIFIER
	DECLARE @PanelistId AS UNIQUEIDENTIFIER
	DECLARE @paneltype AS VARCHAR(20)
	DECLARE @PanelName AS VARCHAR(50)
	DECLARE @AuditId AS BIGINT

	BEGIN TRY

			-- SELECT * FROM [Temp].[PanelistEligibilityImport] TEMP

		DELETE	FROM [Temp].[PanelistEligibilityImport]  
		Where ISNULL(BusinessId,'') ='' and ISNULL(PanelCode,'') =''
		and ISNULL([Year],'')=''  and ISNULL(Period,'')='' 
		and ISNULL(EligibilityReason,'')  = '' and 
		ISNULL(IsEligible,'') = '' and ISNULL(DemographicWeight,0) = 0


		SELECT @CountryId = CountryId
		FROM Country
		WHERE CountryISO2A = @CountryCode

		PRINT 'COUNTRY ID: '
		PRINT @CountryId

		SELECT @PanelGUID = GUIDReference
			,@PanelName = NAME
			,@paneltype = [Type]
		FROM Panel
		WHERE PanelCode = @PanelCode
			AND Country_Id = @CountryId

		PRINT 'PANEL GUID: '
		PRINT @PanelGUID

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
			,@PanelGUID
			,@PanelName
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

		------------------------------------------
		-- Find Panelist
		-------------------------------------------
		DECLARE @PanelistInfo AS TABLE (
			BusinessID VARCHAR(20)
			,PanelistId UNIQUEIDENTIFIER
			)

		-- ,CollaborationMethodology_GUID UNIQUEIDENTIFIER
		IF (@paneltype = 'HouseHold')
		BEGIN
			INSERT INTO @PanelistInfo (
				BusinessID
				,PanelistId
				)
			SELECT DISTINCT TEMP.BusinessId ,V.Panelist
			FROM [Temp].[PanelistEligibilityImport] TEMP
			INNER JOIN (
				SELECT pl.GUIDReference AS Panelist
					,I.IndividualId AS BusinessId
				FROM Panelist pl
				INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
				INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
				WHERE pl.panel_Id = @PanelGUID
					AND pl.Country_Id = @CountryId
				) V ON TEMP.BusinessId = V.BusinessId
		END
		ELSE
		BEGIN
			INSERT INTO @PanelistInfo (
				BusinessID
				,PanelistId
				)
			SELECT DISTINCT TEMP.BusinessId
				,V.Panelist
			FROM [Temp].[PanelistEligibilityImport] TEMP
			INNER JOIN (
				SELECT pl.GUIDReference AS Panelist
					,i.IndividualId AS BusinessId
				FROM Panelist pl
				INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
				WHERE pl.panel_Id = @PanelGUID
					AND pl.Country_Id = @CountryId
				) V ON TEMP.BusinessId = V.BusinessId
		END

		--	select * from @PanelistInfo 
		------------------------------------------
		-- Find Calendar
		-------------------------------------------
		DECLARE @CalendarID AS UNIQUEIDENTIFIER
		DECLARE @YearPeriodTypeId AS UNIQUEIDENTIFIER
		DECLARE @MonthPeriodTypeId AS UNIQUEIDENTIFIER
	--	DECLARE @WeekPeriodTypeId AS UNIQUEIDENTIFIER

		SET @CalendarID = (
				SELECT TOP 1 CalendarID
				FROM PanelCalendarMapping
				WHERE OwnerCountryId = @CountryId
					AND PanelID = @PanelGUID
				ORDER BY CalendarID DESC
				)

		IF (@CalendarID IS NULL)
		BEGIN
			SET @CalendarID = (
					SELECT TOP 1 CalendarID
					FROM CountryCalendarMapping
					WHERE CountryId = @CountryId
						AND CalendarId NOT IN (
							SELECT CalendarID
							FROM PanelCalendarMapping
							WHERE OwnerCountryId = @CountryId
							)
					)
		END

		PRINT 'CalendarID :'
		PRINT @CalendarID

		SELECT @YearPeriodTypeId = CH.ParentPeriodTypeId
			,@MonthPeriodTypeId = CH.ChildPeriodTypeId
		FROM CalendarPeriod Cp
		INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
		WHERE Cp.CalendarId = @CalendarID
			AND CH.SequenceWithinHierarchy IN (1) --AND Cp.PeriodValue = @pYear

		--SELECT @WeekPeriodTypeId = CH.ChildPeriodTypeId
		--FROM CalendarPeriod Cp
		--INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
		--WHERE Cp.CalendarId = @CalendarID
		--	AND CH.SequenceWithinHierarchy IN (2) --AND Cp.PeriodValue = @pYear

		--  select * from CalendarPeriodHierarchy where calendarId = '82CAAD22-9461-4C9F-A599-04A306ECEB85'
		PRINT 'Period :'
		PRINT @YearPeriodTypeId
		PRINT @MonthPeriodTypeId
		--PRINT @WeekPeriodTypeId

		------
		DECLARE @CAL AS TABLE (
			CalPeriod VARCHAR(20)
			,PeriodId UNIQUEIDENTIFIER
			,PeriodValue INT
			,[Year] INT
			,[Period] INT
			--,[Week] INT
			)

		--  StartDate DATETIME,
		--  EndDate DATETIME
		INSERT INTO @CAL (
			CalPeriod
			,PeriodId
			,PeriodValue
			,[Year]
			,Period
		--	,[Week]
			)
		--   StartDate,
		--  EndDate
		SELECT DISTINCT 
			TEMP.Period
			,p.PeriodId
			,p.PeriodValue
			, TEMP.[Year]
			, TEMP.[Period]
		--	,SUBSTRING(Period, 9, 2) AS [Week]
		FROM [Temp].[PanelistEligibilityImport] AS TEMP
		INNER JOIN CalendarPeriod y ON TEMP.[Year] = y.PeriodValue
		INNER JOIN CalendarPeriod p ON (
				p.StartDate BETWEEN y.StartDate AND y.EndDate
				)
			AND (y.CalendarID = p.CalendarId)
			AND p.PeriodValue = TEMP.[Period]
 
		WHERE y.CalendarId = @CalendarID
			AND y.OwnerCountryId = @CountryId
			AND y.PeriodTypeId = @YearPeriodTypeId
			AND p.PeriodTypeId = @MonthPeriodTypeId
		--	AND w.PeriodTypeId = @WeekPeriodTypeId

		--	SELECT *  FROM @CAL
		--------------------------------------
		-- VALIDATIONS  -- ERROR LOG
		--------------------------------------

		-- check if already error exists
		IF EXISTS (SELECT * FROM [dbo].[FileImportErrorLog] 
				WHERE  JobId = @JobId)	
		BEGIN
				UPDATE [dbo].[FileImportErrorLog] 
				SET ErrorDate = @Getdate
				WHERE  JobId = @JobId

			SET @IsErrorOccured = 1
		END

		-- ERROR : 1. Duplicate records (within the file)
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
			,@PanelCode
			,'Data Issue'
			,'0'
			,' Error: Duplicate records in the file for BusinessId : ' + isnull(BusinessId, '') + ' Year: ' + isnull(T.[Year], '') + ' Period: ' + isnull(Period, '')
			,@ImportDate
			,@JobId
		FROM (
			SELECT [BusinessId]
				,[PanelCode]
				,TEMP.[Year]
				,[Period]
				,count(1) cnt
			FROM [Temp].[PanelistEligibilityImport] AS TEMP
			GROUP BY [BusinessId]
				,[PanelCode]
				,[Year]
				,[Period]
			HAVING Count(1) > 1
			) T

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		IF @InsertUpdate = 'I'
		BEGIN
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
				,@PanelCode
				,'Data Issue'
				,'0'
				,' Error: Duplicates records, Target table already contain these records for BusinessId : ' + isnull(BusinessId, '') + ' Year: ' + isnull(TempPE.[Year], '')  + ' Period: ' + isnull(Period, '') + ''''
				,@ImportDate
				,@JobId
			FROM [dbo].[PanelistEligibility] PE
			INNER JOIN (
				SELECT TEMP.BusinessId
					,TEMP.[Year]
					,TEMP.Period
					,PanelistId
					,DemographicWeight
					,@GPSUser AS [GPSUser]
					,@PanelGUID AS Panel_Id
					,@CalendarID AS CalendarPeriod_CalendarId
					,C.PeriodId AS CalendarPeriod_PeriodId
					,@CountryId AS Country_Id
				FROM [Temp].[PanelistEligibilityImport] AS TEMP
				INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
				INNER JOIN @CAL AS C ON C.[Year] = TEMP.[Year]
					AND C.Period = TEMP.[Period]
				) TempPE ON PE.PanelistId = TempPE.PanelistId
				AND PE.Panel_Id = TempPE.Panel_Id
				AND PE.CalendarPeriod_CalendarId = TempPE.CalendarPeriod_CalendarId
				AND PE.CalendarPeriod_PeriodId = TempPE.CalendarPeriod_PeriodId
				AND PE.Country_Id = @CountryId

			IF @@ROWCOUNT > 0
				SET @IsErrorOccured = 1
		END
		ELSE -- @InsertUpdate = 'U' 	
		BEGIN
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
				,@PanelCode
				,'Data Issue'
				,'0'
				,' Error: Target table does not contain BusinessId : ' + isnull(BusinessId, '') + ' Year: ' + isnull(TempPE.[Year], '')  + ' Period: ' + isnull(Period, '')
				,@ImportDate
				,@JobId
			FROM [dbo].[PanelistEligibility] PE
			RIGHT JOIN (
				SELECT TEMP.BusinessId
				,TEMP.[Year]
					,TEMP.Period
					,PanelistId
					,DemographicWeight
					,@GPSUser AS [GPSUser]
					,@PanelGUID AS Panel_Id
					,@CalendarID AS CalendarPeriod_CalendarId
					,C.PeriodId AS CalendarPeriod_PeriodId
					,@CountryId AS Country_Id
				FROM [Temp].[PanelistEligibilityImport] AS TEMP
				INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
				INNER JOIN @CAL AS C ON C.[Year] = TEMP.[Year]
					AND C.Period = TEMP.[Period]
				) TempPE ON PE.PanelistId = TempPE.PanelistId
				AND PE.Panel_Id = TempPE.Panel_Id
				AND PE.CalendarPeriod_CalendarId = TempPE.CalendarPeriod_CalendarId
				AND PE.CalendarPeriod_PeriodId = TempPE.CalendarPeriod_PeriodId
				AND PE.Country_Id = @CountryId
			WHERE PE.PanelistId IS NULL

			IF @@ROWCOUNT > 0
				SET @IsErrorOccured = 1
		END

		----------------------------------
		-- ERROR : 2. INVALID PANELIST
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
			,@PanelCode
			,'BusinessId'
			,'0'
			,'Invalid BusinessID : ' + isnull(BusinessId, '')
			,@ImportDate
			,@JobId
		FROM (
			SELECT DISTINCT TEMP.BusinessId
			FROM [Temp].[PanelistEligibilityImport](NOLOCK) TEMP
			LEFT JOIN (
				SELECT IndividualId AS BusinessId
				FROM Panelist pl
				INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
				INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
				WHERE pl.panel_Id = @PanelGUID
					AND pl.Country_Id = @CountryId
				
				UNION ALL
				
				SELECT i.IndividualId AS BusinessId
				FROM Panelist pl
				INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
				WHERE pl.panel_Id = @PanelGUID
					AND pl.Country_Id = @CountryId
				) tbl ON TEMP.BusinessId = tbl.BusinessId
			WHERE tbl.BusinessId IS NULL
			) V

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		-- ERROR : 3. Calendar errors
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
			,@PanelCode
			,'Calendar'
			,'0'
			,'Invalid Calendar Period for BusinessId: ' + isnull(BusinessId, '') + ' Year: ' + isnull(V.[Year], '')  + ', Period: ' + ISNULL(Period, '')
			,@ImportDate
			,@JobId
		FROM (
			SELECT 
			TEMP.[Year]
			 ,TEMP.[Period]
				,BusinessId
			FROM [Temp].[PanelistEligibilityImport] TEMP
			WHERE  TEMP.[Year] IS NULL OR TEMP.Period IS NULL
			
			UNION ALL
			
			SELECT  TEMP.[Year] 
			,[Period]
				,BusinessId
			FROM [Temp].[PanelistEligibilityImport] TEMP
			WHERE  TEMP.Period > 13
				OR TEMP.Period = 0
			--union all				
			--	select  [Period], BusinessId    FROM [Temp].[PanelistEligibilityImport] Temp
			--	Where SUBSTRING(Period, 9, 2) > 13 or  SUBSTRING(Period, 9, 2)= 0
			
			UNION ALL
			
			SELECT  TEMP.[Year]
			,TEMP.[Period]
				,BusinessId
			FROM [Temp].[PanelistEligibilityImport] TEMP
			WHERE TEMP.[Year] NOT IN (
					SELECT PeriodValue
					FROM CalendarPeriod
					WHERE CalendarId = @CalendarID
						AND PeriodTypeId = @YearPeriodTypeId
						AND OwnerCountryId = @CountryId
					)
			) V

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		-- ERROR : 4. DemographicWeight value Warning...
		-- 4.1.
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
			,@PanelCode
			,'DemographicWeight'
			,'0'
			,'Error: DemographicWeight Value should be numeric for BusinessId: ' + isnull(BusinessId, '') + ' Year: ' + isnull(TEMP.[Year], '')  + ' Period: ' + isnull(Period, '')
			,@ImportDate
			,@JobId
		FROM [Temp].[PanelistEligibilityImport] AS TEMP
		WHERE (
				DemographicWeight IS NULL
				AND ISNUMERIC(DemographicWeight) <> 1
				)

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		-- 4.2 Warning on DemographicWeights
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
			,@PanelCode
			,'DemographicWeight'
			,'0'
			,'Warning: DemographicWeight Value is NULL for BusinessId: ' + isnull(BusinessId, '') + ' Year: ' + isnull(TEMP.[Year], '')  + ' Period: ' + isnull(Period, '')
			,@ImportDate
			,@JobId
		FROM [Temp].[PanelistEligibilityImport] AS TEMP
		WHERE (
				DemographicWeight IS NULL
				OR DemographicWeight = ''
				)

		-- ERROR : 5. is Eligile 
	IF	@ImportType  = 'PanelistEligibility'  --	@InsertUpdate = 'I'
	  BEGIN
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
				,@PanelCode
				,'IsEligible'
				,'0'
				,'Error: IsEligible is not in range for BusinessId: ' + isnull(BusinessId, '') + ' Year: ' + isnull(TEMP.[Year], '')  + ' Period: ' + isnull(Period, '')
				,@ImportDate
				,@JobId
			FROM [Temp].[PanelistEligibilityImport] AS TEMP
			WHERE (
					IsEligible IS NULL
					OR IsEligible NOT IN (
						'0'
						,'1'
						)
					)

			IF @@ROWCOUNT > 0
				SET @IsErrorOccured = 1
		END

		-------------------------------------
		-- EligibilityFailureReason
		------------------------------------
		IF @ImportType   = 'PanelistEligibility' -- @InsertUpdate = 'I'
		BEGIN
			INSERT INTO [EligibilityFailureReason] (
				EligibilityFailureReasonId
				,[Description]
				,Country_Id
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				)
			SELECT NEWID()
				,EligibilityReason
				,@CountryId
				,@GPSUser AS [GPSUser]
				,@ImportDate
				,@ImportDate
			FROM (
				SELECT DISTINCT TEMP.EligibilityReason
				FROM [Temp].[PanelistEligibilityImport] AS TEMP
				WHERE TEMP.EligibilityReason NOT IN (
						SELECT DISTINCT [Description]
						FROM [dbo].[EligibilityFailureReason]
						WHERE Country_Id = @CountryId
						)
				) eligView
		END


		
	---------------------------------------------
	--  validate panel code 
	-----------------------------------------------
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
			,@PanelCode
			,'PanelCode'
			,'0'
			,'Error: Invalid Panel code for BusinessId: ' + isnull(BusinessId, '') 
			+ ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '')  + ' PanelCode:' + isnull(PanelCode, '')
			,@ImportDate
			,@JobId
		FROM [Temp].[PanelistEligibilityImport] AS TEMP
		WHERE (	PanelCode IS NULL OR PanelCode <> @PanelCode)


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
			,@PanelCode
			,'Unknown'
			,ERROR_NUMBER()
			,ERROR_MESSAGE()
			,@ImportDate
			,@JobId

		PRINT ERROR_MESSAGE();

		UPDATE [FileImportAuditSummary]
		SET [Status] = 'Error'
			,Comments = N'' + ERROR_MESSAGE()
			,PassedRows = 0
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

			IF @InsertUpdate = 'U' -- UPDATING [DemographicWeight] for exising BusinessId and Calendar Period. 
			BEGIN
			--	select * FROM [Temp].[PanelistEligibilityImport] AS TEMP 

				IF @ImportType = 'PanelistEligibility'
				BEGIN 
					UPDATE PE
					SET PE.[DemographicWeight] = V.[DemographicWeight]
						,IsEligible = V.IsEligible
						,EligibilityFailureReasonId = V.EligibilityFailureReasonId
						,GPSUSer = @GPSUser
						,[GPSUpdateTimestamp] = @ImportDate
					FROM [PanelistEligibility] PE
					INNER JOIN (
							SELECT TEMP.[DemographicWeight]
								,P.PanelistId
								,C.PeriodId
								,TEMP.IsEligible
								,TEMP.EligibilityReason
								, elgReason.EligibilityFailureReasonId
							FROM [Temp].[PanelistEligibilityImport] AS TEMP
							INNER JOIN @CAL AS C ON C.Period = TEMP.Period -- SUBSTRING(TEMP.Period, CHARINDEX('.', TEMP.Period) + 1, 2)
							AND C.Year = TEMP.[Year]
							INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
							LEFT JOIN EligibilityFailureReason AS elgReason ON elgReason.[Description] = TEMP.EligibilityReason
							AND elgReason.Country_Id = @CountryId
						) V ON PE.PanelistId = V.PanelistId
						AND PE.CalendarPeriod_PeriodId = V.PeriodId
						-- AND ISNULL( PE.[DemographicWeight],0)  <>  ISNULL(V.[DemographicWeight],0)
					WHERE PE.Country_Id = @CountryId
						AND PE.Panel_Id = @PanelGUID
						AND PE.CalendarPeriod_CalendarId = @CalendarID
				END
				ELSE   -- @ImportType = 'PanelistWeightingValue'
				BEGIN 

					UPDATE PE
					SET PE.[DemographicWeight] = V.[DemographicWeight]
						,GPSUSer = @GPSUser
						,[GPSUpdateTimestamp] = @ImportDate
					FROM [PanelistEligibility] PE
					INNER JOIN (
							SELECT TEMP.[DemographicWeight]
								,P.PanelistId
								,C.PeriodId
								,TEMP.IsEligible
								,TEMP.EligibilityReason
								, elgReason.EligibilityFailureReasonId
							FROM [Temp].[PanelistEligibilityImport] AS TEMP
							INNER JOIN @CAL AS C ON C.Period = TEMP.Period -- SUBSTRING(TEMP.Period, CHARINDEX('.', TEMP.Period) + 1, 2)
							AND C.Year = TEMP.[Year]
							INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
							LEFT JOIN EligibilityFailureReason AS elgReason ON elgReason.[Description] = TEMP.EligibilityReason
							AND elgReason.Country_Id = @CountryId
						) V ON PE.PanelistId = V.PanelistId
						AND PE.CalendarPeriod_PeriodId = V.PeriodId
						-- AND ISNULL( PE.[DemographicWeight],0)  <>  ISNULL(V.[DemographicWeight],0)
					WHERE PE.Country_Id = @CountryId
						AND PE.Panel_Id = @PanelGUID
						AND PE.CalendarPeriod_CalendarId = @CalendarID
				END
				SET @UpdatedRows = @@ROWCOUNT 

				UPDATE [FileImportAuditSummary]
				SET [Status] = 'Completed'
					,PassedRows = @updatedRows
				WHERE AuditId = @AuditId


		    END -- U

			IF @InsertUpdate = 'I' --
			BEGIN
				-- Create new data
				INSERT INTO [dbo].[PanelistEligibility] (
					[GUIDReference]
					,[PanelistId]
					,[Panel_Id]
					,[EligibilityFailureReasonId]
					,[IsEligible]
					,[CalendarPeriod_CalendarId]
					,[CalendarPeriod_PeriodId]
					,[Country_Id]
					,[GPSUser]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					,[DemographicWeight]
					)
				SELECT NEWID() [GUIDReference]
					,P.PanelistId
					,@PanelGUID
					,elgReason.EligibilityFailureReasonId AS [EligibilityFailureReasonId]
					,IsEligible AS IsEligible
					,@CalendarID
					,C.PeriodId
					,@CountryId
					,@GPSUser AS [GPSUser]
					,@ImportDate
					,@ImportDate
					,[DemographicWeight]
				FROM [Temp].[PanelistEligibilityImport] AS TEMP
				INNER JOIN @CAL AS C ON C.Period = TEMP.PEriod -- SUBSTRING(TEMP.Period, CHARINDEX('.', TEMP.Period) + 1, 2)
					AND C.Year = TEMP.[Year]
				INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
				LEFT JOIN EligibilityFailureReason AS elgReason ON elgReason.[Description] = TEMP.EligibilityReason
					AND elgReason.Country_Id = @CountryId
				WHERE NOT EXISTS (
						SELECT 1
						FROM [dbo].[PanelistEligibility]
						WHERE Panel_Id = @PanelGUID
							AND CalendarPeriod_CalendarId = @CalendarID
							AND CalendarPeriod_PeriodId = C.PeriodId
							AND Country_Id = @CountryId
							AND PanelistId = P.PanelistId
						)

				SET @updatedRows = @@ROWCOUNT

				PRINT '@updatedRows : ' + convert(VARCHAR(10), @updatedRows)

				UPDATE [FileImportAuditSummary]
				SET [Status] = 'Completed'
					,PassedRows = @updatedRows
				WHERE AuditId = @AuditId
			END -- I

		END TRY

		BEGIN CATCH
			PRINT 'CRITICAL ERRORS OCCURED'

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
				,@PanelCode
				,'Unknown'
				,ERROR_NUMBER()
				,ERROR_MESSAGE()
				,@ImportDate
				,@JobId

			PRINT ERROR_MESSAGE();

			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
				,Comments = 'CRITICAL ERRORS OCCURED - Please check the Template format and error logs.'
				,PassedRows = 0
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

		SELECT @AuditId
	END
			-- Results : 
			-- select * from [dbo].[FileImportErrorLog]
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
GO