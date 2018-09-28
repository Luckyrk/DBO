CREATE PROCEDURE [dbo].[InsertFormAnswersRecords] @pCountryId UNIQUEIDENTIFIER
	,@pGPSUser NVARCHAR(200)
	,@pCultureCode INT
	,@pFormAnswresInsert FormAnswresRecords READONLY
	,@pIsShowActiveBelonging BIT
	,@pFormId VARCHAR(100)
AS
BEGIN
	DECLARE @GetDate DATETIME

	SET @GetDate = ISNULL((
				SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pCountryId)
				), GETUTCDATE())
	--******************************BELONGINGS REGION START
	BEGIN TRANSACTION T

	BEGIN TRY
UPDATE Form SET IsShowActiveBelonging=@pIsShowActiveBelonging,GPSUpdateTimestamp=@GetDate WHERE GUIDReference=@pFormId AND ISNULL(IsShowActiveBelonging,0)<>ISNULL(@pIsShowActiveBelonging,0)

		CREATE TABLE #TempFormAnswers (
			RowNumber INT
			,DemographicType VARCHAR(50) collate database_default
			,DemographicId UNIQUEIDENTIFIER
			,AttributeValueId UNIQUEIDENTIFIER
			,Value NVARCHAR(100) collate database_default
			,CandidateId UNIQUEIDENTIFIER
			,RespondentId UNIQUEIDENTIFIER
			,DiscriminatorType NVARCHAR(400) collate database_default
			,BelongingTypeId UNIQUEIDENTIFIER
			,BelongingCode NVARCHAR(400) collate database_default
			,StateId UNIQUEIDENTIFIER
			,BelongingType NVARCHAR(400) collate database_default
			,[FreeText] NVARCHAR(400) collate database_default
			,BelongingSectionId UNIQUEIDENTIFIER
			,EnumSetID UNIQUEIDENTIFIER
			,IsNewRecord BIT
			,IsNewRespondent BIT
			)

		--STEP 1 INSERT BELONGINGS
		INSERT INTO #TempFormAnswers
		SELECT RowNumber
			,DemographicType
			,DemographicId
			,ISNULL(AttributeValueId, NEWID()) AS AttributeValueId
			,Value
			,CandidateId
			,IIF(BelongingSectionId IS NULL, NULL, RespondentId)
			,IIF(BelongingSectionId IS NULL, NULL, 'Belonging') AS DiscriminatorType
			,BelongingTypeId
			,BelongingCode
			,StateId
			,BelongingType
			,[FreeText]
			,BelongingSectionId
			,NULL AS EnumSetID
			,IIF(AttributeValueId IS NULL, 1, 0) AS IsNewRecord
			,IIF(RespondentId IS NULL, 1, 0) AS IsNewRecord
		FROM @pFormAnswresInsert

		DECLARE @TEMPNewRespondents AS TABLE (
			RowNumber INT
			,NEWRespondentId UNIQUEIDENTIFIER
			)

		INSERT INTO @TEMPNewRespondents
		SELECT RowNumber
			,NEWID()
		FROM #TempFormAnswers
		WHERE BelongingSectionId IS NOT NULL
			AND RespondentId IS NULL
		GROUP BY RowNumber

		UPDATE T2
		SET T2.RespondentId = T1.NEWRespondentId
		FROM #TempFormAnswers T2
		INNER JOIN @TEMPNewRespondents T1 ON T2.RowNumber = T1.RowNumber

		UPDATE T1
		SET T1.EnumSetID = A.EnumSetId
		FROM #TempFormAnswers T1
		INNER JOIN Attribute A ON A.GUIDReference = T1.DemographicId
			AND A.[Type] = 'Enum'
		WHERE T1.DemographicType = 'Enum'
			AND A.[Type] = 'Enum'
			AND A.EnumSetId IS NOT NULL

		--INSERT INTO Respondent
		INSERT INTO Respondent (
			[GUIDReference]
			,[DiscriminatorType]
			,[CountryID]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			)
		SELECT DISTINCT RespondentId
			,DiscriminatorType
			,@pCountryId
			,@pGPSUser
			,@GetDate
			,@GetDate
		FROM #TempFormAnswers
		WHERE IsNewRecord = 1
			AND BelongingSectionId IS NOT NULL
			AND IsNewRespondent = 1

		-- INSERT INTO Belonging
		INSERT INTO [Belonging] (
			[GUIDReference]
			,[CandidateId]
			,[TypeId]
			,[BelongingCode]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[State_Id]
			,[Type]
			)
		SELECT RespondentId
			,CandidateId
			,BelongingTypeId
			,RNO + MaxBelongingCode
			,@pGPSUser
			,@GetDate
			,@GetDate
			,StateId
			,BelongingType
		FROM (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY MaxBelongingCode ORDER BY MaxBelongingCode ASC
					) AS RNO
				,*
			FROM (
				SELECT DISTINCT RespondentId
					,BelongingTypeId
					,CandidateId
					,(
						SELECT ISNULL(Max(BelongingCode), 0)
						FROM Belonging B
						WHERE B.CandidateId = TF.CandidateId
							AND B.TypeId = TF.BelongingTypeId
						) AS MaxBelongingCode
					,StateId
					,BelongingType
				FROM #TempFormAnswers TF
				WHERE IsNewRecord = 1
					AND BelongingSectionId IS NOT NULL
					AND IsNewRespondent = 1
				) AS T1
			) AS T2

		-- INSERT INTO OrderedBelonging
		INSERT INTO [OrderedBelonging] (
			[Id]
			,[Order]
			,[BelongingSection_Id]
			,[Belonging_Id]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			)
		SELECT OrderedID
			,RNO + [Order]
			,BelongingSectionId
			,RespondentId
			,@pGPSUser
			,@GetDate
			,@GetDate
		FROM (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY [Order] ORDER BY OrderedID ASC
					) AS RNO
				,*
			FROM (
				SELECT NEWID() AS OrderedID
					,*
				FROM (
					SELECT DISTINCT (
							SELECT ISNULL(Max([Order]), 0)
							FROM OrderedBelonging OB
							WHERE OB.BelongingSection_Id = TB.BelongingSectionId
							) AS [Order]
						,BelongingSectionId
						,RespondentId
					FROM #TempFormAnswers TB
					WHERE IsNewRecord = 1
						AND BelongingSectionId IS NOT NULL
						AND IsNewRespondent = 1
					) AS T0
				) AS T1
			) AS T2

		--STEP 2 UPDATE BELONGINGS
		INSERT INTO [StateDefinitionHistory] (
			[GUIDReference]
			,[GPSUser]
			,[CreationDate]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Comments]
			,[CollaborateInFuture]
			,[From_Id]
			,[To_Id]
			,[ReasonForchangeState_Id]
			,[Country_Id]
			,[Panelist_Id]
			,[GroupMembership_Id]
			,[Candidate_Id]
			,[Belonging_Id]
			,[Order_Id]
			,[Order_Country_Id]
			,[Action_Id]
			,[Package_Id]
			,[ImportFile_Id]
			,[ImportFilePendingRecord_Id]
			)
		SELECT NEWID()
			,@pGPSUser
			,@Getdate
			,@Getdate
			,@Getdate
			,NULL
			,0
			,B.State_Id AS From_Id
			,TB.StateId
			,NULL
			,@pCountryId
			,NULL
			,NULL
			,NULL
			,TB.RespondentId
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
		FROM #TempFormAnswers TB
		INNER JOIN Belonging B ON B.GUIDReference = TB.RespondentId
		WHERE TB.IsNewRecord = 0
			AND TB.BelongingSectionId IS NOT NULL
			AND TB.StateId <> B.State_Id

		UPDATE B
		SET B.State_Id = TB.StateId
			,B.GPSUpdateTimestamp = @GetDate
			,B.GPSUser = @pGPSUser
		FROM #TempFormAnswers TB
		INNER JOIN Belonging B ON B.GUIDReference = TB.RespondentId
		WHERE TB.IsNewRecord = 0
			AND TB.BelongingSectionId IS NOT NULL
			AND TB.StateId <> B.State_Id

		--******************************BELONGINGS REGION END
		--STEP 3 INSERT ATTRIBUTE VALUES
		INSERT INTO [AttributeValue] (
			[GUIDReference]
			,[DemographicId]
			,[CandidateId]
			,[RespondentId]
			,[Address_Id]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Value]
			,[ValueDesc]
			,[EnumDefinition_Id]
			,[FreeText]
			,[Discriminator]
			,[Country_Id]
			)
		SELECT AttributeValueId
			,DemographicId
			,CASE 
				WHEN BelongingSectionId IS NULL
					THEN CandidateId
				ELSE NULL
				END
			,IIF(BelongingSectionId IS NULL, NULL, RespondentId)
			,NULL
			,@pGPSUser
			,@GetDate
			,@GetDate
			,CASE 
				WHEN DemographicType = 'int'
					THEN Value
				WHEN DemographicType = 'String'
					THEN Value
				WHEN DemographicType = 'Date'
					THEN Value
				WHEN DemographicType = 'Boolean'
					THEN IIF(Value = 'True', '1', '0')
				WHEN DemographicType = 'Float'
					THEN REPLACE(Value, ',', '.')
				WHEN DemographicType = 'Enum'
					THEN Value
				END
			,(
				SELECT TOP 1 ISNULL(tt.Value, t.KeyName) AS ValueDesc
				FROM EnumDefinition ed
				INNER JOIN Translation t ON ed.translation_id = t.translationid
				LEFT JOIN TranslationTerm tt ON tt.translation_id = t.translationid
					AND tt.culturecode = @pCultureCode
				WHERE ed.Value = #TempFormAnswers.Value
					AND ed.demographic_id = DemographicId
				)
			,CASE 
				WHEN DemographicType = 'Enum'
					THEN (
							SELECT ed.ID
							FROM EnumDefinition ED
							WHERE (
									ED.Demographic_Id = #TempFormAnswers.DemographicId
									OR ED.EnumSet_ID = #TempFormAnswers.EnumSetId
									)
								AND ED.Value = #TempFormAnswers.Value
							)
				END
			,[FreeText]
			,CASE 
				WHEN DemographicType = 'int'
					THEN 'IntAttributeValue'
				WHEN DemographicType = 'String'
					THEN 'StringAttributeValue'
				WHEN DemographicType = 'Date'
					THEN 'DateAttributeValue'
				WHEN DemographicType = 'Boolean'
					THEN 'BooleanAttributeValue'
				WHEN DemographicType = 'Float'
					THEN 'FloatAttributeValue'
				WHEN DemographicType = 'Enum'
					THEN 'EnumAttributeValue'
				END
			,@pCountryId
		FROM #TempFormAnswers
		WHERE IsNewRecord = 1
			AND VALUE IS NOT NULL

		--STEP 4 UPDATE ATTRIBUTE VALUES
		--update av set av.GPSUser=@pGPSUser,av.GPSUpdateTimestamp=@GetDate
		--from #TempFormAnswers TB
		--join AttributeValue av on av.GUIDReference=tb.AttributeValueId
		UPDATE av
		SET av.Value = CASE 
				WHEN DemographicType = 'int'
					THEN tb.Value
				WHEN DemographicType = 'String'
					THEN tb.Value
				WHEN DemographicType = 'Date'
					THEN tb.Value
				WHEN DemographicType = 'Boolean'
					THEN IIF(tb.Value = 'True', '1', '0')
				WHEN DemographicType = 'Float'
					THEN REPLACE(tb.Value, ',', '.')
				END
			,av.[Discriminator] = CASE 
				WHEN DemographicType = 'int'
					THEN 'IntAttributeValue'
				WHEN DemographicType = 'String'
					THEN 'StringAttributeValue'
				WHEN DemographicType = 'Date'
					THEN 'DateAttributeValue'
				WHEN DemographicType = 'Boolean'
					THEN 'BooleanAttributeValue'
				WHEN DemographicType = 'Float'
					THEN 'FloatAttributeValue'
				WHEN DemographicType = 'Enum'
					THEN 'EnumAttributeValue'
				END
			,av.GPSUpdateTimestamp = @GetDate
			,av.GPSUser = @pGPSUser
		FROM AttributeValue av
		INNER JOIN #TempFormAnswers tb ON av.GUIDReference = tb.AttributeValueId
		WHERE IsNewRecord = 0
			AND DemographicType <> 'Enum'
			AND DemographicType <> 'EnumAttributeValue'
			AND TB.VALUE IS NOT NULL
			AND TB.Value <> ISNULL(av.Value, '')

		UPDATE EV
		SET ev.[EnumDefinition_Id] = ED.Id
			,ev.[Discriminator] = 'EnumAttributeValue'
			,ev.value = TB.Value
			,ev.GPSUpdateTimestamp = @GetDate
			,ev.GPSUser = @pGPSUser
			,ev.ValueDesc = (
				SELECT TOP 1 ISNULL(tt.Value, t.KeyName) AS ValueDesc
				FROM EnumDefinition ed
				INNER JOIN Translation t ON ed.translation_id = t.translationid
				LEFT JOIN TranslationTerm tt ON tt.translation_id = t.translationid
					AND tt.culturecode = @pCultureCode
				WHERE ed.Value = tb.Value
					AND ed.demographic_id = tb.DemographicId
				)
			,ev.[FreeText] = TB.[FreeText]
		FROM #TempFormAnswers TB
		INNER JOIN AttributeValue EV ON TB.AttributeValueId = EV.GUIDReference
		INNER JOIN EnumDefinition ED ON (
				ED.Demographic_Id = TB.DemographicId
				OR TB.EnumSetID = ED.EnumSet_Id
				)
			AND ED.Value = TB.Value
		WHERE IsNewRecord = 0
			AND DemographicType = 'Enum'
			AND TB.VALUE IS NOT NULL
			AND (
				TB.Value <> ISNULL(ev.Value, '')
				OR ISNULL(TB.[FreeText], '') <> ISNULL(ev.[FreeText], '')
				)

		DELETE
		FROM AV
		FROM #TempFormAnswers TB
		INNER JOIN IntAttributeValue AV ON TB.AttributeValueId = AV.GUIDReference
		WHERE IsNewRecord = 0
			AND DemographicType = 'int'
			AND TB.VALUE IS NULL

		DELETE
		FROM AV
		FROM #TempFormAnswers TB
		INNER JOIN StringAttributeValue AV ON TB.AttributeValueId = AV.GUIDReference
		WHERE IsNewRecord = 0
			AND DemographicType = 'String'
			AND TB.VALUE IS NULL

		DELETE
		FROM AV
		FROM #TempFormAnswers TB
		INNER JOIN DateAttributeValue AV ON TB.AttributeValueId = AV.GUIDReference
		WHERE IsNewRecord = 0
			AND DemographicType = 'Date'
			AND TB.VALUE IS NULL

		DELETE
		FROM AV
		FROM #TempFormAnswers TB
		INNER JOIN BooleanAttributeValue AV ON TB.AttributeValueId = AV.GUIDReference
		WHERE IsNewRecord = 0
			AND DemographicType = 'Boolean'
			AND TB.VALUE IS NULL

		DELETE
		FROM AV
		FROM #TempFormAnswers TB
		INNER JOIN FloatAttributeValue AV ON TB.AttributeValueId = AV.GUIDReference
		WHERE IsNewRecord = 0
			AND DemographicType = 'Float'
			AND TB.VALUE IS NULL

		DELETE
		FROM EV
		FROM #TempFormAnswers TB
		INNER JOIN EnumAttributeValue EV ON TB.AttributeValueId = EV.GUIDReference
		WHERE IsNewRecord = 0
			AND DemographicType = 'Enum'
			AND TB.VALUE IS NULL

		DELETE
		FROM AV
		FROM #TempFormAnswers TB
		INNER JOIN AttributeValue AV ON TB.AttributeValueId = AV.GUIDReference
		WHERE IsNewRecord = 0
			AND TB.VALUE IS NULL

		COMMIT TRANSACTION T
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION T

		DECLARE @ERR_MSG AS NVARCHAR(4000)
			,@ERR_STA AS SMALLINT

		SET @ERR_MSG = ERROR_MESSAGE();
		SET @ERR_STA = ERROR_STATE();

		THROW 50001
			,@ERR_MSG
			,@ERR_STA;
	END CATCH
END