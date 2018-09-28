CREATE PROCEDURE [dbo].[GroupIdBulkUpdate_AdminScreen] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed UpdateGroupIdImportFeed_AdminScreen READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		IF NOT EXISTS (
				SELECT 1
				FROM ImportFile I
				INNER JOIN StateDefinition SD ON SD.Id = I.State_Id
					AND I.GUIDReference = @pFileId
				WHERE SD.Code = 'ImportFileProcessing'
					AND SD.Country_Id = @pCountryId
				)
		BEGIN
			RETURN;
		END

		DECLARE @Error BIT

		SET @Error = 0

		DECLARE @ISNUMERIC BIT

		SET @ISNUMERIC = 0

		/*
  EXEC InsertImportFile 'ImportFileProcessing'
         ,@pUser
         ,@pFileId
         ,@pCountryId
         */
		DECLARE @SelectedCoulmns NVARCHAR(max)
		DECLARE @GetDate DATETIME
		DECLARE @GroupIdLength INT
		DECLARE @UpdateGroupIdLength INT

		SELECT @SelectedCoulmns = 'isnull(GroupId,''NULL'')';

		DECLARE @Configuration_Id UNIQUEIDENTIFIER

		SET @Configuration_Id = (
				SELECT Configuration_Id
				FROM Country
				WHERE CountryId = @pCountryId
				)

		DECLARE @GroupBusinessIdDigits INT

		SET @GroupBusinessIdDigits = (
				SELECT TOP 1 GroupBusinessIdDigits
				FROM CountryConfiguration
				WHERE Id = @Configuration_Id
				)
		SET @GetDate = (
				SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(), @pCountryId)
				)
		SET @SelectedCoulmns = STUFF((
					SELECT '+''|''+isnull([' + [ColumnName] + '],''NULL'')'
					FROM @pColumn
					ORDER BY [Rownumber]
					FOR XML PATH('')
					), 1, 5, '')

		DECLARE @ImportFormatId UNIQUEIDENTIFIER

		SELECT @ImportFormatId = ImportFormat_Id
		FROM ImportFile
		WHERE GUIDReference = @pFileId

		IF (
				(
					SELECT COUNT(1)
					FROM ImportColumnMapping ICM
					INNER JOIN ImportFormat IMF ON ICM.ImportFormat_Id = IMF.GUIDReference
						AND ICM.ImportFormat_Id = @ImportFormatId
					) <> (
					SELECT COUNT(1)
					FROM @pColumn
					)
				)
		BEGIN
			SET @Error = 1

			INSERT INTO ImportAudit
			VALUES (
				NEWID()
				,1
				,1
				,'Import coulmns are not match with import format'
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

		DECLARE @importDataCount BIGINT

		SET @importDataCount = (
				SELECT COUNT(1)
				FROM @pImportFeed
				)

		DECLARE @columnsincrement INT

		SET @columnsincrement = 1

		DECLARE @rowsincrement INT

		SET @rowsincrement = 1

		DECLARE @insertincrement INT

		SET @insertincrement = 1

		DECLARE @maxColumnCount INT

		SET @maxColumnCount = (
				SELECT MAX(Rownumber)
				FROM @pColumn
				)

		DECLARE @REPETSEPARATOER NVARCHAR(max)

		SET @REPETSEPARATOER = REPLICATE('|', @maxColumnCount)

		DECLARE @maxInsertCount INT

		SET @maxInsertCount = (
				SELECT MAX(Rownumber)
				FROM @pImportFeed
				)

		IF (@importDataCount > 0)
		BEGIN
			WHILE (@columnsincrement <= @maxColumnCount)
			BEGIN
				SET @rowsincrement = 1

				WHILE (@rowsincrement <= @maxInsertCount)
				BEGIN
					DECLARE @columnName VARCHAR(100)

					SET @columnName = (
							SELECT [ColumnName]
							FROM @pColumn
							WHERE [Rownumber] = @columnsincrement
							)

					IF (@columnName = 'GroupId')
					BEGIN
						SET @GroupIdLength = (
								SELECT LEN(GroupId)
								FROM @pImportFeed
								WHERE Rownumber = @rowsincrement
									AND (
										GroupId IS NOT NULL
										OR LEN(GroupId) > 0
										)
								)
						SET @ISNUMERIC = (
								SELECT ISNUMERIC(GroupId)
								FROM @pImportFeed
								WHERE Rownumber = @rowsincrement
									AND (
										GroupId IS NOT NULL
										OR LEN(GroupId) > 0
										)
								)

						IF EXISTS (
								SELECT 1
								FROM @pImportFeed
								WHERE Rownumber = @rowsincrement
									AND (
										[GroupId] IS NULL
										OR LEN([GroupId]) = 0
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
								,'GroupId is mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Rownumber = @rowsincrement
								AND (
									Feed.[GroupId] IS NULL
									OR LEN(Feed.[GroupId]) = 0
									)
						END

						IF (@ISNUMERIC = 0)
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
								,'GroupId should be Numeric at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Rownumber = @rowsincrement
								AND (
									Feed.[GroupId] IS NOT NULL
									OR LEN(Feed.[GroupId]) > 0
									)
						END

						IF (@ISNUMERIC = 1)
						BEGIN
							IF EXISTS (
									SELECT 1
									FROM @pImportFeed
									GROUP BY [GroupId]
									HAVING COUNT([GroupId]) > 1
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
									,'Duplicate BusinessId''s are exists at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
									,@GetDate
									,Feed.[FullRow]
									,@REPETSEPARATOER
									,@GetDate
									,@pUser
									,@GetDate
									,@pFileId
								FROM @pImportFeed Feed
								WHERE Feed.[GroupId] IN (
										SELECT [GroupId]
										FROM @pImportFeed
										GROUP BY [GroupId]
										HAVING COUNT([GroupId]) > 1
										)
							END

							IF EXISTS (
									SELECT 1
									FROM @pImportFeed Feed
									WHERE NOT EXISTS (
											SELECT 1
											FROM Collective C
											WHERE C.Sequence = Feed.[GroupId]
												AND C.CountryId = @pCountryId
											)
										AND Feed.Rownumber = @rowsincrement
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
									,'GroupId should be exist at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
									,@GetDate
									,Feed.[FullRow]
									,@REPETSEPARATOER
									,@GetDate
									,@pUser
									,@GetDate
									,@pFileId
								FROM @pImportFeed Feed
								WHERE NOT EXISTS (
										SELECT 1
										FROM Collective C
										WHERE C.Sequence = Feed.[GroupId]
											AND C.CountryId = @pCountryId
										)
									AND Feed.Rownumber = @rowsincrement
							END
						END
					END

					IF (@columnName = 'UpdatedGroupID')
					BEGIN
						SET @UpdateGroupIdLength = (
								SELECT LEN(UpdatedGroupID)
								FROM @pImportFeed
								WHERE Rownumber = @rowsincrement
									AND (
										UpdatedGroupID IS NOT NULL
										OR LEN(UpdatedGroupID) > 0
										)
								)
						SET @ISNUMERIC = (
								SELECT ISNUMERIC(UpdatedGroupID)
								FROM @pImportFeed
								WHERE Rownumber = @rowsincrement
									AND (
										UpdatedGroupID IS NOT NULL
										OR LEN(UpdatedGroupID) > 0
										)
								)

						IF EXISTS (
								SELECT 1
								FROM @pImportFeed
								WHERE Rownumber = @rowsincrement
									AND (
										[UpdatedGroupID] IS NULL
										OR LEN([UpdatedGroupID]) = 0
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
								,'UpdateGroupId is mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Rownumber = @rowsincrement
								AND (
									Feed.[UpdatedGroupID] IS NULL
									OR LEN(Feed.[UpdatedGroupID]) = 0
									)
						END

						IF (@ISNUMERIC = 0)
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
								,'UpdateGroupId should be Numeric at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Rownumber = @rowsincrement
								AND (
									Feed.[UpdatedGroupID] IS NOT NULL
									OR LEN(Feed.[UpdatedGroupID]) > 0
									)
						END

						IF (@UpdateGroupIdLength > @GroupBusinessIdDigits)
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
								,'UpdatedGroupID should not exceed  (' + (
									SELECT CONVERT(VARCHAR(10), @GroupBusinessIdDigits)
									) + ') Digits at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Rownumber = @rowsincrement
								AND (
									LEN(Feed.[UpdatedGroupID]) > @GroupBusinessIdDigits
									AND Feed.[UpdatedGroupID] IS NOT NULL
									)
						END

						IF (@ISNUMERIC = 1)
						BEGIN
							IF EXISTS (
									SELECT 1
									FROM @pImportFeed
									GROUP BY [UpdatedGroupID]
									HAVING COUNT([UpdatedGroupID]) > 1
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
									,'Duplicate UpdateGroupId''s are exists at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
									,@GetDate
									,Feed.[FullRow]
									,@REPETSEPARATOER
									,@GetDate
									,@pUser
									,@GetDate
									,@pFileId
								FROM @pImportFeed Feed
								WHERE Feed.[UpdatedGroupID] IN (
										SELECT [UpdatedGroupID]
										FROM @pImportFeed
										GROUP BY [UpdatedGroupID]
										HAVING COUNT([UpdatedGroupID]) > 1
										)
							END

							IF EXISTS (
									SELECT 1
									FROM @pImportFeed Feed
									WHERE EXISTS (
											SELECT 1
											FROM Collective C
											WHERE C.Sequence = Feed.[UpdatedGroupID]
												AND C.CountryId = @pCountryId
											)
										AND Rownumber = @rowsincrement
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
									,'UpdateGroupId should not exist at Row ' + CONVERT(VARCHAR, Feed.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
									,@GetDate
									,Feed.[FullRow]
									,@REPETSEPARATOER
									,@GetDate
									,@pUser
									,@GetDate
									,@pFileId
								FROM @pImportFeed Feed
								WHERE EXISTS (
										SELECT 1
										FROM Collective C
										WHERE C.Sequence = Feed.[UpdatedGroupID]
											AND C.CountryId = @pCountryId
										)
									AND Rownumber = @rowsincrement
							END
						END
					END

					-------------------------------------------
					SET @rowsincrement = @rowsincrement + 1
				END

				--------------------------------------------
				SET @columnsincrement = @columnsincrement + 1
			END
		END

		--IF @@ROWCOUNT > 0
		--     SET @Error = 1
		IF (@Error > 0)
		BEGIN
			EXEC InsertImportFile 'ImportFileError'
				,@pUser
				,@pFileId
				,@pCountryId
		END
		ELSE
		BEGIN
			CREATE TABLE #ImportFeedData (
				Rownumber INT NOT NULL
				,[GroupId] INT NULL
				,[UpdatedGroupID] NVARCHAR(max) COLLATE DATABASE_DEFAULT NULL
				,GroupIdLength INT NULL
				,CountryId UNIQUEIDENTIFIER NULL
				)

			INSERT INTO #ImportFeedData (
				Rownumber
				,[GroupId]
				,[UpdatedGroupID]
				)
			SELECT Feed.Rownumber
				,Feed.[GroupId]
				,Feed.[UpdatedGroupID]
			FROM @pImportFeed Feed
			INNER JOIN Collective C ON C.Sequence = Feed.GroupId
				AND C.CountryId = @pCountryId

			BEGIN TRANSACTION T

			BEGIN TRY
				SET @GroupBusinessIdDigits = (
						SELECT CC.GroupBusinessIdDigits
						FROM COUNTRY C
						JOIN CountryConfiguration CC ON C.Configuration_Id = CC.Id
						WHERE C.CountryId = @pCountryId
						)

				--SET @IndividualId = (SELECT I.GUIDReference
				--FROM Collective C
				--JOIN #ImportFeedData IFD ON IFD.GroupId = C.Sequence
				--JOIN CollectiveMembership CM ON C.GUIDReference = CM.Group_Id
				--JOIN Individual I ON I.GUIDReference=CM.Individual_Id
				--AND I.CountryId=@pCountryId )
				UPDATE C
				SET C.Sequence = IFD.UpdatedGroupID
				FROM Collective C
				JOIN #ImportFeedData IFD ON IFD.GroupId = C.Sequence
					AND C.CountryId = @pCountryId

				UPDATE I
				SET I.IndividualId = REPLACE(I.IndividualId, LEFT(I.IndividualId, @GroupBusinessIdDigits), REPLICATE('0', @GroupBusinessIdDigits - LEN(RTRIM(IFD.UpdatedGroupID))) + IFD.UpdatedGroupID)
				FROM Collective C
				JOIN #ImportFeedData IFD ON IFD.UpdatedGroupID = C.Sequence
				JOIN CollectiveMembership CM ON C.GUIDReference = CM.Group_Id
				JOIN Individual I ON I.GUIDReference = CM.Individual_Id
					AND I.CountryId = @pCountryId
				WHERE IFD.UpdatedGroupID = C.Sequence

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
					,'Household updated successfully'
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed

				COMMIT TRANSACTION T
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION T

				INSERT INTO ImportAudit
				VALUES (
					NEWID()
					,1
					,1
					,ERROR_MESSAGE()
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