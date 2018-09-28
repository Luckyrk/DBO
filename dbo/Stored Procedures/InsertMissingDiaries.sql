GO
--EXEC [InsertMissingDiaries] 2015,5,3,'195aa409-50bb-4078-86e4-b846757e1faa','bfd50c3c-83ea-4251-8e34-32b591dd43c1','TestUserTW1','3558a18e-cceb-cadc-cb8c-08cf81794a86',2057,'PD'
CREATE PROCEDURE [dbo].[InsertMissingDiaries] (
	@pTargetYear INT
	,@pTargetPeriod INT
	,@pTargetWeek INT
	,@pPanelId UNIQUEIDENTIFIER
	,@pCalendarId UNIQUEIDENTIFIER
	,@pUsername VARCHAR(30)
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pDiaryTypeCode NVARCHAR(10)
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @ReasonTypeId UNIQUEIDENTIFIER

		EXEC GetCommunicationReasonTypeId @pCountryId
			,@pUsername
			,@pCommunicationReasonTypeId = @ReasonTypeId OUTPUT

		DECLARE @PanelName NVARCHAR(100)
			,@ContactMechanismId UNIQUEIDENTIFIER
			,@DiaryTypeDesc NVARCHAR(100)

		SET @DiaryTypeDesc = (SELECT TOP 1 dbo.GetTranslationValue(TranslationId,2057)  
								FROM CollaborationMethodology 
								WHERE Country_Id= @pCountryId AND Code = @pDiaryTypeCode)

		DECLARE @Getdate DATETIME
		SET @Getdate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
		CREATE TABLE #Calnder_temp (
			RowNum INT identity(1, 1)
			,DiaryYear VARCHAR(20) COLLATE DATABASE_DEFAULT
			,DiaryPeriod VARCHAR(20) COLLATE DATABASE_DEFAULT
			,DiaryWeek VARCHAR(30) COLLATE DATABASE_DEFAULT
			)

		INSERT INTO #Calnder_temp
		EXEC GetCalendarYearPeriodWeekRecords @pCountryId
			,@pPanelId

		SELECT @PanelName = NAME
		FROM Panel
		WHERE GUIDReference = @pPanelId

		SELECT @ContactMechanismId = GUIDReference
		FROM ContactMechanismType
		WHERE Country_Id = @pCountryId
			AND Types = 'EMail'

		DECLARE @tempTranslation TABLE (TranslationValue NVARCHAR(50))

		INSERT INTO @tempTranslation
		SELECT TT.Value
		FROM Translation T
		INNER JOIN TranslationTerm TT ON T.TranslationId = TT.Translation_Id
		WHERE T.KeyName IN (
				'PanelistInterestedState'
				,'PanelistLiveState'
				,'PanelistPreLiveState'
				)
			AND TT.CultureCode = @pCultureCode

		CREATE TABLE #PanelistTemp (
			BusinessId NVARCHAR(100) COLLATE DATABASE_DEFAULT
			,PanelistState NVARCHAR(20) COLLATE DATABASE_DEFAULT
			,CreationDate DATETIME
			,CandidateId UNIQUEIDENTIFIER
			,DiaryPeriodWeek VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
			,Diaryyear INT NULL
			,DiaryPeriod INT NULL
			,DiaryWeek INT NULL
			,MatchedRecord BIT DEFAULT 0
			,isHousehold BIT NULL -- This is the dummy column. We are not using any where below. We have added this because  the procedure "GetAvailablePanelists" returning this column.
			,KeyName NVARCHAR(1000) NULL -- This is the dummy column. We are not using any where below. We have added this because  the procedure "GetAvailablePanelists" returning this column.
			,DiaryTypeCode NVARCHAR(10)
			)

		INSERT INTO #PanelistTemp (
			BusinessId
			,PanelistState
			,isHousehold
			,CreationDate
			,CandidateId
			,KeyName
			,DiaryTypeCode
			)
		EXEC GetAvailablePanelists @pCultureCode
			,@pPanelId
			,@pCountryId

		DELETE
		FROM #PanelistTemp
		WHERE DiaryTypeCode <> @pDiaryTypeCode

		DELETE
		FROM #PanelistTemp
		WHERE PanelistState NOT IN (
				SELECT TranslationValue
				FROM @tempTranslation
				)

		DELETE m
		FROM #PanelistTemp m
		WHERE EXISTS (
				SELECT DISTINCT businessid
				FROM DiaryEntry d
				WHERE d.BusinessId = m.BusinessId
					AND d.DiaryDateYear = @pTargetYear
					AND d.DiaryDatePeriod = @pTargetPeriod
					AND d.DiaryDateWeek = @pTargetWeek
					AND d.PanelId = @pPanelId
				)

		UPDATE PT
		SET PT.MatchedRecord = 1
			,PT.DiaryYear = ss.DiaryDateYear
			,PT.DiaryPeriod = ss.DiaryDatePeriod
			,PT.DiaryWeek = ss.DiaryDateWeek
		FROM (
			SELECT *
				,ROW_NUMBER() OVER (
					PARTITION BY BusinessId ORDER BY DiaryDateYear DESC
						,DiaryDatePeriod DESC
						,DiaryDateWeek DESC
					) AS RNO
			FROM (
				SELECT DE.BusinessId
					,DE.DiaryDateYear
					,DE.DiaryDatePeriod
					,DE.DiaryDateWeek
					,TEMP.CandidateId
				FROM DiaryEntry DE
				INNER JOIN #PanelistTemp TEMP ON TEMP.BusinessId = DE.BusinessId
				WHERE DE.PanelId = @pPanelId
					--AND DE.DiarySourceFull = @DiaryTypeDesc
					AND (
						de.DiaryDateYear < @pTargetYear
						OR (
							de.DiaryDateYear = @pTargetYear
							AND de.DiaryDatePeriod < @pTargetPeriod
							)
						OR (
							de.DiaryDateYear = @pTargetYear
							AND de.DiaryDatePeriod = @pTargetPeriod
							AND de.DiaryDateWeek < @pTargetWeek
							)
						)
				) ss1
			) ss
		INNER JOIN #PanelistTemp PT ON PT.BusinessId = ss.BusinessId
		WHERE RNO = 1

		UPDATE #PanelistTemp
		SET DiaryPeriodWeek = dbo.[GetDiaryPeriodWeekBYDate](CreationDate, @pCalendarId)
		WHERE MatchedRecord = 0

		UPDATE #PanelistTemp
		SET DiaryYear = (
				SELECT items
				FROM SPLIT(DiaryPeriodWeek, '.')
				WHERE id = 1
				)
			,DiaryPeriod = (
				SELECT items
				FROM SPLIT(DiaryPeriodWeek, '.')
				WHERE id = 2
				)
			,DiaryWeek = (
				SELECT items
				FROM SPLIT(DiaryPeriodWeek, '.')
				WHERE id = 3
				)
		WHERE MatchedRecord = 0

		CREATE TABLE #finalResult (
			Id UNIQUEIDENTIFIER
			,BusinessId VARCHAR(20) COLLATE DATABASE_DEFAULT
			,DiaryDateYear INT
			,DiaryDatePeriod INT
			,DiaryDateWeek INT
			,CandidateId UNIQUEIDENTIFIER
			,ClaimFlag INT
			)

		CREATE NONCLUSTERED INDEX [IDX_DiaryEntry_DiaryDates_DiaryState] ON #PanelistTemp (
			[BusinessId]
			,[DiaryYear]
			,[DiaryPeriod]
			,[DiaryWeek]
			)

		DECLARE @targetrownum INT

		SET @targetrownum = (
				SELECT ct.rownum
				FROM #Calnder_temp ct
				WHERE @pTargetYear = ct.DiaryYear
					AND @pTargetPeriod = ct.diaryperiod
					AND @pTargetweek = ct.diaryweek
				)

		INSERT INTO #finalResult
		SELECT newid()
			,BusinessId
			,@pTargetYear AS DiaryDateYear
			,@pTargetPeriod AS DiaryDatePeriod
			,@pTargetWeek AS DiaryDateWeek
			,CandidateId
			,(
				CASE 
					WHEN MatchedRecord = 0
						THEN (@targetrownum - ct.rownum) + 1
					ELSE (@targetrownum - ct.rownum)
					END
				) AS ClaimFlag
		FROM #PanelistTemp pt
		INNER JOIN #Calnder_temp ct ON pt.DiaryYear = ct.DiaryYear
			AND pt.diaryperiod = ct.diaryperiod
			AND pt.diaryweek = ct.diaryweek

		-- If the record exist in the missing diaries then update the Claim Flag
		UPDATE MD
		SET MD.ClaimFlag = FR.ClaimFlag, MD.GPSUpdateTimestamp = @Getdate,MD.GPSUser=@pUsername
		FROM MissingDiaries MD
		INNER JOIN #finalResult FR ON FR.BusinessId = MD.BusinessId
			AND FR.DiaryDateYear = MD.DiaryDateYear
			AND FR.DiaryDateWeek = MD.DiaryDateWeek
			AND MD.DiaryDatePeriod = FR.DiaryDatePeriod
			AND MD.PanelId = @pPanelId

		DELETE FR
		FROM MissingDiaries MD
		INNER JOIN #finalResult FR ON FR.BusinessId = MD.BusinessId
			AND FR.DiaryDateYear = MD.DiaryDateYear
			AND FR.DiaryDateWeek = MD.DiaryDateWeek
			AND MD.DiaryDatePeriod = FR.DiaryDatePeriod
		WHERE MD.PanelId = @pPanelId

		INSERT INTO MissingDiaries (
			id
			,BusinessId
			,DiaryDateYear
			,DiaryDatePeriod
			,DiaryDateWeek
			,ClaimFlag
			,Country_Id
			,NumberOfDaysLate
			,NumberOfDaysEarly
			,ReceivedDate
			,GPSUser
			,DiarySourceFull
			,PanelId
			,CreationTimeStamp
			,GPSUpdateTimestamp
			)
		SELECT Id
			,BusinessId
			,DiaryDateYear
			,DiaryDatePeriod
			,DiaryDateWeek
			,ClaimFlag
			,@pCountryid
			,0
			,0
			,NULL
			,'ClaimProcessUser'
			,@DiaryTypeDesc
			,@pPanelId
			,@Getdate
			,@Getdate
		FROM #finalResult
		WHERE ClaimFlag > 0

			Declare @UndoClaimFlagId UniqueIdentifier
			SET @UndoClaimFlagId=NEWID()
			
		   INSERT INTO UndoClaimData(Id,DiaryDateYear,DiaryDatePeriod,DiaryDateWeek,DiarySourceFull,PanelName,PanelId,UndoClaimFlag,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
			SELECT @UndoClaimFlagId,@pTargetYear,@pTargetPeriod,@pTargetWeek,@DiaryTypeDesc,@PanelName,@pPanelId,0,@pUsername,@Getdate,@Getdate

			INSERT INTO MissingClaimData(UndoClaimId,MissingDiariesId)
		SELECT @UndoClaimFlagId,Id
		FROM MissingDiaries
		WHERE PanelId = @pPanelId
			AND GPSUpdateTimestamp=@Getdate
			

		INSERT INTO [dbo].[CommunicationEvent] (
			[GUIDReference]
			,[CreationDate]
			,[Incoming]
			,[State]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[CallLength]
			,[ContactMechanism_Id]
			,[Country_Id]
			,[Candidate_Id]
			)
		SELECT Id
			,@Getdate
			,1
			,2
			,@pUsername
			,@Getdate
			,@Getdate
			,'00:00:00'
			,@ContactMechanismId
			,@pCountryid
			,CandidateId
		FROM #finalResult
		WHERE ClaimFlag > 0

		DECLARE @comment NVARCHAR(max)

		SET @comment = Convert(NVARCHAR, @PanelName) + ' For the ' + convert(VARCHAR, @pTargetYear) + '.' + convert(VARCHAR, @pTargetPeriod) + '.' + convert(VARCHAR, @pTargetWeek) + ' , the claim flag is '

		INSERT INTO [dbo].[CommunicationEventReason] (
			[GUIDReference]
			,[Comment]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[ReasonType_Id]
			,[Panel_Id]
			,[Country_Id]
			,[Communication_Id]
			)
		SELECT NEWID()
			,@comment + convert(NVARCHAR, ClaimFlag)
			,@pUsername
			,@Getdate
			,@Getdate
			,@ReasonTypeId
			,@pPanelId
			,@pCountryid
			,Id
		FROM #finalResult
		WHERE ClaimFlag > 0

		SELECT COUNT(0)
			FROM MissingClaimData
		WHERE UndoClaimId = @UndoClaimFlagId
	
	END TRY

	BEGIN CATCH
		SELECT 0
	END CATCH

	IF OBJECT_ID('tempdb..#Calnder_temp') IS NOT NULL
		DROP TABLE #Calnder_temp

	IF OBJECT_ID('tempdb..#PanelistTemp') IS NOT NULL
		DROP TABLE #PanelistTemp

	IF OBJECT_ID('tempdb..#finalResult') IS NOT NULL
		DROP TABLE #finalResult
END
GO