CREATE PROCEDURE [dbo].[ExclusionBulkInsert] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed ExclusionImportFeed READONLY
	,@pRepeatableData ExclusionRepeatableFeed READONLY	
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN --1
	SET NOCOUNT ON;

BEGIN TRY
	DECLARE @GetDate DATETIME
		DECLARE @ColumnNumber INT = 0

		SET @GetDate = (
				SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(), @pCountryId)
				)

	IF NOT EXISTS (
			SELECT 1
			FROM ImportFile I
			INNER JOIN StateDefinition SD ON SD.Id = I.State_Id
				AND I.GUIDReference = @pFileId
			WHERE SD.Code = 'ImportFileProcessing'
				AND SD.Country_Id = @pCountryId
			)
	BEGIN
		INSERT INTO ImportAudit
		VALUES (
			NEWID()
			,1
			,1
			,'File already is processed'
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
			)

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END

	DECLARE @Error BIT

	SET @Error = 0

	DECLARE @importDataCount BIGINT

	SET @importDataCount = (
			SELECT COUNT(*)
			FROM @pImportFeed
			)

	DECLARE @columnsincrement INT

	SET @columnsincrement = 1

	DECLARE @insertincrement INT

	SET @insertincrement = 1

	DECLARE @maxColumnCount INT

	SET @maxColumnCount = (
			SELECT MAX(Rownumber)
			FROM @pColumn
			)

	DECLARE @REPETSEPARATOER NVARCHAR(MAX)

	SET @REPETSEPARATOER = REPLICATE('|', @maxColumnCount)

	DECLARE @maxInsertCount INT

	SET @maxInsertCount = (
			SELECT MAX(Rownumber)
			FROM @pImportFeed
			)

	DECLARE @ImportFormatId UNIQUEIDENTIFIER

	SELECT @ImportFormatId = ImportFormat_Id
		FROM ImportFile
		WHERE GUIDReference = @pFileId

	IF (@importDataCount > 0)
	BEGIN --2
		WHILE (@columnsincrement <= @maxColumnCount)
		BEGIN --3
			DECLARE @columnName VARCHAR(100)

			SET @columnName = (
					SELECT [ColumnName]
					FROM @pColumn
					WHERE [Rownumber] = @columnsincrement
					)

				IF (@columnName = 'BusinessId')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE BusinessId IS NULL
						)
				BEGIN
					SET @Error = 1

					INSERT INTO ImportAudit (
						GUIDReference
						,Error
						,IsInvalid
						,[Message]
						,[Date]
						,SerializedRowData
						,SerializedRowErrors
						,CreationTimeStamp
						,GPSUser
						,GPSUpdateTimestamp
						,[File_Id]
						)
					SELECT NEWID()
						,1
						,0
							,'BusinessId Mandatory at Row ' + CONVERT(VARCHAR, Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.BusinessId IS NULL
				END
			END
				ELSE IF (@columnName = 'RangeFrom')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE RangeFrom IS NULL
						)
				BEGIN
					SET @Error = 1

					INSERT INTO ImportAudit (
						GUIDReference
						,Error
						,IsInvalid
						,[Message]
						,[Date]
						,SerializedRowData
						,SerializedRowErrors
						,CreationTimeStamp
						,GPSUser
						,GPSUpdateTimestamp
						,[File_Id]
						)
					SELECT NEWID()
						,1
						,0
							,'RangeFrom Mandatory at Row ' + CONVERT(VARCHAR, Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.RangeFrom IS NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
							WHERE RangeFrom IS NOT NULL
								AND RangeTo IS NOT NULL
								AND RangeFrom > RangeTo
						)
				BEGIN
					SET @Error = 1

					INSERT INTO ImportAudit (
						GUIDReference
						,Error
						,IsInvalid
						,[Message]
						,[Date]
						,SerializedRowData
						,SerializedRowErrors
						,CreationTimeStamp
						,GPSUser
						,GPSUpdateTimestamp
						,[File_Id]
						)
					SELECT NEWID()
						,1
						,0
							,'RangeFrom should be less than To Date at Row ' + CONVERT(VARCHAR, Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
						WHERE RangeFrom IS NOT NULL
							AND RangeTo IS NOT NULL
							AND RangeFrom > RangeTo
				END
			END
				ELSE IF (@columnName = 'ReasonType')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE ReasonType IS NULL
						)
				BEGIN
					SET @Error = 1

					INSERT INTO ImportAudit (
						GUIDReference
						,Error
						,IsInvalid
						,[Message]
						,[Date]
						,SerializedRowData
						,SerializedRowErrors
						,CreationTimeStamp
						,GPSUser
						,GPSUpdateTimestamp
						,[File_Id]
						)
					SELECT NEWID()
						,1
						,0
							,'ReasonType Mandatory at Row ' + CONVERT(VARCHAR, Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.ReasonType IS NULL
				END
			END		
			
				IF (@columnName = 'AllIndividuals')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
							WHERE AllIndividuals IS NOT NULL
								AND AllIndividuals NOT IN (
									'0'
									,'1'
									,'YES'
									,'NO'
									,'TRUE'
									,'FALSE'
						)
							)
				BEGIN
					SET @Error = 1

					INSERT INTO ImportAudit (
						GUIDReference
						,Error
						,IsInvalid
						,[Message]
						,[Date]
						,SerializedRowData
						,SerializedRowErrors
						,CreationTimeStamp
						,GPSUser
						,GPSUpdateTimestamp
						,[File_Id]
						)
					SELECT NEWID()
						,1
						,0
							,'AllIndividuals INVALID at Row ' + CONVERT(VARCHAR, Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
						WHERE AllIndividuals IS NOT NULL
							AND AllIndividuals NOT IN (
								'0'
								,'1'
								,'YES'
								,'NO'
								,'TRUE'
								,'FALSE'
								)
				END
			END
			
			SET @columnsincrement = @columnsincrement + 1
		END --3

		IF EXISTS (
					SELECT 1
					FROM @pImportFeed Feed
					JOIN Individual I ON I.IndividualId = Feed.BusinessId
					JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
					JOIN StateDefinition SD ON CM.State_Id = SD.Id
					WHERE SD.InactiveBehavior = 1
					)
		BEGIN
			SET @Error = 1

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
					,'Individual is Inactive at Row ' + CONVERT(VARCHAR, Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeed Feed
			JOIN Individual I ON I.IndividualId = Feed.BusinessId
			JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
			JOIN StateDefinition SD ON CM.State_Id = SD.Id
			WHERE SD.InactiveBehavior = 1
		END	

			IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE [ColumnName] = 'PanelCode'					
			)
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM @pRepeatableData
					WHERE PanelCode IS NULL
					)
			BEGIN
				SET @Error = 1

				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
						,'PanelCode Mandatory at Row ' + CONVERT(VARCHAR, feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
					FROM @pRepeatableData R
					INNER JOIN @pImportFeed Feed ON R.Rownumber = Feed.Rownumber
				WHERE R.PanelCode IS NULL
			END

				IF (
						SELECT COUNT(1)
						FROM @pRepeatableData
						) = 0
			BEGIN
				SET @Error = 1

				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
						,'PanelCode Mandatory at Row ' + CONVERT(VARCHAR, feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
					FROM @pRepeatableData R
					INNER JOIN @pImportFeed Feed ON R.Rownumber = Feed.Rownumber
				WHERE R.PanelCode IS NULL
			END

			IF EXISTS (
					SELECT 1
						FROM @pRepeatableData IMP
						LEFT JOIN Panel P ON IMP.PanelCode = P.PanelCode
							AND P.Country_Id = @pCountryId
						WHERE P.PanelCode IS NULL
					)
			BEGIN
				SET @Error = 1
					SELECT @ColumnNumber = RowNumber
		FROM @pColumn
		WHERE [ColumnName] = 'PanelCode'
				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
						,'Invalid PanelCode at Row ' + CONVERT(VARCHAR, IMP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,IMP.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
					FROM @pRepeatableData RP
					INNER JOIN @pImportFeed IMP ON RP.Rownumber = IMP.Rownumber
					LEFT JOIN Panel P ON RP.PanelCode = P.PanelCode
						AND P.Country_Id = @pCountryId
					WHERE P.PanelCode IS NULL
			END
		END

			IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE [ColumnName] = 'BusinessId'					
			)
		BEGIN
			IF EXISTS (
					SELECT 1
						FROM @pImportFeed IMP
						LEFT JOIN Individual I ON IMP.BusinessId = I.IndividualId
						WHERE I.IndividualId IS NULL
					)
			BEGIN
				SET @Error = 1

					SELECT @ColumnNumber = RowNumber
					FROM @pColumn
					WHERE [ColumnName] = 'BusinessId'

				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
						,'Invalid BusinessId at Row ' + CONVERT(VARCHAR, IMP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,IMP.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
					FROM @pImportFeed IMP
					LEFT JOIN Individual I ON IMP.BusinessId = I.IndividualId
					WHERE I.IndividualId IS NULL
			END
		END
		
		CREATE TABLE #ImportFeedData (
				Rownumber INT NOT NULL
				,ExclusionGuid UNIQUEIDENTIFIER
				,IndividualId VARCHAR(20) COLLATE DATABASE_DEFAULT NOT NULL
				,IndividualGuid UNIQUEIDENTIFIER
				,GroupGuid UNIQUEIDENTIFIER
				,ExclusionType VARCHAR(500) COLLATE DATABASE_DEFAULT NOT NULL
				,ExclusionTypeId UNIQUEIDENTIFIER
				,RangeFrom DATETIME NOT NULL
				,RangeEnd DATETIME
				,AllIndividuals BIT
			)

		/* missed row id concept */
		INSERT INTO #ImportFeedData (
			Rownumber
			,ExclusionGuid			
			,IndividualId			
			,ExclusionType			
			,RangeFrom
			,RangeEnd
			,AllIndividuals			
			)
			SELECT Feed.Rownumber
				,NEWID()
				,Feed.BusinessId
				,Feed.ReasonType
				,Feed.RangeFrom
				,DATEADD(s, - 1, DATEADD(day, 1, CONVERT(DATETIME, feed.RangeTo)))
				,CASE 
					WHEN UPPER(Feed.AllIndividuals) = 'YES'
						THEN 1
					WHEN UPPER(Feed.AllIndividuals) = 'NO'
						THEN 0
					WHEN UPPER(Feed.AllIndividuals) = 'TRUE'
						THEN 1
					WHEN UPPER(Feed.AllIndividuals) = 'FALSE'
						THEN 0
					ELSE ISNULL(Feed.AllIndividuals, 0)
			END
				   FROM @pImportFeed Feed

			UPDATE IMP
			SET IMP.ExclusionTypeId = E.GUIDReference
			FROM #ImportFeedData IMP
			INNER JOIN Translation T ON T.KeyName = IMP.ExclusionType
			INNER JOIN TranslationTerm TE ON TE.Translation_Id = T.TranslationId
				AND CultureCode = @pCultureCode
			INNER JOIN ExclusionType E ON E.Translation_Id = T.TranslationId
				AND E.Country_Id = @pCountryId

			UPDATE IMP
			SET IMP.ExclusionTypeId = E.GUIDReference
			FROM #ImportFeedData IMP
			INNER JOIN TranslationTerm TE ON TE.Value = IMP.ExclusionType
				AND CultureCode = @pCultureCode
			INNER JOIN ExclusionType E ON E.Translation_Id = TE.Translation_Id
				AND E.Country_Id = @pCountryId
			WHERE IMP.ExclusionTypeId IS NULL

			IF EXISTS (
					SELECT 1
					FROM #ImportFeedData
					WHERE ExclusionTypeId IS NULL
					)
		BEGIN		
			SET @Error = 1

				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
					,'Invalid Exclusion Type at Row ' + CONVERT(VARCHAR, IMP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
					,@GetDate
					,FEED.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM #ImportFeedData IMP
				INNER JOIN @pImportFeed FEED ON FEED.Rownumber = IMP.RowNumber
				WHERE ExclusionTypeId IS NULL
		END

			SELECT *
			FROM #ImportFeedData

			UPDATE IMP
			SET IMP.IndividualGuid = I.GUIDReference
			FROM #ImportFeedData IMP
			INNER JOIN Individual I ON I.IndividualId = IMP.IndividualId
				AND I.CountryId = @pCountryId

			UPDATE IMP
			SET IMP.GroupGuid = C.Group_Id
			FROM #ImportFeedData IMP
			INNER JOIN CollectiveMembership C ON C.Individual_Id = IMP.IndividualGuid
		
		CREATE TABLE #RepeatableData (
				RowNumber INT NOT NULL
				,ExclusionGuid UNIQUEIDENTIFIER
				,PanelistGUID UNIQUEIDENTIFIER
				,PanelGUID UNIQUEIDENTIFIER NULL
				,PanelCode NVARCHAR(200) NULL
				,PanelType NVARCHAR(200) NULL
				,GroupGUID UNIQUEIDENTIFIER NULL
				,IndividualGuid UNIQUEIDENTIFIER NULL
			)

			--select * from @pRepeatableData;
			--select* from #RepeatableData
		INSERT INTO #RepeatableData (
			RowNumber			
			,PanelGUID
			,ExclusionGuid
			,PanelCode
			,PanelType
			,GroupGUID
			,IndividualGuid			
			)
			SELECT rep.Rownumber
				,P.GUIDReference
				,fEED.ExclusionGuid
				,Rep.PanelCode
				,P.[Type]
				,Feed.GroupGuid
				,Feed.IndividualGuid
		FROM @pRepeatableData REP
		INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
		INNER JOIN Panel P ON P.PanelCode = REP.PanelCode
			AND P.Country_Id = @pCountryId	

			UPDATE REP
			SET PanelistGUID = P.GUIDReference
			FROM #RepeatableData REP
			INNER JOIN Panelist P ON P.PanelMember_Id = REP.IndividualGuid
				AND P.Panel_Id = REP.PanelGUID
			WHERE REP.PanelType = 'Individual'

			UPDATE REP
			SET PanelistGUID = P.GUIDReference
			FROM #RepeatableData REP
			INNER JOIN Panelist P ON P.PanelMember_Id = REP.GroupGUID
				AND P.Panel_Id = REP.PanelGUID
			WHERE REP.PanelType = 'HouseHold'

			IF EXISTS (
					SELECT 1
					FROM #RepeatableData
					WHERE PanelistGUID IS NULL
					)
		BEGIN
				PRINT 'error'

			SET @Error = 1

				SELECT @ColumnNumber = RowNumber
				FROM @pColumn
				WHERE [ColumnName] = 'PanelCode'

				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
					,'Invalid Panelcode at Row ' + CONVERT(VARCHAR, FEED.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,FEED.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM #RepeatableData REP
				INNER JOIN @pImportFeed FEED ON FEED.Rownumber = REP.RowNumber
				WHERE PanelistGUID IS NULL
		END

		/*****************DUPLICATE VALIDATION  START*********************/
			IF EXISTS (
					SELECT 1
					FROM (
						SELECT E.Range_From
							,E.Range_To
							,EI.Individual_Id
						FROM Exclusion E
							INNER JOIN ExclusionIndividual EI ON E.GUIDReference = EI.Exclusion_Id 
							INNER JOIN ExclusionPanelist EP ON EP.Exclusion_Id = E.GUIDReference 
						INNER JOIN #ImportFeedData IMP ON IMP.IndividualGuid = EI.Individual_Id
							AND E.[Type_Id] = IMP.ExclusionTypeId
						INNER JOIN #RepeatableData REP ON REP.IndividualGuid = EI.Individual_Id
							AND EP.Panelist_Id = REP.PanelistGUID
							AND IMP.RowNumber = REP.RowNumber
							WHERE (
								(
									IMP.RangeFrom BETWEEN E.Range_From
										AND ISNULL(E.Range_To, CONVERT(DATETIME, '2200-01-01 00:00:00'))
									)
								OR (
									(
										IMP.RangeEnd BETWEEN E.Range_From
											AND ISNULL(E.Range_To, CONVERT(DATETIME, '2200-01-01 00:00:00'))
										)
									AND IMP.RangeEnd IS NOT NULL
									)
								OR (
									IMP.RangeEnd IS NULL
									AND (ISNULL(IMP.RangeEnd, IMP.RangeFrom) < E.Range_From)
									)
								)
						) TEMP
								   )
		BEGIN
			SET @Error = 1

				INSERT INTO ImportAudit (
					GUIDReference
					,Error
					,IsInvalid
					,[Message]
					,[Date]
					,SerializedRowData
					,SerializedRowErrors
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,[File_Id]
					)
				SELECT NEWID()
					,1
					,0
					,'Exclusion Range is already used by one identical type exclusion at Row ' + CONVERT(VARCHAR, FEED.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
					,@GetDate
					,FEED.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM (
					SELECT DISTINCT IMP.Rownumber
						,E.Range_From
						,E.Range_To
						,EI.Individual_Id
					FROM Exclusion E
							INNER JOIN ExclusionIndividual EI ON E.GUIDReference = EI.Exclusion_Id 
							INNER JOIN ExclusionPanelist EP ON EP.Exclusion_Id = E.GUIDReference 
					INNER JOIN #ImportFeedData IMP ON IMP.IndividualGuid = EI.Individual_Id
						AND E.[Type_Id] = IMP.ExclusionTypeId
					INNER JOIN #RepeatableData REP ON REP.IndividualGuid = EI.Individual_Id
						AND EP.Panelist_Id = REP.PanelistGUID
						AND IMP.RowNumber = REP.RowNumber
							WHERE (
							(
								IMP.RangeFrom BETWEEN E.Range_From
									AND ISNULL(E.Range_To, CONVERT(DATETIME, '2200-01-01 00:00:00'))
								)
							OR (
								(
									IMP.RangeEnd BETWEEN E.Range_From
										AND ISNULL(E.Range_To, CONVERT(DATETIME, '2200-01-01 00:00:00'))
									)
								AND IMP.RangeEnd IS NOT NULL
								)
							OR (
								IMP.RangeEnd IS NULL
								AND (ISNULL(IMP.RangeEnd, IMP.RangeFrom) < E.Range_From)
								)
							)
					) REP
				INNER JOIN @pImportFeed FEED ON FEED.Rownumber = REP.RowNumber
		END
		
		/*****************DUPLICATE VALIDATION  END*********************/
		IF (@Error > 0)
		BEGIN
			EXEC InsertImportFile 'ImportFileBusinessValidationError'
				,@pUser
				,@pFileId
				,@pCountryId

			RETURN;
		END
		ELSE		
				BEGIN TRANSACTION

			BEGIN TRY
			--Start Insert
				INSERT INTO Exclusion (
					GUIDReference
					,Range_From
					,Range_To
					,AllIndividuals
					,AllPanels
					,IsClosed
					,GPSUser
					,CreationTimeStamp
					,[Type_Id]
					,Parent_Id
					,GPSUpdateTimestamp
					)
				SELECT FEED.ExclusionGuid
					,FEED.RangeFrom
					,FEED.RangeEnd
					,FEED.AllIndividuals
					,0
					,0
					,@pUser
					,@GetDate
					,FEED.ExclusionTypeId
					,FEED.IndividualGuid
					,@GetDate
				FROM #ImportFeedData FEED

				INSERT INTO ExclusionIndividual (
					Exclusion_Id
					,Individual_Id
					,GPSUser
					,GPSUpdateTimestamp
					,CreationTimeStamp
					)
				SELECT FEED.ExclusionGuid
					,FEED.IndividualGuid
					,@pUser
					,@GetDate
					,@GetDate
				FROM #ImportFeedData FEED
				WHERE FEED.AllIndividuals = 0

				INSERT INTO ExclusionIndividual (
					Exclusion_Id
					,Individual_Id
					,GPSUser
					,GPSUpdateTimestamp
					,CreationTimeStamp
					)
				SELECT FEED.ExclusionGuid
					,C.Individual_Id
					,@pUser
					,@GetDate
					,@GetDate
				FROM #ImportFeedData FEED
				INNER JOIN CollectiveMembership C ON C.Group_Id = FEED.GroupGuid
				WHERE FEED.AllIndividuals = 1

				INSERT INTO ExclusionPanelist (
					Exclusion_Id
					,Panelist_Id
					,GPSUser
					,GPSUpdateTimestamp
					,CreationTimeStamp
					)
				SELECT FEED.ExclusionGuid
					,FEED.PanelistGUID
					,@pUser
					,@GetDate
					,@GetDate
				FROM #RepeatableData FEED

			EXEC InsertImportFile 'ImportFileSuccess'
				,@pUser
				,@pFileId
				,@pCountryId		

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,0
				,0
				,'Exclusion created successfully ( ' + ISNULL(IFD.IndividualId, '') + ' )'
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeed Feed
			INNER JOIN #ImportFeedData IFD ON Feed.[Rownumber] = IFD.Rownumber

				PRINT @pFileId

			COMMIT TRANSACTION

				PRINT 'sucess';
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION

				PRINT 'error';

			INSERT INTO ImportAudit
			VALUES (
				NEWID()
				,1
				,1
				,ERROR_MESSAGE()
				,@GetDate
				,NULL
				,NULL
				,NULL
				,@pUser
				,@GetDate
				,@pFileId
				)

			EXEC InsertImportFile 'ImportFileBusinessValidationError'
				,@pUser
				,@pFileId
				,@pCountryId
		END CATCH
	END
END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();
	
		RAISERROR (
				@ErrorMessage
				,-- Message text.
				@ErrorSeverity
				,-- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END
