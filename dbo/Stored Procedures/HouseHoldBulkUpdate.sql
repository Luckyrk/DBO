CREATE PROCEDURE [dbo].[HouseHoldBulkUpdate] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed HouseHoldImportFeedUpdate READONLY
	,@pDemographicData Demographics READONLY
	,@AliasImportFeed NamedAliasImportFeed READONLY
	,@DyniamicRoles DynamicRolesImportFeed READONLY
	,@RepeatableFeed RepeatableFeed READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @ColumnNumber INT = 0

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

		/*

	EXEC InsertImportFile 'ImportFileProcessing'

		,@pUser

		,@pFileId

		,@pCountryId

		*/
		DECLARE @SelectedCoulmns NVARCHAR(MAX)
		DECLARE @GetDate DATETIME

		SELECT @SelectedCoulmns = 'isnull(BusinessId,''NULL'')';

		SET @GetDate = (
				SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pCountryId)
				)

		IF (@GetDate IS NULL)
		BEGIN
			INSERT INTO ImportAudit
			VALUES (
				NEWID()
				,1
				,1
				,'Time zone is not configured for the Country'
				,GETDATE()
				,NULL
				,NULL
				,GETDATE()
				,@pUser
				,GETDATE()
				,@pFileId
				)

			EXEC InsertImportFile 'ImportFileBusinessValidationError'
				,@pUser
				,@pFileId
				,@pCountryId

			RETURN;
		END

		BEGIN TRY
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

			DECLARE @ImportColumnMappingCount INT = NULL

			IF EXISTS (
					SELECT 1
					FROM ImportColumnMapping ICM
					INNER JOIN ImportFormat IMF ON ICM.ImportFormat_Id = IMF.GUIDReference
						AND ICM.ImportFormat_Id = @ImportFormatId
					INNER JOIN Country C ON IMF.Country_Id = C.CountryId
					INNER JOIN ImportsPostBackToMorpheusConfiguration IPMC ON IPMC.CountryId = C.CountryId
						AND IPMC.ImportDefinitionTypeName = IMF.ImportDefinitionTypeName
					WHERE IPMC.CountryISO2A = C.CountryISO2A
					)
			BEGIN
				SELECT @ImportColumnMappingCount = COUNT(1)
				FROM ImportColumnMapping ICM
				INNER JOIN ImportFormat IMF ON ICM.ImportFormat_Id = IMF.GUIDReference
					AND ICM.ImportFormat_Id = @ImportFormatId
				INNER JOIN Country C ON IMF.Country_Id = C.CountryId
				INNER JOIN ImportsPostBackToMorpheusConfiguration IPMC ON IPMC.CountryId = C.CountryId
					AND IPMC.ImportDefinitionTypeName = IMF.ImportDefinitionTypeName
				WHERE IPMC.CountryISO2A = C.CountryISO2A
			END

			IF (
					(@ImportColumnMappingCount IS NOT NULL)
					AND (@ImportColumnMappingCount) <= 2
					AND NOT EXISTS (
						SELECT 1
						FROM ImportColumnMapping ICM
						INNER JOIN ImportFormat IMF ON ICM.ImportFormat_Id = IMF.GUIDReference
							AND ICM.ImportFormat_Id = @ImportFormatId
						INNER JOIN Country C ON IMF.Country_Id = C.CountryId
						INNER JOIN ImportsPostBackToMorpheusConfiguration IPMC ON IPMC.CountryId = C.CountryId
							AND IPMC.ImportDefinitionTypeName = IMF.ImportDefinitionTypeName
							AND IPMC.DemogrpahicId = ICM.Demographic_Id
							AND ICM.Discriminator = 'AttributeImportColumnMapping'
						WHERE IPMC.CountryISO2A = C.CountryISO2A
						)
					)
			BEGIN
				SET @Error = 1

				INSERT INTO ImportAudit
				VALUES (
					NEWID()
					,1
					,1
					,'Morphues house hold import should only update Socialgrade'
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

			IF (
					(@ImportColumnMappingCount IS NOT NULL)
					AND (@ImportColumnMappingCount) > 2
					)
			BEGIN
				SET @Error = 1

				INSERT INTO ImportAudit
				VALUES (
					NEWID()
					,1
					,1
					,'Morphues house hold import should only update Socialgrade'
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

			IF NOT EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'BusinessId'
					)
			BEGIN
				INSERT INTO ImportAudit
				VALUES (
					NEWID()
					,1
					,1
					,'BusinessId not exist'
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

			IF OBJECT_ID('tempdb..#AddressTypes') IS NULL
			BEGIN
				CREATE TABLE #AddressTypes (
					ID UNIQUEIDENTIFIER
					,AddressType NVARCHAR(50) Collate Database_Default
					)

				INSERT INTO #AddressTypes (
					ID
					,AddressType
					) (
					SELECT AT.Id
					,TT.Value FROM TranslationTerm TT INNER JOIN AddressType AT ON AT.Description_Id = TT.Translation_Id WHERE AT.DiscriminatorType = 'PostalAddressType'
					AND TT.CultureCode = @pCultureCode
					)
			END

			IF (@importDataCount > 0)
			BEGIN
				WHILE (@columnsincrement <= @maxColumnCount)
				BEGIN
					DECLARE @columnName VARCHAR(100)

					SET @columnName = (
							SELECT TOP 1 [ColumnName]
							FROM @pColumn
							WHERE [Rownumber] = @columnsincrement
							)

					IF (@columnName = 'BusinessId')
					BEGIN
						IF EXISTS (
								SELECT 1
								FROM @pImportFeed
								WHERE [BusinessId] IS NULL
									OR LEN([BusinessId]) = 0
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
								,'BusinessId is mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Feed.[BusinessId] IS NULL
								OR LEN(Feed.[BusinessId]) = 0
						END

						IF EXISTS (
								SELECT 1
								FROM @pImportFeed
								GROUP BY BusinessId
								HAVING count(BusinessId) > 1
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
								,'Duplicate BusinessId''s are exists at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							WHERE Feed.BusinessId IN (
									SELECT BusinessId
									FROM @pImportFeed
									GROUP BY BusinessId
									HAVING count(BusinessId) > 1
									)
						END

						IF EXISTS (
								SELECT 1
								FROM @pImportFeed Feed
								WHERE NOT EXISTS (
										SELECT 1
										FROM Individual I
										WHERE I.IndividualId = Feed.BusinessId
											AND I.CountryId = @pCountryId
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
								,'BusinessId should be exist at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
									FROM Individual I
									WHERE I.IndividualId = Feed.BusinessId
										AND i.CountryId = @pCountryId
									)

							SET @Error = 1
						END
					END

					IF (@columnName = 'InterviewerCode')
					BEGIN
						IF EXISTS (
								SELECT 1
								FROM @pImportFeed Feed
								LEFT JOIN [dbo].[Interviewer] Inte ON FEED.InterviewerCode = Inte.InterviewerCode
									AND @pCountryId = Inte.Country_Id
								WHERE Inte.ID IS NULL
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
								,'InterviewerCode is not Found at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
								,@GetDate
								,Feed.[FullRow]
								,@REPETSEPARATOER
								,@GetDate
								,@pUser
								,@GetDate
								,@pFileId
							FROM @pImportFeed Feed
							LEFT JOIN [dbo].[Interviewer] Inte ON FEED.InterviewerCode = Inte.InterviewerCode
								AND @pCountryId = Inte.Country_Id
							WHERE Inte.ID IS NULL
						END
					END

					IF (@columnName = 'GroupContact')
					BEGIN
						IF EXISTS (
								SELECT 1
								FROM @pImportFeed Feed
								WHERE NOT EXISTS (
										SELECT 1
										FROM Individual I
										WHERE I.IndividualId = Feed.GroupContact COLLATE SQL_Latin1_General_CP1_CI_AI
											AND I.CountryId = @pCountryId
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
								,'Group Contact should be exist at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
									FROM Individual I
									WHERE I.IndividualId = Feed.GroupContact COLLATE SQL_Latin1_General_CP1_CI_AI
										AND I.CountryId = @pCountryId
									)
						END
					END

					SET @columnsincrement = @columnsincrement + 1
				END
			END

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'AddressType'
					)
			BEGIN
				SELECT @ColumnNumber = RowNumber
				FROM @pColumn
				WHERE [ColumnName] = 'AddressType'

				IF EXISTS (
						SELECT 1
						FROM @RepeatableFeed REP
						WHERE AddressType IS NULL
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
						,'AddressType is Mandatory at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
						,@GetDate
						,IMP.FullRow
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @RepeatableFeed Feed
					INNER JOIN @pImportFeed IMP ON Feed.Rownumber = IMP.Rownumber
					WHERE AddressType IS NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @RepeatableFeed REP
						LEFT JOIN #AddressTypes AT ON AT.AddressType = REP.AddressType
						WHERE REP.AddressType IS NOT NULL
							AND AT.AddressType IS NULL
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
						,'AddressType is not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
						,@GetDate
						,IMP.FullRow
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @RepeatableFeed Feed
					LEFT JOIN #AddressTypes AT ON AT.AddressType = REP.AddressType
					WHERE REP.AddressType IS NOT NULL
						AND AT.AddressType IS NULL
				END
			END

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'Order'
						OR [ColumnName] = 'AddressType'
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @RepeatableFeed
						WHERE (
								[Order] IS NULL
								AND AddressType IS NULL
								)
							AND (
								AddressLine1 IS NOT NULL
								OR AddressLine2 IS NOT NULL
								OR AddressLine3 IS NOT NULL
								OR AddressLine4 IS NOT NULL
								OR PostCode IS NOT NULL
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
						,'Order/AddressType is Mandatory at Row ' + CONVERT(VARCHAR, FEED1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
						,@GetDate
						,Feed1.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @RepeatableFeed Feed
					INNER JOIN @pImportFeed FEED1 ON FEED1.Rownumber = Feed.Rownumber
					WHERE (
							[Order] IS NULL
							AND AddressType IS NULL
							)
						AND (
							AddressLine1 IS NOT NULL
							OR AddressLine2 IS NOT NULL
							OR AddressLine3 IS NOT NULL
							OR AddressLine4 IS NOT NULL
							OR PostCode IS NOT NULL
							)
				END
			END

			IF EXISTS (
					SELECT 1
					FROM @RepeatableFeed
					WHERE AddressLine1 IS NULL
						AND AddressLine2 IS NULL
						AND AddressLine3 IS NULL
						AND AddressLine4 IS NULL
						AND PostCode IS NULL
						AND (
							AddressType IS NOT NULL
							OR [Order] IS NOT NULL
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
					,'Either AddressLine1 OR AddressLine2 Or AddressLine3 Or AddressLine4 Or PostCode is required at Row ' + CONVERT(VARCHAR, FEED1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
					,@GetDate
					,Feed1.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @RepeatableFeed Feed
				INNER JOIN @pImportFeed FEED1 ON FEED1.Rownumber = Feed.Rownumber
				WHERE AddressLine1 IS NULL
					AND AddressLine2 IS NULL
					AND AddressLine3 IS NULL
					AND AddressLine4 IS NULL
					AND PostCode IS NULL
					AND (
						AddressType IS NOT NULL
						OR [Order] IS NOT NULL
						)
			END

			IF EXISTS (
					SELECT 1
					FROM @DyniamicRoles DR
					WHERE DR.DyniamicRoleName = 'HeadOfHouseHoldRoleName'
						AND NOT EXISTS (
							SELECT 1
							FROM Individual I
							WHERE I.IndividualId = DR.DyniamicRoleBuissnessId
								AND I.CountryId = @pCountryId
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
					,'Please enter valid HeadOfHouseHoldRoleName at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
						FROM @DyniamicRoles DR
						INNER JOIN @pImportFeed F ON Feed.Rownumber = DR.Rownumber
						WHERE DR.DyniamicRoleName = 'HeadOfHouseHoldRoleName'
							AND F.Rownumber = Feed.Rownumber
							AND NOT EXISTS (
								SELECT 1
								FROM Individual I
								WHERE I.IndividualId = DR.DyniamicRoleBuissnessId
									AND I.CountryId = @pCountryId
								)
						)
			END

			IF EXISTS (
					SELECT 1
					FROM @DyniamicRoles DR
					WHERE DR.DyniamicRoleName = 'MainShopperRoleName'
						AND NOT EXISTS (
							SELECT 1
							FROM Individual I
							WHERE I.IndividualId = DR.DyniamicRoleBuissnessId
								AND I.CountryId = @pCountryId
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
					,'Main Shopper should be exist at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
						FROM @DyniamicRoles DR
						INNER JOIN @pImportFeed F ON Feed.Rownumber = DR.Rownumber
						WHERE DR.DyniamicRoleName = 'MainShopperRoleName'
							AND F.Rownumber = Feed.Rownumber
							AND NOT EXISTS (
								SELECT 1
								FROM Individual I
								WHERE I.IndividualId = DR.DyniamicRoleBuissnessId
									AND I.CountryId = @pCountryId
								)
						)
			END

			IF EXISTS (
					SELECT 1
					FROM @DyniamicRoles DR
					WHERE DR.DyniamicRoleName = 'MainContact'
						AND NOT EXISTS (
							SELECT 1
							FROM Individual I
							WHERE I.IndividualId = DR.DyniamicRoleBuissnessId
								AND I.CountryId = @pCountryId
							)
					)
			BEGIN
				SET @Error = 1

				DECLARE @QueryMCExists NVARCHAR(MAX)

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
					,'Main Contact should be exist at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
						FROM @DyniamicRoles DR
						INNER JOIN @pImportFeed F ON Feed.Rownumber = DR.Rownumber
						WHERE DR.DyniamicRoleName = 'MainContact'
							AND F.Rownumber = Feed.Rownumber
							AND NOT EXISTS (
								SELECT 1
								FROM Individual I
								WHERE I.IndividualId = DR.DyniamicRoleBuissnessId
									AND I.CountryId = @pCountryId
								)
						)
			END

			IF EXISTS (
					SELECT 1
					FROM @pImportFeed
					WHERE GACode IS NULL
					)
				AND EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE ColumnName IN (
							'HomeAddressLine1'
							,'HomeAddressLine2'
							,'HomeAddressLine3'
							,'HomeAddressLine4'
							,'HomePostCode'
							)
					)
				AND EXISTS (
					SELECT 1
					FROM BusinessRulesContext BC
					INNER JOIN BusinessRule BR ON BC.GUIDReference = BR.Context_Id
						AND BC.Country_Id = BR.Country_Id
					WHERE BR.Country_Id = @pCountryId
						AND BC.NAME = 'GeographicAreaDetermination'
						AND [Type] = 'InRule'
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
					,'Geographic Area Code is not exists for the provided address at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				WHERE Feed.GACode IS NULL
			END

			IF (@Error > 0)
			BEGIN
				EXEC InsertImportFile 'ImportFileBusinessValidationError'
					,@pUser
					,@pFileId
					,@pCountryId

				RETURN;
			END

			CREATE TABLE #ImportFeedData (
				Rownumber INT NOT NULL
				,BusinessId NVARCHAR(300) NULL
				,GroupContact NVARCHAR(300) NULL
				,HomeAddressLine1 NVARCHAR(200) NULL
				,HomeAddressLine2 NVARCHAR(200) NULL
				,HomeAddressLine3 NVARCHAR(200) NULL
				,HomeAddressLine4 NVARCHAR(200) NULL
				,HomePostCode NVARCHAR(200) NULL
				,GroupAlias NVARCHAR(200) NULL
				,AliasContextName NVARCHAR(200) NULL
				,IndividualGUID UNIQUEIDENTIFIER
				,PostalAddressGuid UNIQUEIDENTIFIER
				,GroupId UNIQUEIDENTIFIER
				,GACode NVARCHAR(200) NULL
				,InterviewerCode BIGINT NULL
				)

			INSERT INTO #ImportFeedData (
				Rownumber
				,BusinessId
				,GroupContact
				,HomeAddressLine1
				,HomeAddressLine2
				,HomeAddressLine3
				,HomeAddressLine4
				,HomePostCode
				,IndividualGUID
				,PostalAddressGuid
				,GroupId
				,GACode
				,InterviewerCode
				)
			SELECT Feed.Rownumber
				,Feed.BusinessId
				,Feed.GroupContact
				,Feed.HomeAddressLine1
				,Feed.HomeAddressLine2
				,Feed.HomeAddressLine3
				,Feed.HomeAddressLine4
				,Feed.HomePostCode
				,I.GUIDReference
				,ISNULL((
						SELECT TOP 1 A.GUIDReference
						FROM OrderedContactMechanism OCM
						JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
							AND A.AddressType = 'PostalAddress'
						JOIN [AddressType] AT ON A.[Type_Id] = AT.Id
							AND AT.IsDefault = 1
							AND AT.DiscriminatorType = 'PostalAddressType'
						WHERE OCM.Candidate_Id = I.GUIDReference
							AND OCM.[Order] = 1
						), I.MainPostalAddress_Id)
				,CM.Group_Id
				,Feed.[GACode]
				,Feed.InterviewerCode
			FROM @pImportFeed Feed
			INNER JOIN Individual I ON I.IndividualId = Feed.BusinessId COLLATE SQL_Latin1_General_CP1_CI_AI
				AND i.CountryId = @pCountryId
			INNER JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
			INNER JOIN Collective C ON C.GUIDReference = CM.Group_Id
				AND C.Sequence = CAST(LEFT(Feed.BusinessId, CHARINDEX('-', Feed.BusinessId) - 1) AS INT)
				AND C.CountryId = @pCountryId
			INNER JOIN StateDefinition sd ON CM.State_Id = sd.Id

			IF OBJECT_ID('tempdb..#RepeatableData') IS NULL
			BEGIN
				CREATE TABLE #RepeatableData (
					AddressListGUID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
					,[Order] INT NULL
					,IndividualGuid UNIQUEIDENTIFIER NULL
					,AddressLine1 NVARCHAR(MAX) Collate Database_Default
					,AddressLine2 NVARCHAR(MAX) Collate Database_Default
					,AddressLine3 NVARCHAR(MAX) Collate Database_Default
					,AddressLine4 NVARCHAR(MAX) Collate Database_Default
					,PostCode NVARCHAR(MAX) Collate Database_Default
					,AddressType NVARCHAR(MAX) Collate Database_Default
					,AddressTypeGUID UNIQUEIDENTIFIER NULL
					,GroupId UNIQUEIDENTIFIER NULL
					)

				INSERT INTO #RepeatableData (
					[Order]
					,IndividualGuid
					,AddressLine1
					,AddressLine2
					,AddressLine3
					,AddressLine4
					,PostCode
					,AddressType
					,AddressTypeGUID
					,GroupId
					)
				SELECT REp.[Order]
					,FEED.IndividualGuid
					,REP.AddressLine1
					,REP.AddressLine2
					,REP.AddressLine3
					,REP.AddressLine4
					,REP.PostCode
					,REP.AddressType
					,ap.ID
					,Feed.GroupId
				FROM @RepeatableFeed REP
				INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
				INNER JOIN #AddressTypes AP ON REP.AddressType = AP.AddressType
			END

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
				,'Home address already exists at Row ' + CONVERT(VARCHAR, Feed2.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,FEED2.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM #RepeatableData FEED
			INNER JOIN #ImportFeedData FEED1 ON FEED.IndividualGuid = FEED1.IndividualGUID
			INNER JOIN @pImportFeed FEED2 ON FEED1.Rownumber = FEED2.Rownumber
			WHERE AddressType = 'Home'
				AND FEED.[Order] IS NULL
				AND EXISTS (
					SELECT *
					FROM OrderedContactMechanism OCM
					JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
					WHERE OCM.Candidate_Id = FEED.IndividualGuid
						AND A.Type_Id = FEED.AddressTypeGUID
					)

			IF @@ROWCOUNT > 0
				SET @Error = 1

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'Order'
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM #RepeatableData RData
						INNER JOIN OrderedContactMechanism OCM ON RData.IndividualGuid = OCM.Candidate_Id
							AND OCM.[Order] = RData.[Order]
						INNER JOIN [address] A ON A.GUIDReference = OCM.Address_Id
						INNER JOIN AddressType AT ON A.[Type_Id] = AT.Id
						INNER JOIN TranslationTerm TT ON At.Description_Id = TT.Translation_Id
						WHERE TT.VALUE != RData.AddressType
							AND TT.CultureCode = @pCultureCode
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
						,'Order is not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,FEED1.BusinessId
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM #RepeatableData Feed
					INNER JOIN #ImportFeedData FEED1 ON Feed.IndividualGuid = FEED1.IndividualGUID
					INNER JOIN OrderedContactMechanism OCM ON Feed.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = Feed.[Order]
					INNER JOIN [address] A ON A.GUIDReference = OCM.Address_Id
					INNER JOIN AddressType AT ON A.[Type_Id] = AT.Id
					INNER JOIN TranslationTerm TT ON At.Description_Id = TT.Translation_Id
					WHERE TT.VALUE != Feed.AddressType
						AND TT.CultureCode = @pCultureCode
				END
			END

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'AddressType'
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM #RepeatableData REP
						LEFT JOIN #AddressTypes AT ON AT.AddressType = REP.AddressType
						WHERE REP.AddressType IS NOT NULL
							AND AT.AddressType IS NULL
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
						,'AddressType IS NOT VALID at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,IMP.FullRow
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @RepeatableFeed Feed
					INNER JOIN @pImportFeed IMP ON FEED.Rownumber = IMP.Rownumber
					LEFT JOIN #AddressTypes AT ON AT.AddressType = Feed.AddressType
					WHERE Feed.AddressType IS NOT NULL
						AND AT.AddressType IS NULL
				END
			END

			CREATE TABLE #Demographics (
				DemographicId UNIQUEIDENTIFIER
				,GroupId UNIQUEIDENTIFIER
				,DemographicValue NVARCHAR(MAX)
				,DemographicType VARCHAR(10)
				,DemographicName NVARCHAR(MAX)
				,Rownumber INT
				,AttributeValueId UNIQUEIDENTIFIER DEFAULT NEWID()
				,FromRange DECIMAL(18, 2)
				,ToRange DECIMAL(18, 2)
				,MinimumLength INT
				,MaximumLength INT
				,DateFrom DATETIME
				,DateTo DATETIME
				,Today BIT
				,ColumnNumber INT
				)

			INSERT INTO #Demographics (
				DemographicId
				,GroupId
				,DemographicValue
				,DemographicType
				,DemographicName
				,Rownumber
				,FromRange
				,ToRange
				,MinimumLength
				,MaximumLength
				,DateFrom
				,DateTo
				,Today
				,ColumnNumber
				)
			SELECT A.GUIDReference
				,feed.GroupId
				,demo.DemographicValue
				,A.[Type]
				,demo.DemographicName
				,demo.Rownumber
				,A.[From]
				,A.[To]
				,A.[MinLength]
				,A.[MaxLength]
				,A.[DateFrom]
				,A.[DateTo]
				,A.Today
				,CP.RowNumber AS [ColumnNumber]
			FROM #ImportFeedData feed
			INNER JOIN @pDemographicData demo ON feed.Rownumber = demo.Rownumber
			INNER JOIN Attribute A ON A.[Key] = demo.DemographicName
				AND Country_Id = @pCountryId
			JOIN @pColumn CP ON A.[KEY] = CP.COLUMNNAME
				AND Country_Id = @pCountryId
			WHERE demo.DemographicValue IS NOT NULL
				AND demo.DemographicValue <> ''

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'String'
						AND LEN(DemographicValue) > 500
					)
			BEGIN
				SET @Error = 1

				DECLARE @StringDemoTbl [dbo].[DemoValidation]
				DECLARE @StringDemoTblTemp [dbo].[DemoValidation]

				INSERT INTO @StringDemoTblTemp (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'String'
					AND LEN(DemographicValue) > 500

				INSERT INTO @StringDemoTbl (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @StringDemoTblTemp e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'String'
					AND LEN(DemographicValue) > 500

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
					,T.Names + ' demographics are exceeds max length at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @StringDemoTbl T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'String'
						AND LEN(DemographicValue) NOT BETWEEN MinimumLength
							AND MaximumLength
					)
			BEGIN
				SET @Error = 1

				DECLARE @StringDemoTblRange [dbo].[DemoValidation]
				DECLARE @StringDemoTblTempRange [dbo].[DemoValidation]

				INSERT INTO @StringDemoTblTempRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'String'
					AND LEN(DemographicValue) NOT BETWEEN MinimumLength
						AND MaximumLength

				INSERT INTO @StringDemoTblRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @StringDemoTblTempRange e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'String'
					AND LEN(DemographicValue) NOT BETWEEN MinimumLength
						AND MaximumLength

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
					,T.Names + ' are not in range at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @StringDemoTblRange T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'Int'
						AND ISNUMERIC(DemographicValue) <> 1
					)
			BEGIN
				SET @Error = 1

				DECLARE @IntTable [dbo].[DemoValidation]
				DECLARE @IntTableTemp [dbo].[DemoValidation]

				INSERT INTO @IntTableTemp (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'Int'
					AND ISNUMERIC(DemographicValue) <> 1

				INSERT INTO @IntTable (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @IntTableTemp e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'Int'
					AND ISNUMERIC(DemographicValue) <> 1

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
					,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @IntTable T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'Int'
						AND ISNUMERIC(DemographicValue) = 1
						AND CAST(DemographicValue AS INT) NOT BETWEEN FromRange
							AND ToRange
					)
			BEGIN
				SET @Error = 1

				DECLARE @IntTableRange [dbo].[DemoValidation]
				DECLARE @IntTableTempRange [dbo].[DemoValidation]

				INSERT INTO @IntTableTempRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'Int'
					AND ISNUMERIC(DemographicValue) = 1
					AND CAST(DemographicValue AS INT) NOT BETWEEN FromRange
						AND ToRange

				INSERT INTO @IntTableRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @IntTableTempRange e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'Int'
					AND ISNUMERIC(DemographicValue) = 1
					AND CAST(DemographicValue AS INT) NOT BETWEEN FromRange
						AND ToRange

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
					,T.Names + ' demographics are not in range at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @IntTableRange T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			--Commented for PBI39098
			--SET DATEFORMAT dmy;
			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE LOWER(DemographicType) IN (
							'date'
							,'datetime'
							)
						AND ISDATE(DemographicValue) <> 1
					)
			BEGIN
				SET @Error = 1

				DECLARE @DateTable [dbo].[DemoValidation]
				DECLARE @DateTableTemp [dbo].[DemoValidation]

				--Commented for PBI39098
				--SET DATEFORMAT dmy;
				INSERT INTO @DateTableTemp (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE LOWER(DemographicType) IN (
						'date'
						,'datetime'
						)
					AND ISDATE(DemographicValue) <> 1

				INSERT INTO @DateTable (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @DateTableTemp e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE LOWER(DemographicType) IN (
						'date'
						,'datetime'
						)
					AND ISDATE(DemographicValue) <> 1

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
					,T.Names + ' date demographics are not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @DateTable T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE LOWER(DemographicType) IN (
							'date'
							,'datetime'
							)
						AND ISDATE(DemographicValue) = 1
						AND 0 = (
							CASE 
								WHEN Today = 1
									--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
									--AND CONVERT(DATETIME, DemographicValue, 103) <= CONVERT(DATETIME, @GetDate, 103)
									AND CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
									AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
									THEN 1
								WHEN Today = 0
									--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
									--AND CONVERT(DATETIME, DemographicValue, 103) <= DateTo
									AND (
										DateFrom IS NULL
										OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
										)
									AND (
										DateTo IS NULL
										OR CONVERT(DATETIME, DemographicValue, 101) <= DateTo
										)
									THEN 1
								ELSE 0
								END
							)
					)
			BEGIN
				SET @Error = 1

				DECLARE @DateTableRange [dbo].[DemoValidation]
				DECLARE @DateTableTempRange [dbo].[DemoValidation]

				--Commented for PBI39098
				--SET DATEFORMAT dmy;
				INSERT INTO @DateTableTempRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE LOWER(DemographicType) IN (
						'date'
						,'datetime'
						)
					AND ISDATE(DemographicValue) = 1
					AND 0 = (
						CASE 
							WHEN Today = 1
								--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
								--AND CONVERT(DATETIME, DemographicValue, 103) <= CONVERT(DATETIME, @GetDate, 103)
								AND CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
								AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
								THEN 1
							WHEN Today = 0
								--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
								--AND CONVERT(DATETIME, DemographicValue, 103) <= DateTo
								AND (
									DateFrom IS NULL
									OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
									)
								AND (
									DateTo IS NULL
									OR CONVERT(DATETIME, DemographicValue, 101) <= DateTo
									)
								THEN 1
							ELSE 0
							END
						)

				INSERT INTO @DateTableRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @DateTableTempRange e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE LOWER(DemographicType) IN (
						'date'
						,'datetime'
						)
					AND ISDATE(DemographicValue) = 1
					AND 0 = (
						CASE 
							WHEN Today = 1
								--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
								--AND CONVERT(DATETIME, DemographicValue, 103) <= CONVERT(DATETIME, @GetDate, 103)
								AND CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
								AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
								THEN 1
							WHEN Today = 0
								--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
								--AND CONVERT(DATETIME, DemographicValue, 103) <= DateTo
								AND (
									DateFrom IS NULL
									OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
									)
								AND (
									DateTo IS NULL
									OR CONVERT(DATETIME, DemographicValue, 101) <= DateTo
									)
								THEN 1
							ELSE 0
							END
						)

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
					,T.Names + ' date demographics are not range at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @DateTableRange T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics t
					WHERE DemographicType = 'Enum'
						AND NOT EXISTS (
							SELECT 1
							FROM dbo.EnumDefinition
							WHERE Demographic_Id = t.DemographicId
								AND Value = t.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
							)
					)
			BEGIN
				SET @Error = 1

				DECLARE @EnumTable [dbo].[DemoValidation]
				DECLARE @EnumTableTemp [dbo].[DemoValidation]

				INSERT INTO @EnumTableTemp (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'Enum'
					AND NOT EXISTS (
						SELECT 1
						FROM dbo.EnumDefinition
						WHERE Demographic_Id = t.DemographicId
							AND Value = t.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
						)

				INSERT INTO @EnumTable (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @EnumTableTemp e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'Enum'
					AND NOT EXISTS (
						SELECT 1
						FROM dbo.EnumDefinition
						WHERE Demographic_Id = t.DemographicId
							AND Value = t.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
						)

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
					,T.Names + ' enum demographics are not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @EnumTable T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'Float'
						AND ISNUMERIC(DemographicValue) <> 1
						AND (FLOOR(DemographicValue) <> CEILING(DemographicValue))
					)
			BEGIN
				SET @Error = 1

				DECLARE @FloatTable [dbo].[DemoValidation]
				DECLARE @FloatTableTemp [dbo].[DemoValidation]

				INSERT INTO @FloatTableTemp (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'Float'
					AND ISNUMERIC(DemographicValue) <> 1
					AND ISNUMERIC(DemographicValue) <> 1
					AND (FLOOR(DemographicValue) <> CEILING(DemographicValue))

				INSERT INTO @FloatTable (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @FloatTableTemp e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'Float'
					AND ISNUMERIC(DemographicValue) <> 1
					AND ISNUMERIC(DemographicValue) <> 1
					AND (FLOOR(DemographicValue) <> CEILING(DemographicValue))

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
					,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @FloatTable T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'Float'
						AND ISNUMERIC(DemographicValue) = 1
						AND (FLOOR(DemographicValue) = CEILING(DemographicValue))
						AND CAST(DemographicValue AS DECIMAL(18, 2)) NOT BETWEEN FromRange
							AND ToRange
					)
			BEGIN
				SET @Error = 1

				DECLARE @FloatTableRange [dbo].[DemoValidation]
				DECLARE @FloatTableTempRange [dbo].[DemoValidation]

				INSERT INTO @FloatTableTempRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'Float'
					AND ISNUMERIC(DemographicValue) = 1
					AND (FLOOR(DemographicValue) = CEILING(DemographicValue))
					AND CAST(DemographicValue AS DECIMAL(18, 2)) NOT BETWEEN FromRange
						AND ToRange

				INSERT INTO @FloatTableRange (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @FloatTableTempRange e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'Float'
					AND ISNUMERIC(DemographicValue) = 1
					AND (FLOOR(DemographicValue) = CEILING(DemographicValue))
					AND CAST(DemographicValue AS DECIMAL(18, 2)) NOT BETWEEN FromRange
						AND ToRange

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
					,T.Names + ' demographics are not in range at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @FloatTableRange T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END

			IF EXISTS (
					SELECT 1
					FROM #Demographics
					WHERE DemographicType = 'Boolean'
						AND LOWER(DemographicValue) NOT IN (
							'yes'
							,'true'
							,'no'
							,'false'
							,'1'
							,'0'
							)
					)
			BEGIN
				SET @Error = 1

				DECLARE @BooleanTable [dbo].[DemoValidation]
				DECLARE @BooleanTableTemp [dbo].[DemoValidation]

				INSERT INTO @BooleanTableTemp (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				FROM #Demographics t
				WHERE DemographicType = 'Boolean'
					AND LOWER(DemographicValue) NOT IN (
						'yes'
						,'true'
						,'no'
						,'false'
						,'1'
						,'0'
						)

				INSERT INTO @BooleanTable (
					Rownumber
					,Names
					)
				SELECT [Rownumber]
					,DemographicName
				--,STUFF((
				--		SELECT ', ' + DemographicName
				--		FROM #Demographics d
				--		INNER JOIN @BooleanTableTemp e ON d.[Rownumber] = e.[Rownumber]
				--			AND d.DemographicName = e.Names COLLATE SQL_Latin1_General_CP1_CI_AI
				--		WHERE d.[Rownumber] = t.[Rownumber]
				--		FOR XML PATH('')
				--		), 1, 2, '')
				FROM #Demographics t
				WHERE DemographicType = 'Boolean'
					AND LOWER(DemographicValue) NOT IN (
						'yes'
						,'true'
						,'no'
						,'false'
						,'1'
						,'0'
						)

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
					,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
					,@GetDate
					,Feed.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pImportFeed Feed
				INNER JOIN @BooleanTable T ON Feed.[Rownumber] = T.[Rownumber]
				JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
					AND T.Names = D.DemographicName
			END
		END TRY

		BEGIN CATCH
			INSERT INTO ImportAudit
			VALUES (
				NEWID()
				,1
				,1
				,'Error Occurred:' + ERROR_MESSAGE() + 'at Line:' + CAST(ERROR_LINE() AS NVARCHAR(MAX))
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

		IF (@Error > 0)
		BEGIN
			EXEC InsertImportFile 'ImportFileError'
				,@pUser
				,@pFileId
				,@pCountryId
		END
		ELSE
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION T

				/* Postal Address update */
				UPDATE A
				SET A.AddressLine1 = IFD.HomeAddressLine1
					,A.GPSUpdateTimestamp = @GetDate
					,A.GPSUser = @pUser
				FROM [dbo].[Address] A
				INNER JOIN #ImportFeedData IFD ON A.GUIDReference = IFD.PostalAddressGuid
				WHERE LEN(ISNULL(IFD.HomeAddressLine1, '')) > 0

				UPDATE A
				SET A.AddressLine2 = IFD.HomeAddressLine2
					,A.GPSUpdateTimestamp = @GetDate
					,A.GPSUser = @pUser
				FROM [dbo].[Address] A
				INNER JOIN #ImportFeedData IFD ON A.GUIDReference = IFD.PostalAddressGuid
				WHERE IFD.HomeAddressLine2 IS NOT NULL

				UPDATE A
				SET A.AddressLine3 = IFD.HomeAddressLine3
					,A.GPSUpdateTimestamp = @GetDate
					,A.GPSUser = @pUser
				FROM [dbo].[Address] A
				INNER JOIN #ImportFeedData IFD ON A.GUIDReference = IFD.PostalAddressGuid
				WHERE IFD.HomeAddressLine3 IS NOT NULL

				UPDATE A
				SET A.AddressLine4 = IFD.HomeAddressLine4
					,A.GPSUpdateTimestamp = @GetDate
					,A.GPSUser = @pUser
				FROM [dbo].[Address] A
				INNER JOIN #ImportFeedData IFD ON A.GUIDReference = IFD.PostalAddressGuid
				WHERE IFD.HomeAddressLine4 IS NOT NULL

				UPDATE A
				SET A.PostCode = IFD.HomePostCode
					,A.GPSUpdateTimestamp = @GetDate
					,A.GPSUser = @pUser
				FROM [dbo].[Address] A
				INNER JOIN #ImportFeedData IFD ON A.GUIDReference = IFD.PostalAddressGuid
				WHERE IFD.HomePostCode IS NOT NULL

				/*************MULTIPLE ADDRESS HANLDE**************/
				IF EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE [ColumnName] = 'AddressLine1'
						)
				BEGIN
					UPDATE A
					SET A.AddressLine1 = FEED.AddressLine1
						,A.GPSUpdateTimestamp = @GetDate
						,A.GPSUser = @pUser
					FROM #RepeatableData FEED
					INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = FEED.[Order]
					INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
					WHERE A.[AddressType] = 'PostalAddress'
						AND OCM.[Order] = FEED.[ORDER]
						AND FEED.AddressLine1 IS NOT NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE [ColumnName] = 'AddressLine2'
						)
				BEGIN
					UPDATE A
					SET A.AddressLine2 = FEED.AddressLine2
						,A.GPSUpdateTimestamp = @GetDate
						,A.GPSUser = @pUser
					FROM #RepeatableData FEED
					INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = FEED.[ORDER]
					INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
					WHERE A.[AddressType] = 'PostalAddress'
						AND OCM.[Order] = FEED.[ORDER]
						AND FEED.AddressLine2 IS NOT NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE [ColumnName] = 'AddressLine3'
						)
				BEGIN
					UPDATE A
					SET A.AddressLine3 = FEED.AddressLine3
						,A.GPSUpdateTimestamp = @GetDate
						,A.GPSUser = @pUser
					FROM #RepeatableData FEED
					INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = FEED.[ORDER]
					INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
					WHERE A.[AddressType] = 'PostalAddress'
						AND OCM.[Order] = FEED.[ORDER]
						AND FEED.AddressLine3 IS NOT NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE [ColumnName] = 'AddressLine4'
						)
				BEGIN
					UPDATE A
					SET A.AddressLine4 = FEED.AddressLine4
						,A.GPSUpdateTimestamp = @GetDate
						,A.GPSUser = @pUser
					FROM #RepeatableData FEED
					INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = FEED.[ORDER]
					INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
					WHERE A.[AddressType] = 'PostalAddress'
						AND OCM.[Order] = FEED.[ORDER]
						AND FEED.AddressLine4 IS NOT NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE [ColumnName] = 'PostCode'
						)
				BEGIN
					UPDATE A
					SET A.PostCode = FEED.PostCode
						,A.GPSUpdateTimestamp = @GetDate
						,A.GPSUser = @pUser
					FROM #RepeatableData FEED
					INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = FEED.[ORDER]
					INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
					WHERE A.[AddressType] = 'PostalAddress'
						AND OCM.[Order] = FEED.[ORDER]
						AND FEED.PostCode IS NOT NULL
				END

				IF EXISTS (
						SELECT 1
						FROM #RepeatableData
						WHERE AddressType IS NOT NULL
							AND [Order] IS NULL
						)
				BEGIN
					INSERT INTO [Address] (
						GUIDReference
						,AddressLine1
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,AddressLine2
						,AddressLine3
						,AddressLine4
						,PostCode
						,[Type_Id]
						,AddressType
						,Country_Id
						)
					SELECT FEED.AddressListGUID
						,FEED.AddressLine1
						,@pUser
						,@GetDate
						,@GetDate
						,FEED.AddressLine2
						,FEED.AddressLine3
						,FEED.AddressLine4
						,FEED.PostCode
						,FEED.AddressTypeGUID
						,'PostalAddress'
						,@pCountryId
					FROM #RepeatableData FEED
					WHERE AddressType IS NOT NULL
						AND [Order] IS NULL

					INSERT INTO ORDEREDCONTACTMECHANISM (
						Id
						,[Order]
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Candidate_Id
						,Address_Id
						,Country_Id
						)
					SELECT NEWID() AS Id
						,(
							SELECT ISNULL(MAX([ORDER]), 0) + 1
							FROM ORDEREDCONTACTMECHANISM
							WHERE Candidate_Id = feed.IndividualGuid
							) AS [Order]
						,@puser AS GPSUser
						,@GetDate AS GPSUpdateTimestamp
						,@GetDate AS CreationTimeStamp
						,feed.IndividualGuid AS Candidate_Id
						,feed.AddressListGUID AS Address_Id
						,@pCountryId
					FROM #RepeatableData feed
					WHERE AddressType IS NOT NULL
						AND [Order] IS NULL
				END

				/*****************************************/
				/* Address change Action task */
				DECLARE @ActiontaskId UNIQUEIDENTIFIER = newid()
				DECLARE @countryid UNIQUEIDENTIFIER
				DECLARE @TypeTranslationid UNIQUEIDENTIFIER
				DECLARE @TranslaionIds UNIQUEIDENTIFIER
				DECLARE @AssigneeId UNIQUEIDENTIFIER
				DECLARE @GUIDRefActionTask UNIQUEIDENTIFIER

				--DECLARE @getdate DATETIME = @GetDate
				SET @AssigneeId = (
						SELECT TOP 1 Id
						FROM IdentityUser
						WHERE UserName = @pUser
							AND Country_Id = @pCountryId
						)
				SET @TranslaionIds = (
						SELECT TOP 1 TranslationId
						FROM Translation
						WHERE KeyName = 'AddressChanges'
						)
				SET @TypeTranslationid = (
						SELECT TOP 1 TranslationId
						FROM Translation
						WHERE KeyName = 'DealtByCommunicationTeamActionTaskTypeTypeDescriptor'
						)
				SET @GUIDRefActionTask = (
						SELECT TOP 1 GUIDReference
						FROM ActionTaskType axc
						WHERE TagTranslation_Id = @TranslaionIds
							AND axc.Country_Id = @pCountryId
						)

				IF (
						@pCountryId IN (
							SELECT C.CountryId
							FROM FieldConfiguration FC
							INNER JOIN Country C ON C.Configuration_Id = FC.CountryConfiguration_Id
							WHERE [Key] = 'AddressCardchange'
								AND [Visible] = 1
							)
						)
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM ActionTaskType
							WHERE [TagTranslation_Id] = @TranslaionIds
								AND [Country_Id] = @pCountryId
							)
					BEGIN
						INSERT INTO [dbo].[ActionTaskType] (
							[GUIDReference]
							,[IsForDpa]
							,[IsForFqs]
							,[GPSUser]
							,[GPSUpdateTimestamp]
							,[CreationTimeStamp]
							,[Duration]
							,[TagTranslation_Id]
							,[DescriptionTranslation_Id]
							,[TypeTranslation_Id]
							,[Country_Id]
							,[Type]
							,[IsClosed]
							)
						VALUES (
							NEWID()
							,0
							,0
							,@pUser
							,@getdate
							,@getdate
							,NULL
							,@TranslaionIds
							,@TranslaionIds
							,@TypeTranslationid
							,@pCountryId
							,'DealtByCommunicationTeam'
							,0
							)
					END

					IF (@GUIDRefActionTask IS NOT NULL)
					BEGIN
						INSERT INTO [dbo].[ActionTask] (
							[GUIDReference]
							,[StartDate]
							,[EndDate]
							,[CompletionDate]
							,[ActionComment]
							,[InternalOrExternal]
							,[GPSUser]
							,[GPSUpdateTimestamp]
							,[CreationTimeStamp]
							,[State]
							,[CommunicationCompletion_Id]
							,[ActionTaskType_Id]
							,[Candidate_Id]
							,[Country_Id]
							,[FormId]
							,[Assignee_Id]
							,[Panel_Id]
							)
						SELECT @ActiontaskId
							,@getdate
							,@getdate
							,@getdate
							,'Postal Address type has changed'
							,0
							,@pUser
							,@getdate
							,@getdate
							,4
							,NULL
							,@GUIDRefActionTask
							,IFD.GroupId
							,@pCountryId
							,NULL
							,@AssigneeId
							,NULL
						FROM #ImportFeedData IFD
						WHERE LEN(ISNULL(IFD.HomeAddressLine1, '')) > 0
							OR IFD.HomeAddressLine2 IS NOT NULL
							OR IFD.HomeAddressLine3 IS NOT NULL
							OR IFD.HomeAddressLine4 IS NOT NULL
							OR IFD.HomePostCode IS NOT NULL
					END
				END

				/* Postal Address update */
				/* Group contact updtae */
				CREATE TABLE #CGCHs (
					CollectiveGroupContactHistoryId UNIQUEIDENTIFIER
					,GroupId UNIQUEIDENTIFIER
					)

				UPDATE CI
				SET CI.Interviewer_Id = Intr.Id
					,CI.GPSUpdateTimestamp = @GetDate
					,CI.GPSUser = @pUser
				FROM [dbo].[Interviewer] Intr
				JOIN #ImportFeedData IFD ON Intr.InterviewerCode = IFD.InterviewerCode
				INNER JOIN Individual I ON I.IndividualId = IFD.BusinessId COLLATE SQL_Latin1_General_CP1_CI_AI
					AND I.CountryId = @pCountryId
				INNER JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
				INNER JOIN Collective CI ON CI.GUIDReference = CM.Group_Id
					AND CI.Sequence = CAST(LEFT(IFD.BusinessId, CHARINDEX('-', IFD.BusinessId) - 1) AS INT)
					AND CI.CountryId = @pCountryId
				WHERE Intr.Country_Id = @pCountryId

				UPDATE C
				SET C.GroupContact_Id = i.GUIDReference
					,C.GPSUpdateTimestamp = @GetDate
					,C.GPSUser = @pUser
				FROM Collective C
				INNER JOIN #ImportFeedData IFD ON C.GUIDReference = IFD.GroupId
				INNER JOIN Individual I ON I.IndividualId = IFD.GroupContact COLLATE SQL_Latin1_General_CP1_CI_AI
					AND I.CountryId = @pCountryId

				INSERT INTO #CGCHs (
					CollectiveGroupContactHistoryId
					,GroupId
					)
				SELECT T.CGCHId
					,T.GroupId
				FROM (
					SELECT ROW_NUMBER() OVER (
							ORDER BY CGCH.CreationTimeStamp DESC
							) AS RowId
						,CGCH.Id AS CGCHId
						,IFD.GroupId
					FROM CollectiveGroupContactHistory CGCH
					INNER JOIN #ImportFeedData IFD ON CGCH.Group_Id = IFD.GroupId
					) T

				UPDATE CGC
				SET CGC.DateTo = @GetDate
					,CGC.GPSUpdateTimestamp = @GetDate
					,CGC.GPSUser = @pUser
				FROM CollectiveGroupContactHistory CGC
				INNER JOIN #CGCHs CGCHS ON CGC.Id = CGCHS.CollectiveGroupContactHistoryId

				INSERT [dbo].[CollectiveGroupContactHistory] (
					[Id]
					,[DateFrom]
					,[DateTo]
					,[CreationTimeStamp]
					,[GPSUser]
					,[GPSUpdateTimestamp]
					,[Group_Id]
					,[Individual_Id]
					,[Country_Id]
					)
				SELECT NEWID()
					,CONVERT(DATE, @GetDate)
					,NULL
					,@GetDate
					,@pUser
					,@GetDate
					,feed.GroupId
					,I.GUIDReference
					,@pCountryId
				FROM #ImportFeedData feed
				INNER JOIN Individual I ON I.IndividualId = feed.GroupContact COLLATE SQL_Latin1_General_CP1_CI_AI
					AND I.CountryId = @pCountryId

				/* Group contact updtae */
				/*GA Update*/
				UPDATE C
				SET C.GeographicArea_Id = GA.GUIDReference
					,C.GPSUpdateTimestamp = @GetDate
					,C.GPSUser = @pUser
				FROM #ImportFeedData Feed
				INNER JOIN Individual I ON Feed.IndividualGUID = I.GUIDReference
				INNER JOIN Candidate C ON I.GUIDReference = C.GUIDReference
				INNER JOIN Country Country ON Country.CountryId = C.Country_Id
				LEFT JOIN GeographicArea GA ON GA.Code = Feed.GACode COLLATE SQL_Latin1_General_CP1_CI_AI
					AND EXISTS (
						SELECT GUIDReference
						FROM dbo.Respondent R
						WHERE R.GUIDReference = GA.GUIDReference
							AND R.CountryID = @pCountryId
						)
				LEFT JOIN GeographicAreas GAs ON GAs.Code = GA.Code COLLATE SQL_Latin1_General_CP1_CI_AI
					AND GAs.CountryISO2A = Country.CountryISO2A
				WHERE Feed.GACode IS NOT NULL
					AND EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE ColumnName IN (
								'HomeAddressLine1'
								,'HomeAddressLine2'
								,'HomeAddressLine3'
								,'HomeAddressLine4'
								,'HomePostCode'
								)
						)

				UPDATE C
				SET C.GeographicArea_Id = GA.GUIDReference
					,C.GPSUpdateTimestamp = @GetDate
					,C.GPSUser = @pUser
				FROM #ImportFeedData Feed
				INNER JOIN Collective G ON Feed.GroupId = G.GUIDReference
				INNER JOIN Candidate C ON G.GUIDReference = C.GUIDReference
				INNER JOIN Country Country ON Country.CountryId = C.Country_Id
				LEFT JOIN GeographicArea GA ON GA.Code = Feed.GACode COLLATE SQL_Latin1_General_CP1_CI_AI
					AND EXISTS (
						SELECT GUIDReference
						FROM dbo.Respondent R
						WHERE R.GUIDReference = GA.GUIDReference
							AND R.CountryID = @pCountryId
						)
				LEFT JOIN GeographicAreas GAs ON GAs.Code = GA.Code COLLATE SQL_Latin1_General_CP1_CI_AI
					AND GAs.CountryISO2A = Country.CountryISO2A
				WHERE Feed.GACode IS NOT NULL
					AND EXISTS (
						SELECT 1
						FROM @pColumn
						WHERE ColumnName IN (
								'HomeAddressLine1'
								,'HomeAddressLine2'
								,'HomeAddressLine3'
								,'HomeAddressLine4'
								,'HomePostCode'
								)
						)

				/*GA Update*/
				/* Dynamic Roles */
				CREATE TABLE #DyniamicRoles (
					DynamicRoleId UNIQUEIDENTIFIER
					,GroupId UNIQUEIDENTIFIER
					,IndividualId UNIQUEIDENTIFIER
					)

				INSERT INTO #DyniamicRoles (
					DynamicRoleId
					,GroupId
					,IndividualId
					)
				SELECT DR.DynamicRoleId
					,feed.GroupId
					,I.GUIDReference
				FROM @DyniamicRoles TDR
				INNER JOIN Translation T ON T.KeyName = TDR.DyniamicRoleName
				INNER JOIN DynamicRole DR ON DR.Translation_Id = T.TranslationId
					AND DR.Country_Id = @pCountryId
				INNER JOIN #ImportFeedData feed ON feed.Rownumber = TDR.[Rownumber]
				INNER JOIN Individual I ON I.IndividualId = TDR.DyniamicRoleBuissnessId COLLATE SQL_Latin1_General_CP1_CI_AI --TDR.DyniamicRoleBuissnessId
					AND I.CountryId = @pCountryId

				UPDATE DRA
				SET DRA.Candidate_Id = TDR.IndividualId
					,DRA.GPSUpdateTimestamp = @GetDate
					,DRA.GPSUser = @pUser
				FROM DynamicRoleAssignment DRA
				INNER JOIN #DyniamicRoles TDR ON TDR.GroupId = DRA.Group_Id
					AND TDR.DynamicRoleId = DRA.DynamicRole_Id

				UPDATE DRAH
				SET DRAH.DateTo = @GetDate
					,DRAH.GPSUpdateTimestamp = @GetDate
					,DRAH.GPSUser = @pUser
				FROM DynamicRoleAssignment DRA
				INNER JOIN #DyniamicRoles TDR ON TDR.GroupId = DRA.Group_Id
					AND TDR.DynamicRoleId = DRA.DynamicRole_Id
				INNER JOIN DynamicRoleAssignmentHistory DRAH ON DRAH.DynamicRoleAssignment_Id = DRA.DynamicRoleAssignmentId
					AND DRAH.DynamicRole_Id = TDR.DynamicRoleId
					AND DRAH.DateTo IS NOT NULL

				INSERT INTO DynamicRoleAssignment (
					DynamicRoleAssignmentId
					,DynamicRole_Id
					,Candidate_Id
					,Group_Id
					,CreationTimeStamp
					,GPSUpdateTimestamp
					,GPSUser
					,Country_Id
					)
				SELECT NEWID()
					,DR.DynamicRoleId
					,DR.IndividualId
					,DR.GroupId
					,@GetDate
					,@GetDate
					,@pUser
					,@pCountryId
				FROM #DyniamicRoles DR
				WHERE NOT EXISTS (
						SELECT 1
						FROM DynamicRoleAssignment DRA
						WHERE DR.GroupId = DRA.Group_Id
							AND DR.DynamicRoleId = DRA.DynamicRole_Id
						)

				INSERT INTO DynamicRoleAssignmentHistory (
					GUIDReference
					,DateFrom
					,CreationTimeStamp
					,GPSUser
					,GPSUpdateTimestamp
					,DynamicRoleAssignment_Id
					,DynamicRole_Id
					,Candidate_Id
					)
				SELECT NEWID()
					,@GetDate
					,@GetDate
					,@pUser
					,@GetDate
					,DRA.DynamicRoleAssignmentId
					,DRA.DynamicRole_Id
					,DRA.Candidate_Id
				FROM DynamicRoleAssignment DRA
				INNER JOIN #DyniamicRoles TDR ON TDR.GroupId = DRA.Group_Id
					AND TDR.DynamicRoleId = DRA.DynamicRole_Id
					AND TDR.IndividualId = DRA.Candidate_Id

				/* Dynamic Roles */
				/* Demographics */
				UPDATE AV
				SET av.Value = D.DemographicValue
					,av.[Discriminator] = 'StringAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				WHERE D.DemographicType = 'String'

				UPDATE AV
				SET av.Value = D.DemographicValue
					,av.[Discriminator] = 'IntAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				WHERE D.DemographicType = 'Int'

				UPDATE AV
				SET av.Value = D.DemographicValue
					,av.[Discriminator] = 'FloatAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				WHERE D.DemographicType = 'Float'

				UPDATE AV
				SET av.Value = D.DemographicValue
					,av.[Discriminator] = 'DateAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				WHERE LOWER(D.DemographicType) IN (
						'date'
						,'datetime'
						)

				UPDATE AV
				SET av.Value = (
						CASE DemographicValue
							WHEN 'Yes'
								THEN 1
							WHEN 'No'
								THEN 0
							WHEN 'TRUE'
								THEN 1
							WHEN 'FALSE'
								THEN 0
							ELSE DemographicValue
							END
						)
					,av.[Discriminator] = 'BooleanAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				WHERE DemographicType = 'Boolean'

				UPDATE AV
				SET av.[EnumDefinition_Id] = ED.Id
					,av.[Discriminator] = 'EnumAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				INNER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.DemographicId
					AND ED.Value = D.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
				WHERE D.DemographicType = 'Enum'

				-- for update
				INSERT ImportsPostBackToMorpheusValues (
					Id
					,NamedAliasKey
					,DemographicId
					,CandidateId
					,MessageType
					,DemographicValue
					,ImportFileId
					,ProcessedStatus
					,GPSUser
					,CreationTimeStamp
					,GPSUpdateTimestamp
					)
				SELECT NEWID()
					,NA.[Key]
					,D.DemographicId
					,D.GroupId
					,IPM.MessageType
					,D.DemographicValue
					,@pFileId
					,0
					,@pUser
					,@GetDate
					,@GetDate
				FROM #Demographics D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				INNER JOIN NamedAlias NA ON NA.Candidate_Id = D.GroupId
				INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id = NAC.NamedAliasContextId
				INNER JOIN ImportsPostBackToMorpheusConfiguration IPM ON IPM.DemogrpahicId = D.DemographicId
				INNER JOIN Country C ON C.CountryId = IPM.CountryId
					AND NAC.Country_Id = C.CountryId
				INNER JOIN KeyAppSetting KA ON KA.KeyName = IPM.EnableKeyAppSettingKey
				LEFT JOIN KeyValueAppSetting KVA ON KA.GUIDReference = KVA.KeyAppSetting_Id
					AND KVA.Country_Id = C.CountryId
				WHERE NAC.NamedAliasContextId = IPM.NamedAliasContextId
					AND C.CountryId = @pCountryId
					AND NAC.Country_Id = @pCountryId
					AND (
						LOWER((
								CASE 
									WHEN (KVA.Value IS NULL)
										THEN KA.DefaultValue
									ELSE KVA.Value
									END
								)) = 'true'
						AND IPM.IsPostBackRequired = 1
						)

				SELECT AttributeValueId AS AttributeValueId
					,DemographicId AS DemographicId
					,GroupId AS GroupId
					,NULL AS RespondentId
					,@pUser AS [User]
					,@GETDATE AS GPSUpdateTimestamp
					,@GETDATE AS CreationTimeStamp
					,NULL AS Address_Id
					,DemographicType
					,DemographicValue
				INTO #InsertAttributeValue
				FROM #Demographics D
				WHERE NOT EXISTS (
						SELECT 1
						FROM AttributeValue AV
						WHERE AV.DemographicId = D.DemographicId
							AND AV.CandidateId = D.GroupId
						)

				INSERT INTO AttributeValue (
					GUIDReference
					,DemographicId
					,CandidateId
					,RespondentId
					,GPSUser
					,GPSUpdateTimestamp
					,CreationTimeStamp
					,Address_Id
					,[Value]
					,[ValueDesc]
					,[EnumDefinition_Id]
					,[FreeText]
					,[Discriminator]
					,Country_Id
					)
				SELECT AttributeValueId
					,DemographicId
					,GroupId
					,NULL
					,[User]
					,@GETDATE
					,@GETDATE
					,NULL
					,CASE 
						WHEN DemographicType = 'String'
							THEN DemographicValue
						WHEN DemographicType = 'Int'
							THEN DemographicValue
						WHEN DemographicType = 'Float'
							THEN DemographicValue
						WHEN LOWER(DemographicType) IN (
								'date'
								,'datetime'
								)
							THEN DemographicValue
						WHEN DemographicType = 'Boolean'
							THEN CASE DemographicValue
									WHEN 'Yes'
										THEN '1'
									WHEN 'No'
										THEN '0'
									WHEN 'TRUE'
										THEN '1'
									WHEN 'FALSE'
										THEN '0'
									ELSE DemographicValue
									END
						END
					,NULL
					,NULL
					,NULL
					,CASE 
						WHEN DemographicType = 'String'
							THEN 'StringAttributeValue'
						WHEN DemographicType = 'Int'
							THEN 'IntAttributeValue'
						WHEN DemographicType = 'Float'
							THEN 'FloatAttributeValue'
						WHEN LOWER(DemographicType) IN (
								'date'
								,'datetime'
								)
							THEN 'DateAttributeValue'
						WHEN DemographicType = 'Boolean'
							THEN 'BooleanAttributeValue'
						END
					,@pCountryId
				FROM #InsertAttributeValue

				UPDATE av
				SET av.[EnumDefinition_Id] = ED.Id
					,av.[Discriminator] = 'EnumAttributeValue'
					,av.GPSUpdateTimestamp = @GetDate
					,av.GPSUser = @pUser
				FROM #Demographics D
				INNER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.DemographicId
					AND ED.Value = D.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
				LEFT JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				WHERE DemographicType = 'Enum'
					AND NOT EXISTS (
						SELECT 1
						FROM EnumAttributeValue EAV
						INNER JOIN AttributeValue AV ON AV.GUIDReference = EAV.GUIDReference
							AND AV.DemographicId = D.DemographicId
							AND AV.CandidateId = D.GroupId
						)

				-- for insert 
				INSERT ImportsPostBackToMorpheusValues (
					Id
					,NamedAliasKey
					,DemographicId
					,CandidateId
					,MessageType
					,DemographicValue
					,ImportFileId
					,ProcessedStatus
					,GPSUser
					,CreationTimeStamp
					,GPSUpdateTimestamp
					)
				SELECT NEWID()
					,NA.[Key]
					,D.DemographicId
					,D.GroupId
					,IPM.MessageType
					,D.DemographicValue
					,@pFileId
					,0
					,@pUser
					,@GetDate
					,@GetDate
				FROM #InsertAttributeValue D
				INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
					AND AV.CandidateId = D.GroupId
				INNER JOIN NamedAlias NA ON NA.Candidate_Id = D.GroupId
				INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id = NAC.NamedAliasContextId
				INNER JOIN ImportsPostBackToMorpheusConfiguration IPM ON IPM.DemogrpahicId = D.DemographicId
				INNER JOIN Country C ON C.CountryId = IPM.CountryId
					AND NAC.Country_Id = C.CountryId
				INNER JOIN KeyAppSetting KA ON KA.KeyName = IPM.EnableKeyAppSettingKey
				LEFT JOIN KeyValueAppSetting KVA ON KA.GUIDReference = KVA.KeyAppSetting_Id
					AND KVA.Country_Id = C.CountryId
				WHERE NAC.NamedAliasContextId = IPM.NamedAliasContextId
					AND C.CountryId = @pCountryId
					AND NAC.Country_Id = @pCountryId
					AND (
						LOWER((
								CASE 
									WHEN (KVA.Value IS NULL)
										THEN KA.DefaultValue
									ELSE KVA.Value
									END
								)) = 'true'
						AND IPM.IsPostBackRequired = 1
						)

				/*Named Alias*/
				CREATE TABLE #Aliasfeed (
					NamedAliasContextId UNIQUEIDENTIFIER
					,GroupId UNIQUEIDENTIFIER
					,NamedAliasKey NVARCHAR(50)
					,NamedAliasKeyValue NVARCHAR(50)
					)

				INSERT INTO #Aliasfeed (
					NamedAliasContextId
					,GroupId
					,NamedAliasKey
					,NamedAliasKeyValue
					)
				SELECT NAC.NamedAliasContextId
					,feed.GroupId
					,NAC.NAME
					,aliasfeed.[NamedAliasValue]
				FROM #ImportFeedData feed
				INNER JOIN @AliasImportFeed aliasfeed ON feed.Rownumber = aliasfeed.Rownumber
				INNER JOIN NamedAliasContext NAC ON NAC.NAME = aliasfeed.NamedAliasKey
					AND NAC.Country_Id = @pCountryId

				UPDATE NA
				SET NA.[Key] = AF.NamedAliasKeyValue
					,NA.GPSUpdateTimestamp = @GetDate
					,NA.GPSUser = @pUser
				FROM #Aliasfeed AF
				INNER JOIN NamedAlias NA ON NA.AliasContext_Id = AF.NamedAliasContextId
					AND NA.Candidate_Id = AF.GroupId

				INSERT [dbo].[NamedAlias] (
					[NamedAliasId]
					,[Key]
					,[AliasContext_Id]
					,[GPSUser]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					,[Guid]
					,[Incentive_Id]
					,[Candidate_Id]
					,[Type]
					)
				SELECT NEWID()
					,AF.NamedAliasKeyValue
					,AF.NamedAliasContextId
					,@pUser
					,@GetDate
					,@GetDate
					,NULL
					,NULL
					,AF.GroupId
					,N'CandidateAlias'
				FROM #Aliasfeed AF
				WHERE NOT EXISTS (
						SELECT 1
						FROM NamedAlias NA
						WHERE NA.AliasContext_Id = AF.NamedAliasContextId
							AND NA.Candidate_Id = AF.GroupId
						)

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
					,'Error Occurred:' + ERROR_MESSAGE() + 'at Line:' + CAST(ERROR_LINE() AS NVARCHAR(MAX))
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

		IF OBJECT_ID('tempdb..#AddressTypes') IS NOT NULL
		BEGIN
			DROP TABLE #AddressTypes
		END

		IF OBJECT_ID('tempdb..#RepeatableData') IS NOT NULL
		BEGIN
			DROP TABLE #RepeatableData
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
