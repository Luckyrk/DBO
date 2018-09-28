CREATE PROCEDURE [dbo].[ImportPSCForUpdate] (
	 @CountryCode AS VARCHAR(3) = ''
	,@PanelCode AS INT = 0
	,@FileName AS VARCHAR(200)
	,@JobId AS VARCHAR(200)
	,@ImportType AS VARCHAR(100) = 'PurchaseSummaryCounts'
	,@updatedRows AS BIGINT OUTPUT
	)
	/*##########################################################################
Author	: Suresh P
Date	: 25-FEB-2015 - Initial Version
Purpose : File Imported data related to Purchase summary counts is available in Temp table.
		  This Procedure validated each column from the Temp table and update the Target table.
Updates: 
		21/05/2015: Added @Category_MonthlyReceive ,@Category_MonthlyPurchase
					CollaborationMethodology_Id check has been removed.
		20/01/2016: Added Category - @Category_PONDALI for Spain.
		25/07/2016: Updated SP related change to table [Temp].[PurchaseSummaryCountsImport] and added Panel code validation
		08/08/2016: PBI 41349 related changes
		4/7/2017  : PBI 44116 - colloboration Methodology implementation.
EXECUTE SP:
  DECLARE @updatedRows BIGINT = 0 
	EXEC [ImportPSCForUpdate]  'TW', 4, 'COMPST-MP.CSV','PurchaseSummaryCounts',@updatedRows =0 
##########################################################################*/
AS
BEGIN
BEGIN TRY
	
	DECLARE @Category_COMALI VARCHAR(20) = 'S_COMALI'
	DECLARE @Category_COMPERF VARCHAR(20) = 'S_COMPERF'
	DECLARE @Category_DPE VARCHAR(20) = 'P_DPEALI'
	DECLARE @Category_DPR VARCHAR(20) = 'P_DPRALI'
	DECLARE @Category_MonthlyReceive VARCHAR(20) = 'Monthly_R'
	DECLARE @Category_MonthlyPurchase VARCHAR(20) = 'Monthly_P'
	DECLARE @Category_DayCount VARCHAR(20) = 'DayCount'
	DECLARE @Category_PONDALI VARCHAR(20) = 'P_PONDALI'
	
	DECLARE @Getdate DATETIME		
     SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	DECLARE @GPSUser VARCHAR(20) = 'ImportUser'
	DECLARE @ImportDate DATETIME = @Getdate
	--DECLARE @ImportType VARCHAR(100)  = 'PurchaseSummaryCounts'
	DECLARE @CountryId AS UNIQUEIDENTIFIER
	DECLARE @IsErrorOccured AS BIT = 0
	DECLARE @PanelGUID AS UNIQUEIDENTIFIER
	DECLARE @PanelistId AS UNIQUEIDENTIFIER
	DECLARE @paneltype AS VARCHAR(20)
	DECLARE @PanelName AS VARCHAR(50)
	DECLARE @AuditId AS BIGINT

	BEGIN TRY
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

		-- remove dummy rows
		DELETE [SSIS].[PurchaseSummaryCountsImport]
		Where ISNULL(BusinessId,'') =''
		and  ISNULL(PanelCode,'') =''
		and  ISNULL(Category,'') =''
		and  ISNULL(SummaryCount,'') =''
		and  LEN(Period)<8
		AND ISNULL(CollaborationMethodology,'')=''


		PRINT 'PANEL GUID: '
		PRINT @PanelGUID

		DECLARE @TotalRows BIGINT = (select count(*) from [SSIS].[PurchaseSummaryCountsImport] WHERE CountryCode=@CountryCode)
		
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
			,@TotalRows
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
			,CollaborationMethodology_GUID UNIQUEIDENTIFIER
			)

		IF (@paneltype = 'HouseHold')
		BEGIN
			INSERT INTO @PanelistInfo (
				BusinessID
				,PanelistId
				,CollaborationMethodology_GUID
				)
			SELECT DISTINCT TEMP.BusinessId
				,V.Panelist
				,V.CollaborationMethodology_Id
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			INNER JOIN (
				SELECT pl.GUIDReference AS Panelist
					,I.IndividualId AS BusinessId
					,pl.CollaborationMethodology_Id
				FROM Panelist pl
				INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
				INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
				WHERE pl.panel_Id = @PanelGUID
					AND pl.Country_Id = @CountryId
				) V ON TEMP.BusinessId = V.BusinessId
			WHERE TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
				)
				AND TEMP.CountryCode=@CountryCode
		END
		ELSE
		BEGIN
			INSERT INTO @PanelistInfo (
				BusinessID
				,PanelistId
				,CollaborationMethodology_GUID
				)
			SELECT DISTINCT TEMP.BusinessId
				,V.Panelist
				,V.CollaborationMethodology_Id 
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			INNER JOIN (
				SELECT pl.GUIDReference AS Panelist
					,i.IndividualId AS BusinessId
					,pl.CollaborationMethodology_Id
				FROM Panelist pl
				INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
				WHERE pl.panel_Id = @PanelGUID
					AND pl.Country_Id = @CountryId
				) V ON TEMP.BusinessId = V.BusinessId
			WHERE TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
					)
					 AND TEMP.CountryCode=@CountryCode
		END

		--	select * from @PanelistInfo 
		------------------------------------------
		-- Find Calendar
		-------------------------------------------
		DECLARE @CalendarID AS UNIQUEIDENTIFIER
		DECLARE @YearPeriodTypeId AS UNIQUEIDENTIFIER
		DECLARE @MonthPeriodTypeId AS UNIQUEIDENTIFIER
		DECLARE @WeekPeriodTypeId AS UNIQUEIDENTIFIER

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

		SELECT @WeekPeriodTypeId = CH.ChildPeriodTypeId
		FROM CalendarPeriod Cp
		INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
		WHERE Cp.CalendarId = @CalendarID
			AND CH.SequenceWithinHierarchy IN (2) --AND Cp.PeriodValue = @pYear

		--  select * from CalendarPeriodHierarchy where calendarId = '82CAAD22-9461-4C9F-A599-04A306ECEB85'
		PRINT 'Period :'
		PRINT @YearPeriodTypeId
		PRINT @MonthPeriodTypeId
		PRINT @WeekPeriodTypeId

		------
		DECLARE @CAL AS TABLE (
			CalPeriod VARCHAR(20)
			,PeriodId UNIQUEIDENTIFIER
			,PeriodValue INT
			,[Year] INT
			,[Period] INT
			,[Week] INT
			)

		--  StartDate DATETIME,
		--  EndDate DATETIME
		INSERT INTO @CAL (
			CalPeriod
			,PeriodId
			,PeriodValue
			,[Year]
			,Period
			,[Week]
			)
		SELECT DISTINCT TEMP.[Year] + '.' + TEMP.[Period] + '.' + TEMP.[Week]
			,w.PeriodId
			,w.PeriodValue
			,TEMP.[Year] 
			,TEMP.[Period]
			,TEMP.[Week]
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		INNER JOIN CalendarPeriod y ON TEMP.[Year] = y.PeriodValue
		INNER JOIN CalendarPeriod p ON (
				p.StartDate BETWEEN y.StartDate
					AND y.EndDate
				)
			AND (y.CalendarID = p.CalendarId)
			AND p.PeriodValue = (
				CASE 
					WHEN TEMP.[Period] = 0
						THEN '01'
					ELSE TEMP.[Period]
					END
				)
		INNER JOIN CalendarPeriod w ON (
				w.StartDate BETWEEN p.StartDate
					AND p.EndDate
				)
			AND (w.CalendarID = p.CalendarId)
			AND w.PeriodValue = (
				CASE 
					WHEN TEMP.[Week] = 0
						THEN '01'
					ELSE TEMP.[Week]
					END
				)
		WHERE TEMP.[Category] IN (
				-- SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
				-- WHERE Country_Id = @CountryId  AND ISNULL(Code,'') NOT IN ('', @Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR)
				--	@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR
					@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI
				)   
			AND y.CalendarId = @CalendarID
			AND y.OwnerCountryId = @CountryId
			AND y.PeriodTypeId = @YearPeriodTypeId
			AND p.PeriodTypeId = @MonthPeriodTypeId
			AND w.PeriodTypeId = @WeekPeriodTypeId
			AND TEMP.CountryCode=@CountryCode

		INSERT INTO @CAL (
			CalPeriod
			,PeriodId
			,PeriodValue
			,[Year]
			,Period
			)
		SELECT DISTINCT TEMP.[Year] + '.' + TEMP.[Period] + '.' + '00'
			,p.PeriodId
			,p.PeriodValue
			,TEMP.[Year] AS [Year]
			,TEMP.[Period] AS [Period]
		--  ,SUBSTRING(Period, 9 , 2) AS [Week]
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		INNER JOIN CalendarPeriod y ON TEMP.[Year] = y.PeriodValue
		INNER JOIN CalendarPeriod p ON (
				p.StartDate BETWEEN y.StartDate
					AND y.EndDate
				)
			AND (y.CalendarID = p.CalendarId)
			AND p.PeriodValue = (
				CASE 
					WHEN TEMP.[Period] = 0
						THEN '01'
					ELSE TEMP.[Period]
					END
				)
		--AND (TEMP.[Week]<>'00' or TEMP.[Week]<0)
		WHERE TEMP.[Category] IN (
				SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category WHERE Country_Id = @CountryId
				AND ISNULL(Code,'')  NOT IN ('', @Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI)
				--	@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR
				--	@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI
				)  
			AND y.CalendarId = @CalendarID
			AND y.OwnerCountryId = @CountryId
			AND y.PeriodTypeId = @YearPeriodTypeId
			AND p.PeriodTypeId = @MonthPeriodTypeId
			AND  TEMP.CountryCode = @CountryCode
		--	SELECT *  FROM @CAL
		--------------------------------------
		-- VALIDATIONS  -- ERROR LOG
		--------------------------------------
		-- ERROR : 0. Validating Categories
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
			,'Category'
			,'0'
			,' Error: invalid category in the file for BusinessId : ' + isnull(BusinessId, '') 
			+ ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(TEMP.[Category], '')
			,@ImportDate
			,@JobId
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		WHERE TEMP.[Category] NOT IN (
				SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
				)
		AND  TEMP.CountryCode = @CountryCode

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

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
			,'Duplicate records'
			,'0'
			,' Error: Duplicate records in the file for BusinessId : ' + isnull(BusinessId, '')
			+ ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull([Category], '')
			,@ImportDate
			,@JobId
		FROM (
			SELECT [BusinessId]
				,[PanelCode]
				,[Year],[Period],[Week]
				,[Category]
				,count(1) cnt
			FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
			WHERE TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
					) 
			AND  TEMP.CountryCode = @CountryCode 
			GROUP BY [BusinessId]
				,[PanelCode]
				,[Year],[Period],[Week]
				,[Category]
			HAVING Count(1) > 1
			) T

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		-------
		-- Type 2: Find Row exists (w.r.t Target table)
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
			,' Error: Cannot update file data, Record does not exist in target table for BusinessId : ' + isnull(BusinessId, '') + ' , Period: ' + isnull(Period, '') + ' , Category: ' + isnull([Category], '')
			,@ImportDate
			,@JobId
		FROM [dbo].[PanelistSummaryCount] PSC
		RIGHT JOIN (
			SELECT TEMP.BusinessId
				,TEMP.Period
				,P.PanelistId
				,SummaryCategoryId
				,TEMP.[Category]
				,SummaryCount
				,@GPSUser AS [GPSUser]
				,@PanelGUID AS Panel_Id
				,@CalendarID AS CalendarPeriod_CalendarId
				,C.PeriodId AS CalendarPeriod_PeriodId
				,@CountryId AS Country_Id
				,CollaborationMethodology_GUID AS CollaborationMethodology_Id
			FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
			INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
			INNER JOIN @CAL AS C ON C.[Year] = TEMP.[Year]
				AND C.Period = TEMP.[Period]
				AND C.[Week] = TEMP.[Week]
			INNER JOIN Summary_Category Catg ON Catg.Code = [Category]
				AND Country_Id = @CountryId
			WHERE TEMP.[Category] IN (
				--	SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category WHERE Country_Id = @CountryId
				--	AND ISNULL(Code,'')  NOT IN ('', @Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR)
				--	@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR
					@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI
					) 
             AND  TEMP.CountryCode = @CountryCode
			) TempPSC ON PSC.PanelistId = TempPSC.PanelistId
			AND PSC.Panel_Id = TempPSC.Panel_Id
			AND PSC.CalendarPeriod_CalendarId = TempPSC.CalendarPeriod_CalendarId
			AND PSC.CalendarPeriod_PeriodId = TempPSC.CalendarPeriod_PeriodId
			AND PSC.SummaryCategoryId = TempPSC.SummaryCategoryId
			--AND PSC.CollaborationMethodology_Id = TempPSC.CollaborationMethodology_Id
			AND PSC.Country_Id = @CountryId
		WHERE PSC.PanelistId IS NULL
		
		UNION ALL
		
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,@PanelCode
			,'Data Issue'
			,'0'
			,' Error: Cannot update file data, Record does not exist in target table for BusinessId : ' + isnull(BusinessId, '') + ' , Period: ' + isnull(Period, '') + ' , Category : ' + isnull([Category], '')
			,@ImportDate
			,@JobId
		FROM [dbo].[PanelistSummaryCount] PSC
		RIGHT JOIN (
			SELECT TEMP.BusinessId
				,TEMP.Period
				,P.PanelistId
				,SummaryCategoryId
				,TEMP.[Category]
				,SummaryCount
				,@GPSUser AS [GPSUser]
				,@PanelGUID AS Panel_Id
				,@CalendarID AS CalendarPeriod_CalendarId
				,C.PeriodId AS CalendarPeriod_PeriodId
				,@CountryId AS Country_Id
				,CollaborationMethodology_GUID AS CollaborationMethodology_Id
			FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
			INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
			INNER JOIN @CAL AS C ON C.[Year] = TEMP.[Year]
				AND C.Period = TEMP.[Period]
				AND C.[Week] IS NULL
			INNER JOIN Summary_Category Catg ON Catg.Code = [Category]
				AND Country_Id = @CountryId
			WHERE TEMP.[Category] IN (
				 SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category WHERE Country_Id = @CountryId
					AND ISNULL(Code,'')  NOT IN ('', @Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI)
				--	@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR
				--	@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI
					)
					AND  TEMP.CountryCode = @CountryCode  
			) TempPSC ON PSC.PanelistId = TempPSC.PanelistId
			AND PSC.Panel_Id = TempPSC.Panel_Id
			AND PSC.CalendarPeriod_CalendarId = TempPSC.CalendarPeriod_CalendarId
			AND PSC.CalendarPeriod_PeriodId = TempPSC.CalendarPeriod_PeriodId
			AND PSC.SummaryCategoryId = TempPSC.SummaryCategoryId
			--AND PSC.CollaborationMethodology_Id = TempPSC.CollaborationMethodology_Id
			AND PSC.Country_Id = @CountryId
		WHERE PSC.PanelistId IS NULL
		
		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

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
			,'Invalid BusinessID : ' + isnull(BusinessId, '') + ' for: ' + isnull(V.[Category], '')
			,@ImportDate
			,@JobId
		FROM (
			SELECT DISTINCT TEMP.BusinessId
				,TEMP.[Category]
			FROM [SSIS].[PurchaseSummaryCountsImport](NOLOCK) TEMP
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
			WHERE TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
					)
				AND tbl.BusinessId IS NULL
				AND  TEMP.CountryCode = @CountryCode
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
			,'Invalid Calendar Period for BusinessId: ' + isnull(BusinessId, '')  + ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(Category, '')
			,@ImportDate
			,@JobId
		FROM (
			--period (@Category_COMALI, @Category_COMPERF,@Category_DPE,@Category_DPR,,@Category_DayCount)
			SELECT [Year], [Period],[Week]
				,BusinessId
				,TEMP.[Category]
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			WHERE (TEMP.[Year] IS NULL OR  TEMP.[Year] = ''  OR TEMP.[Year]= 0)
				AND TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
					)
			AND  TEMP.CountryCode = @CountryCode
			UNION ALL -- period
						
			SELECT [Year], [Period],[Week]
				,BusinessId
				,TEMP.[Category]
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			WHERE (
					TEMP.[Period] > 13
					OR TEMP.[Period] <= 0
					)
				AND TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
					)
			AND  TEMP.CountryCode = @CountryCode
			UNION ALL -- week	***	
			
			SELECT [Year], [Period],[Week]
				,BusinessId
				,TEMP.[Category]
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			WHERE (
					TEMP.[Week] > 5
					OR TEMP.[Week] <= 0
					OR TEMP.[Week] = ''
					OR TEMP.[Week] = '00'
					)
				AND TEMP.[Category] IN (
					--SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					--WHERE Country_Id = @CountryId  AND ISNULL(Code,'') NOT IN ('',
					--@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR)
					@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI
					
					)
				AND  TEMP.CountryCode = @CountryCode
			 
			UNION ALL -- Year
			
			SELECT [Year], [Period],[Week]
				,BusinessId
				,TEMP.[Category]
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			WHERE TEMP.[Year] NOT IN (
					SELECT PeriodValue
					FROM CalendarPeriod
					WHERE CalendarId = @CalendarID
						AND PeriodTypeId = @YearPeriodTypeId
						AND OwnerCountryId = @CountryId
					)
				AND TEMP.[Year] > Year(getdate())
				AND TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
					)
               AND  TEMP.CountryCode = @CountryCode
			) V


		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		-- ERROR : 4. SummaryCount value error...
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
			,'SummaryCount'
			,'0'
			,'Error: Summary Count Value should be numeric for BusinessId: ' + isnull(BusinessId, '')+ ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(Category, '')
			,@ImportDate
			,@JobId
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		WHERE (
				SummaryCount IS NULL
				AND ISNUMERIC(SummaryCount) <> 1
				)
			AND TEMP.[Category] IN (
				SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
				)
				AND  TEMP.CountryCode = @CountryCode
		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		-- 4.2 Warning on SummaryCounts
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
			,'SummaryCount'
			,'0'
			,'Warning: Summary Count Value is NULL for BusinessId: ' + isnull(BusinessId, '') + ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(Category, '')
			,@ImportDate
			,@JobId
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		WHERE (
				SummaryCount IS NULL
				OR SummaryCount = ''
				)
			AND TEMP.[Category] IN (
				SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')<>''
				)
				AND  TEMP.CountryCode = @CountryCode
		-- 4.3 calendar period warning
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
			,'Warning: Calendar Week is not required for the selected category. BusinessId: ' + isnull(BusinessId, '')  + 
			', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(Category, '')
			,@ImportDate
			,@JobId
		FROM (
		SELECT [Year], [Period],[Week]
				,BusinessId
				,TEMP.[Category]
			FROM [SSIS].[PurchaseSummaryCountsImport] TEMP
			WHERE (
					TEMP.[Week] IS NOT NULL
					AND TEMP.[Week] <> ''
					AND TEMP.[Week] <> '00'
					)
				AND TEMP.[Category] IN (
					SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'') NOT IN ('',
					--@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR)
					@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI)
				) 
				AND  TEMP.CountryCode = @CountryCode 
	)v1

	-- 5. validate panel code 
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
			+ ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(Category, '')  + ' PanelCode:' + isnull(PanelCode, '')
			,@ImportDate
			,@JobId
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		WHERE (	PanelCode IS NULL OR PanelCode <> @PanelCode)
		AND  TEMP.CountryCode = @CountryCode

	IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

			
	-- 6. Validate Collaboration Methodology Code
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
			,'Category'
			,'0'
			,' Error: invalid CollaborationMethodology in the file for BusinessId : ' + isnull(BusinessId, '') 
			+ ', Year: ' + isnull([Year], '')  + ', Period: ' + isnull(Period, '') + ', Week: ' + isnull([Week], '') + ' Category:' + isnull(TEMP.[Category], '')
			,@ImportDate
			,@JobId
		FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
		WHERE  rtrim(ISNULL(CollaborationMethodology, '')) <> '' 
		AND TEMP.CollaborationMethodology NOT IN (
						SELECT LTRIM(RTRIM(Code)) CollabCode 
						FROM CollaborationMethodology CM 
						JOIN Country C ON C.CountryId = CM.Country_Id 
						WHERE CountryISO2A = @CountryCode 
						AND ISNULL(Code,'')<>''
				) 
		AND  TEMP.CountryCode = @CountryCode


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
			,PassedRows = @updatedRows
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
			-- Update new data
			UPDATE PSC
			SET PSC.SummaryCount = TempPSC.SummaryCount
				,PSC.GPSUpdateTimestamp = @ImportDate
				,PSC.GPSUser = @GPSUser
				,PSC.CollaborationMethodology_Id = TempPSC.CollaborationMethodology_Id
			FROM [dbo].[PanelistSummaryCount] PSC
			INNER JOIN (
				SELECT P.PanelistId
					,SummaryCategoryId
					,SummaryCount
					,@GPSUser AS [GPSUser]
					,@PanelGUID AS Panel_Id
					,@CalendarID AS CalendarPeriod_CalendarId
					,C.PeriodId AS CalendarPeriod_PeriodId
					,@CountryId AS Country_Id
					,(CASE WHEN ISNULL(CM.Code,'') <> ''  THEN  CM.GUIDReference ELSE P.CollaborationMethodology_GUID END) as CollaborationMethodology_Id
				FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
				INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
				INNER JOIN @CAL AS C ON C.[Week] IS NOT NULL
					AND C.[Year] = TEMP.[Year]
					AND C.Period = TEMP.[Period]
					AND C.[Week] = TEMP.[Week]
				INNER JOIN Summary_Category Catg ON Catg.Code  IS NOT NULL AND Catg.Code = [Category] AND Catg.Country_Id = @CountryId
				LEFT JOIN CollaborationMethodology CM ON  CM.Country_Id = @CountryId AND LTRIM(RTRIM(CM.Code)) = TEMP.CollaborationMethodology
				WHERE TEMP.[Category] IN (
					--SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					--WHERE Country_Id = @CountryId  AND ISNULL(Code,'') NOT IN ('',
					--@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR)
					 @Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI
						) 
						AND  TEMP.CountryCode = @CountryCode
				) TempPSC ON PSC.PanelistId = TempPSC.PanelistId
				AND PSC.Panel_Id = TempPSC.Panel_Id
				AND PSC.CalendarPeriod_CalendarId = TempPSC.CalendarPeriod_CalendarId
				AND PSC.CalendarPeriod_PeriodId = TempPSC.CalendarPeriod_PeriodId
				AND PSC.SummaryCategoryId = TempPSC.SummaryCategoryId
				--AND PSC.CollaborationMethodology_Id = TempPSC.CollaborationMethodology_Id
				AND PSC.Country_Id = @CountryId

			SET @updatedRows = @@ROWCOUNT

			UPDATE PSC
			SET PSC.SummaryCount = TempPSC.SummaryCount
				,PSC.GPSUpdateTimestamp = @ImportDate
				,PSC.GPSUser = @GPSUser
				,PSC.CollaborationMethodology_Id = TempPSC.CollaborationMethodology_Id
			FROM [dbo].[PanelistSummaryCount] PSC
			INNER JOIN (
				SELECT P.PanelistId
					,SummaryCategoryId
					,SummaryCount
					,@GPSUser AS [GPSUser]
					,@PanelGUID AS Panel_Id
					,@CalendarID AS CalendarPeriod_CalendarId
					,C.PeriodId AS CalendarPeriod_PeriodId
					,@CountryId AS Country_Id
					,(CASE WHEN ISNULL(CM.Code,'') <> ''  THEN  CM.GUIDReference ELSE P.CollaborationMethodology_GUID END) as CollaborationMethodology_Id
				FROM [SSIS].[PurchaseSummaryCountsImport] AS TEMP
				INNER JOIN @PanelistInfo AS P ON P.BusinessId = TEMP.BusinessId
				INNER JOIN @CAL AS C ON C.[Year] = TEMP.[Year]
					AND C.Period = TEMP.[Period]
					AND C.Week IS NULL
				INNER JOIN Summary_Category Catg ON Catg.Code  IS NOT NULL AND Catg.Code = [Category] AND Catg.Country_Id = @CountryId
				LEFT JOIN CollaborationMethodology CM ON  CM.Country_Id = @CountryId AND LTRIM(RTRIM(CM.Code)) = TEMP.CollaborationMethodology
				WHERE TEMP.[Category] IN (
						SELECT LTRIM(RTRIM(Code)) as CategoryCode FROM Summary_Category 
					WHERE Country_Id = @CountryId  AND ISNULL(Code,'')  NOT IN ('',
					--@Category_DPE, @Category_DPR, @Category_MonthlyReceive, @Category_DPR
					@Category_COMALI, @Category_COMPERF, @Category_DayCount, @Category_PONDALI )
						)  
						AND  TEMP.CountryCode = @CountryCode
				) TempPSC ON PSC.PanelistId = TempPSC.PanelistId
				AND PSC.Panel_Id = TempPSC.Panel_Id
				AND PSC.CalendarPeriod_CalendarId = TempPSC.CalendarPeriod_CalendarId
				AND PSC.CalendarPeriod_PeriodId = TempPSC.CalendarPeriod_PeriodId
				AND PSC.SummaryCategoryId = TempPSC.SummaryCategoryId
				--AND PSC.CollaborationMethodology_Id = TempPSC.CollaborationMethodology_Id
				AND PSC.Country_Id = @CountryId

			SET @updatedRows = @updatedRows + @@ROWCOUNT

			PRINT '@updatedRows : ' + convert(VARCHAR(10), @updatedRows)

			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Completed'
				,PassedRows = @updatedRows
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
				,@PanelCode
				,'Unknown'
				,ERROR_NUMBER()
				,ERROR_MESSAGE()
				,@ImportDate
				,@JobId

			PRINT ERROR_MESSAGE();

			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
				,Comments = substring(N'' + ERROR_MESSAGE(), 1, 400)
				,PassedRows = @updatedRows
				,TotalRows = @updatedRows
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

	SELECT @updatedRows
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