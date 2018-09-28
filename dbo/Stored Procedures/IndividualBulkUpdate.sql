
CREATE PROCEDURE [dbo].[IndividualBulkUpdate] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed ImportFeed1 READONLY
	,@pRepeatableData PanelTableType READONLY
	,@pDemographicData Demographics READONLY
	,@AliasImportFeed NamedAliasImportFeed READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @GetDate DATETIME
	DECLARE @ColumnNumber INT = 0

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
		,@isGACodeError BIT = 0

	SET @Error = 0

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

	DECLARE @maxInsertCount INT

	SET @maxInsertCount = (
			SELECT MAX(Rownumber)
			FROM @pImportFeed
			)
	SET @maxColumnCount = (
			SELECT MAX(Rownumber)
			FROM @pColumn
			)

	DECLARE @REPETSEPARATOER NVARCHAR(MAX)

	SET @REPETSEPARATOER = REPLICATE('|', @maxColumnCount)

	DECLARE @FirstNameReqired BIT;
	DECLARE @MiddleNameReqired BIT;
	DECLARE @LastNameReqired BIT;
	DECLARE @GroupMembershipNonResidentId UNIQUEIDENTIFIER
	DECLARE @GroupMembershipDeceasedId UNIQUEIDENTIFIER
	DECLARE @PanelistDroppedOffStateId UNIQUEIDENTIFIER

	SELECT @GroupMembershipNonResidentId = sd.Id
	FROM StateDefinition sd
	INNER JOIN Country c ON c.CountryId = sd.Country_Id
	WHERE c.CountryId = @pCountryId
		AND sd.Code = 'GroupMembershipNonResident'

	SELECT @GroupMembershipDeceasedId = sd.Id
	FROM StateDefinition sd
	INNER JOIN Country c ON c.CountryId = sd.Country_Id
	WHERE c.CountryId = @pCountryId
		AND sd.Code = 'GroupMembershipDeceased'

	SELECT @PanelistDroppedOffStateId = sd.Id
	FROM StateDefinition sd
	INNER JOIN Country c ON c.CountryId = sd.Country_Id
	WHERE c.CountryId = @pCountryId
		AND sd.Code = 'PanelistDroppedOffState'

	SET @FirstNameReqired = (
			SELECT [Required]
			FROM FieldConfiguration FC
			INNER JOIN Country C ON FC.CountryConfiguration_Id = C.Configuration_Id
				AND C.CountryId = @pCountryId
				AND FC.[Key] = 'FirstName'
			)
	SET @MiddleNameReqired = (
			SELECT [Required]
			FROM FieldConfiguration FC
			INNER JOIN Country C ON FC.CountryConfiguration_Id = C.Configuration_Id
				AND C.CountryId = @pCountryId
				AND FC.[Key] = 'MiddleName'
			)
	SET @LastNameReqired = (
			SELECT [Required]
			FROM FieldConfiguration FC
			INNER JOIN Country C ON FC.CountryConfiguration_Id = C.Configuration_Id
				AND C.CountryId = @pCountryId
				AND FC.[Key] = 'LastName'
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

	DECLARE @ImportFormatId UNIQUEIDENTIFIER

	SELECT @ImportFormatId = ImportFormat_Id
	FROM ImportFile
	WHERE GUIDReference = @pFileId

	IF OBJECT_ID('tempdb..#AddressTypes') IS NOT NULL
		DROP TABLE #AddressTypes

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
			,'Import columns are not match with import format'
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

	IF EXISTS (
			SELECT 1
			FROM @pColumn
			WHERE [ColumnName] = 'PanelRoleCode'
				AND NOT EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'PanelCode'
					)
			)
	BEGIN
		SET @Error = 1

		INSERT INTO ImportAudit
		VALUES (
			NEWID()
			,1
			,1
			,'PanelCode Column is required'
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

	IF (@importDataCount > 0)
	BEGIN
		WHILE (@columnsincrement <= @maxColumnCount)
		BEGIN
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
						,'BusinessId Mandatory at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[BusinessId] IS NULL
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
						,'Duplicate BusinessId''s are exists at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE BusinessId IN (
							SELECT BusinessId
							FROM @pImportFeed
							GROUP BY BusinessId
							HAVING count(BusinessId) > 1
							)
				END

				IF EXISTS (
						SELECT 1
						FROM @pImportFeed Feed
						LEFT JOIN Individual I ON I.IndividualId = Feed.BusinessId
							AND I.CountryId = @pCountryId
						WHERE I.IndividualId IS NULL
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
						,'BusinessId not exits at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					LEFT JOIN Individual I ON I.IndividualId = Feed.BusinessId
						AND I.CountryId = @pCountryId
					WHERE I.IndividualId IS NULL
				END
			END
			ELSE IF (
					@columnName = 'FirstName'
					AND @FirstNameReqired > 0
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE FirstName IS NULL
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
						,'FirstName Mandatory at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[FirstName] IS NULL
				END
			END
			ELSE IF (
					@columnName = 'MiddleName'
					AND @MiddleNameReqired > 0
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE MiddleName IS NULL
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
						,'MiddleName Mandatory at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.MiddleName IS NULL
				END
			END
			ELSE IF (
					@columnName = 'LastName'
					AND @LastNameReqired > 0
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE LastName IS NULL
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
						,'LastName Mandatory at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.LastName IS NULL
				END
			END
			ELSE IF (
					@columnName = 'HomeAddressLine1'
					AND @isGACodeError = 0
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE HomeAddressLine1 IS NULL
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
						,'HomeAddressLine1 Mandatory at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[HomeAddressLine1] IS NULL
				END

				/*** CHECK IF GA EXISTS ***/
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE GACode IS NOT NULL
						)
					AND NOT EXISTS (
						SELECT 1
						FROM @pImportFeed ifeed
						JOIN GeographicArea ga ON ga.Code = ifeed.GACode
						JOIN Respondent r ON r.GUIDReference = ga.GUIDReference
						WHERE ifeed.GACode IS NOT NULL
							AND ifeed.HomeAddressLine1 IS NOT NULL
						)
				BEGIN
					SET @Error = 1
					SET @isGACodeError = 1

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
						,'GA code ' + Feed.[GACode] + ' doesn''t exist at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[GACode] IS NOT NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE GACode IS NULL
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
						,'Geographic Area Code could not be automatically calculated for the provided address at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[GACode] IS NULL
				END
			END
			ELSE IF (
					@columnName = 'GACode'
					AND @isGACodeError = 0
					)
			BEGIN
				/*** CHECK IF GA EXISTS ***/
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE ISNULL(GACode, '') <> ''
						)
					AND NOT EXISTS (
						SELECT 1
						FROM @pImportFeed ifeed
						JOIN GeographicArea ga ON ga.Code = ifeed.GACode
						JOIN Respondent r ON r.GUIDReference = ga.GUIDReference
						WHERE ifeed.GACode IS NOT NULL
						)
				BEGIN
					SET @Error = 1
					SET @isGACodeError = 1

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
						,'GA code ' + Feed.[GACode] + ' doesn''t exist at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[GACode] IS NOT NULL
				END
						/*

				IF EXISTS (SELECT 1 FROM @pImportFeed WHERE GACode IS NULL)

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

						,'Geographic Area Code could not be automatically calculated for the provided address'

						,@GetDate

						,Feed.[FullRow]

						,@REPETSEPARATOER

						,@GetDate

						,@pUser

						,@GetDate

						,@pFileId

					FROM @pImportFeed Feed

					WHERE Feed.[GACode] IS NULL

				END

				*/
			END
			ELSE IF (@columnName = 'GroupMembershipStateCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						LEFT JOIN StateDefinition SD ON feed.GroupMembershipStateCode = SD.Code
							AND SD.Country_Id = @pCountryId
						WHERE SD.Code IS NULL
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
						,'Invalid GroupMembershipStateCode at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
							FROM StateDefinition SD
							WHERE SD.Code = Feed.GroupMembershipStateCode
							)
				END

				IF EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						INNER JOIN Individual I ON I.IndividualId = Feed.BusinessId
						INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
						INNER JOIN Collective C ON C.GUIDReference = CMP.Group_Id
						INNER JOIN StateDefinition SD ON feed.GroupMembershipStateCode = SD.Code
							AND SD.Country_Id = @pCountryId
						WHERE SD.Code IS NOT NULL
							AND SD.Id = @GroupMembershipNonResidentId
							AND C.GroupContact_Id = I.GUIDReference
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
						,'Group contact should not be non resident at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed feed
					INNER JOIN Individual I ON I.IndividualId = Feed.BusinessId
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
					INNER JOIN Collective C ON C.GUIDReference = CMP.Group_Id
					INNER JOIN StateDefinition SD ON feed.GroupMembershipStateCode = SD.Code
						AND SD.Country_Id = @pCountryId
					WHERE SD.Code IS NOT NULL
						AND SD.Id = @GroupMembershipNonResidentId
						AND C.GroupContact_Id = I.GUIDReference
				END
			END
			ELSE IF (@columnName = 'NextEvent')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						WHERE feed.FrecuencyValue IS NULL
							OR len(feed.FrecuencyValue) = 0
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
						,'FrecuencyValue should be exist at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE feed.FrecuencyValue IS NULL
						OR len(feed.FrecuencyValue) = 0
				END
			END
			ELSE IF (@columnName = 'FrecuencyValue')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM EventFrequency EF
						INNER JOIN TranslationTerm TT ON EF.Translation_Id = TT.Translation_Id
							AND TT.CultureCode = @pCultureCode
						RIGHT JOIN @pImportFeed feed ON TT.Value = feed.FrecuencyValue
						WHERE TT.Value IS NULL
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
						,'Invalid FrecuencyValue at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
							FROM EventFrequency EF
							INNER JOIN TranslationTerm TT ON EF.Translation_Id = TT.Translation_Id
								AND TT.CultureCode = @pCultureCode
							WHERE TT.Value = Feed.FrecuencyValue
							)
				END

				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE NextEvent IS NULL
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
						,'NextEvent should not be null when FrecuencyValue exists at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.NextEvent IS NULL
				END
			END
			ELSE IF (@columnName = 'GroupId')
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						JOIN (
							SELECT SUBSTRING(IndividualId, 0, CHARINDEX('-', IndividualId)) AS GroupId
							FROM Individual
							WHERE CountryId = @pCountryId
							) I ON feed.GroupId = I.GroupId
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
						,'Invalid GroupId at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
							WHERE Feed.GroupId = SUBSTRING(I.IndividualId, 0, CHARINDEX('-', I.IndividualId))
								AND I.CountryId = @pCountryId
							)
				END
			END
			ELSE IF (@columnName = 'CommunicationCommReasonType')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						LEFT JOIN CommunicationEventReasonType CE ON feed.CommunicationCommReasonType = CE.CommEventReasonCode
						WHERE CE.CommEventReasonCode IS NULL
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
						,'Invalid CommunicationCommReasonType at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
							FROM CommunicationEventReasonType CE
							WHERE CE.CommEventReasonCode = Feed.CommunicationCommReasonType
							)
				END
			END
			ELSE IF (@columnName = 'CommunicationContactMechanismCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						LEFT JOIN ContactMechanismType CMT ON CMT.ContactMechanismCode = feed.CommunicationContactMechanismCode
							AND CMT.Country_Id = @pCountryId
						WHERE CMT.GUIDReference IS NULL
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
						,'Invalid CommunicationContactMechanismCode at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed feed
					LEFT JOIN ContactMechanismType CMT ON CMT.ContactMechanismCode = feed.CommunicationContactMechanismCode
						AND CMT.Country_Id = @pCountryId
					WHERE CMT.GUIDReference IS NULL
				END
			END
			ELSE IF (@columnName = 'Incoming')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed feed
						WHERE feed.CommunicationIncoming IS NULL
							OR feed.CommunicationIncoming = ''
							OR feed.CommunicationIncoming NOT IN (
								'1'
								,'0'
								,'Incoming'
								,'Outgoing'
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
						,'Invalid CommunicationIncoming at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed feed
					WHERE feed.CommunicationIncoming IS NULL
						OR feed.CommunicationIncoming = ''
						OR feed.CommunicationIncoming NOT IN (
							'1'
							,'0'
							,'Incoming'
							,'Outgoing'
							)
				END
			END
			ELSE IF (@columnName = 'PanelCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableData feed
						LEFT JOIN Panel P ON feed.PanelCode = P.PanelCode
							AND P.Country_Id = @pCountryId
						WHERE P.PanelCode IS NULL
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
						,'Invalid PanelCode at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableData Rep
							LEFT JOIN Panel P ON Rep.PanelCode = P.PanelCode
								AND P.Country_Id = @pCountryId
							WHERE P.PanelCode IS NULL
							)
				END
			END
			ELSE IF (@columnName = 'PanelRoleCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableData feed
						LEFT JOIN DynamicRole DR ON CAST(ISNULL(feed.[PanelRoleCode], '0') AS INT) = DR.[Code]
							AND DR.Country_Id = @pCountryId
						WHERE DR.Country_Id = @pCountryId
							AND DR.[Code] IS NULL
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
						,'Invalid PanelRoleCode at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableData Rep
							LEFT JOIN DynamicRole DR ON CAST(ISNULL(Rep.[PanelRoleCode], '0') AS INT) = DR.[Code]
								AND DR.Country_Id = @pCountryId
							WHERE DR.Country_Id = @pCountryId
								AND DR.[Code] IS NULL
							)
				END
			END
			ELSE IF (@columnName = 'GroupRoleCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableData feed
						LEFT JOIN DynamicRole DR ON CAST(ISNULL(feed.[GroupRoleCode], '0') AS INT) = DR.[Code]
							AND DR.Country_Id = @pCountryId
						WHERE DR.Country_Id = @pCountryId
							AND DR.[Code] IS NULL
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
						,'Invalid GroupRoleCode at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableData Rep
							LEFT JOIN DynamicRole DR ON CAST(ISNULL(Rep.[GroupRoleCode], '0') AS INT) = DR.[Code]
								AND DR.Country_Id = @pCountryId
							WHERE DR.Country_Id = @pCountryId
								AND DR.[Code] IS NULL
							)
				END
			END
			ELSE IF (@columnName = 'PanelistStateCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableData feed
						LEFT JOIN (
							SELECT SD.Code
							FROM StateDefinition SD
							INNER JOIN StateModel SM ON SD.StateModel_Id = SM.GUIDReference
							WHERE SM.Country_Id = @pCountryId
								AND [Type] = 'Domain.PanelManagement.Candidates.Panelist'
							) Codes ON feed.PanelistStateCode = Codes.Code
						WHERE Codes.Code IS NULL
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
						,'Invalid PanelistStateCode at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,F.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed F
					WHERE F.Rownumber IN (
							SELECT feed.Rownumber
							FROM @pRepeatableData feed
							LEFT JOIN (
								SELECT SD.Code
								FROM StateDefinition SD
								INNER JOIN StateModel SM ON SD.StateModel_Id = SM.GUIDReference
								WHERE SM.Country_Id = @pCountryId
									AND [Type] = 'Domain.PanelManagement.Candidates.Panelist'
								) Codes ON feed.PanelistStateCode = Codes.Code
							WHERE Codes.Code IS NULL
							)
				END
			END
			ELSE IF (@columnName = 'PanelistCommunicationMethodology')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableData REP
						LEFT JOIN CollaborationMethodology CM ON CM.Code = REP.PanelistCommunicationMethodology
							AND CM.Country_Id = @pCountryId
						WHERE CM.Country_Id = @pCountryId
							AND CM.[Code] IS NULL
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
						,'Invalid PanelistCommunicationMethodology at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableData REP
							LEFT JOIN CollaborationMethodology CM ON CM.Code = REP.PanelistCommunicationMethodology
								AND CM.Country_Id = @pCountryId
							WHERE CM.Country_Id = @pCountryId
								AND CM.[Code] IS NULL
							)
				END
			END
			ELSE IF (@columnName = 'PanelistCommunicationMethodologyChangeReason')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableData REP
						LEFT JOIN CollaborationMethodologyChangeReason CMCR ON dbo.GetTranslationValue(Description_Id, @pCultureCode) = REP.PanelistCommunicationMethodologyChangeReason
							AND CMCR.Country_Id = @pCountryId
						WHERE CMCR.Description_Id IS NULL
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
						,'Invalid PanelistCommunicationMethodologyChangeReason at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableData REP
							LEFT JOIN CollaborationMethodologyChangeReason CMCR ON dbo.GetTranslationValue(Description_Id, @pCultureCode) = REP.PanelistCommunicationMethodologyChangeReason
								AND CMCR.Country_Id = @pCountryId
							WHERE CMCR.Description_Id IS NULL
							)
				END
			END

			SET @columnsincrement = @columnsincrement + 1
		END

		--VALUDATE COLUMN COUNT
		DECLARE @importColumnCount INT;

		SELECT @importColumnCount = COUNT(*)
		FROM [ImportColumnMapping] icm
		JOIN ImportFile ifff ON ifff.ImportFormat_Id = icm.ImportFormat_id
		WHERE ifff.GUIDReference = @pFileId

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
			,'Email address is not valid at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
			,@GetDate
			,Feed.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed Feed
		WHERE @importColumnCount <> len([FullRow]) - len(replace([FullRow], '|', '')) + 1

		IF @@ROWCOUNT > 0
			SET @Error = 1

		IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE [ColumnName] LIKE 'Email'
				)
		BEGIN
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
				,'Email address is not valid at Row ' + CONVERT(VARCHAR, feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeed Feed
			JOIN @pRepeatableData rep ON rep.Rownumber = Feed.Rownumber
			WHERE dbo.ValidateEmail(rep.Email) = 0

			IF @@ROWCOUNT > 0
				SET @Error = 1
		END

		IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE [ColumnName] = 'AddressLine1'
				)
		BEGIN
			SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'AddressLine1'

			IF EXISTS (
					SELECT 1
					FROM @pRepeatableData
					WHERE AddressLine1 IS NULL
						AND (
							AddressType IS NOT NULL
							AND [Order] IS NULL
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
					,'AddressLine1 Mandatory at Row ' + CONVERT(VARCHAR, feed1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,Feed1.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableData Feed
				INNER JOIN @pImportFeed FEED1 ON FEED1.Rownumber = Feed.Rownumber
				WHERE Feed.[AddressLine1] IS NULL
					AND (
						AddressType IS NOT NULL
						AND [Order] IS NULL
						)
			END
		END

		IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE [ColumnName] = 'PostCode'
				)
		BEGIN
			SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'PostCode'

			IF EXISTS (
					SELECT 1
					FROM @pRepeatableData
					WHERE PostCode IS NULL
						AND (
							AddressType IS NOT NULL
							AND [Order] IS NULL
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
					,'PostCode Mandatory at Row ' + CONVERT(VARCHAR, feed1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,Feed1.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableData Feed
				INNER JOIN @pImportFeed FEED1 ON FEED1.Rownumber = Feed.Rownumber
				WHERE Feed.PostCode IS NULL
					AND (
						AddressType IS NOT NULL
						AND [Order] IS NULL
						)
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
					FROM @pRepeatableData REP
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
				FROM @pRepeatableData Feed
				INNER JOIN @pImportFeed IMP ON Feed.Rownumber = IMP.Rownumber
				WHERE AddressType IS NULL
			END

			IF EXISTS (
					SELECT 1
					FROM @pRepeatableData REP
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
					,'AddressType is not valid at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,IMP.FullRow
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableData Feed
				INNER JOIN @pImportFeed IMP ON FEED.Rownumber = IMP.Rownumber
				LEFT JOIN #AddressTypes AT ON AT.AddressType = Feed.AddressType
				WHERE Feed.AddressType IS NOT NULL
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
					FROM @pRepeatableData
					WHERE (
							AddressType IS NULL
							AND [Order] IS NULL
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
					,'Order/AddressType Mandatory at Row ' + CONVERT(VARCHAR, feed1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,Feed1.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableData Feed
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
				SELECT ifeed.BusinessId
					,rdata.PhoneOrder
					,rdata.PhoneType
					,COUNT(*) AS C
				FROM @pRepeatableData rdata
				JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
				WHERE rdata.PhoneOrder IS NOT NULL
					AND rdata.PhoneOrder <> ''
				GROUP BY ifeed.BusinessId
					,rdata.PhoneOrder
					,rdata.PhoneType
				HAVING COUNT(*) > 1
				)
		BEGIN
			SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'PhoneOrder'

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
				,'The selected Phone Order is being updated twice for the individual at Row ' + CONVERT(VARCHAR, Feed1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,Feed1.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM (
				SELECT ifeed.BusinessId
					,rdata.PhoneOrder
					,COUNT(*) AS C
				FROM @pRepeatableData rdata
				JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
				WHERE rdata.PhoneOrder IS NOT NULL
					AND rdata.PhoneOrder <> ''
				GROUP BY ifeed.BusinessId
					,rdata.PhoneOrder
				HAVING COUNT(*) > 1
				) ids
			JOIN @pImportFeed Feed1 ON ids.BusinessId = Feed1.BusinessId
		END

		SELECT @ColumnNumber = RowNumber
		FROM @pColumn
		WHERE [ColumnName] = 'PhoneType'

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
			,'Either Phone or Phone Type is required at Row ' + CONVERT(VARCHAR, ifeed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,ifeed.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pRepeatableData rdata
		JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
		WHERE (
				ISNULL(rdata.PhoneType, '') = ''
				OR ISNULL(rdata.Phone, '') = ''
				)
			AND (
				ISNULL(rdata.PhoneType, '') <> ''
				OR ISNULL(rdata.Phone, '') <> ''
				)

		IF @@ROWCOUNT > 0
			SET @Error = 1

		IF EXISTS (
				SELECT 1
				FROM @pRepeatableData rdata
				WHERE rdata.PhoneType IS NOT NULL
					AND rdata.PhoneType <> ''
					AND rdata.PhoneType NOT LIKE 'HomePhoneType'
					AND rdata.PhoneType NOT LIKE 'WorkPhoneType'
					AND rdata.PhoneType NOT LIKE 'MobilePhoneType'
				)
		BEGIN
			SET @Error = 1

			SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'PhoneType'

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
				,'The Phone Type was not recognized, try HomePhoneType, WorkPhoneType or MobilePhoneType at Row ' + CONVERT(VARCHAR, ifeed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,ifeed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pRepeatableData rdata
			JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
			WHERE rdata.PhoneType IS NOT NULL
				AND rdata.PhoneType <> ''
				AND rdata.PhoneType NOT LIKE 'HomePhoneType'
				AND rdata.PhoneType NOT LIKE 'WorkPhoneType'
				AND rdata.PhoneType NOT LIKE 'MobilePhoneType'
		END

		IF EXISTS (
				SELECT ifeed.BusinessId
					,rdata.EmailOrder
					,rdata.EmailType
					,COUNT(*) AS C
				FROM @pRepeatableData rdata
				JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
				WHERE rdata.EmailOrder IS NOT NULL
					AND rdata.EmailOrder <> ''
				GROUP BY ifeed.BusinessId
					,rdata.EmailOrder
					,rdata.EmailType
				HAVING COUNT(*) > 1
				)
		BEGIN
			SET @Error = 1

			SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'EmailOrder'

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
				,'The selected Email Order is being updated twice for the individual at Row ' + CONVERT(VARCHAR, feed1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,Feed1.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM (
				SELECT ifeed.BusinessId
					,rdata.EmailOrder
					,COUNT(*) AS C
				FROM @pRepeatableData rdata
				JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
				WHERE rdata.EmailOrder IS NOT NULL
					AND rdata.EmailOrder <> ''
				GROUP BY ifeed.BusinessId
					,rdata.EmailOrder
				HAVING COUNT(*) > 1
				) ids
			JOIN @pImportFeed Feed1 ON ids.BusinessId = Feed1.BusinessId
		END

		SELECT @ColumnNumber = RowNumber
		FROM @pColumn
		WHERE [ColumnName] = 'EmailType'

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
			,'Either Email or Email Type is required at Row ' + CONVERT(VARCHAR, ifeed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,ifeed.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pRepeatableData rdata
		JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
		WHERE (
				ISNULL(rdata.EmailType, '') = ''
				OR ISNULL(rdata.Email, '') = ''
				)
			AND (
				ISNULL(rdata.EmailType, '') <> ''
				OR ISNULL(rdata.Email, '') <> ''
				)

		IF @@ROWCOUNT > 0
			SET @Error = 1

		IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE ColumnName = 'EmailType'
				)
			AND EXISTS (
				SELECT 1
				FROM @pRepeatableData rdata
				LEFT JOIN Translation t ON t.KeyName = rdata.EmailType
				LEFT JOIN AddressType at ON at.Description_Id = t.TranslationId
					AND at.DiscriminatorType = 'ElectronicAddressType'
				WHERE ISNULL(rdata.EmailType, '') <> ''
					AND at.Description_Id IS NULL
				)
		BEGIN
			SET @Error = 1

			SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'EmailType'

			DECLARE @acceptedTypes NVARCHAR(MAX);

			SELECT @acceptedTypes = COALESCE(@acceptedTypes + ', ', '') + t.KeyName
			FROM Translation t
			JOIN AddressType at ON at.Description_Id = t.TranslationId
				AND at.DiscriminatorType = 'ElectronicAddressType'

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
				,'The Email Type was not recognized, try ' + @acceptedTypes + ' at Row ' + CONVERT(VARCHAR, ifeed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,ifeed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pRepeatableData rdata
			JOIN @pImportFeed ifeed ON ifeed.Rownumber = rdata.Rownumber
			LEFT JOIN Translation t ON t.KeyName = rdata.EmailType
			LEFT JOIN AddressType at ON at.Description_Id = t.TranslationId
				AND at.DiscriminatorType = 'ElectronicAddressType'
			WHERE rdata.EmailType IS NOT NULL
				AND rdata.EmailType <> ''
				AND at.Id IS NULL
		END

		IF EXISTS (
				SELECT 1
				FROM @pRepeatableData
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
				,'Either AddressLine1 OR AddressLine2 Or AddressLine3 Or AddressLine4 Or PostCode is required at Row ' + CONVERT(VARCHAR, feed1.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,Feed1.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pRepeatableData Feed
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

		DECLARE @maxId VARCHAR(50)
		DECLARE @nextId VARCHAR(50)

		SET @maxId = (
				SELECT Max(IndividualId)
				FROM Individual
				WHERE CountryId = @pCountryId
				)

		IF (@maxId IS NOT NULL)
		BEGIN
			SET @nextId = SUBSTRING(@maxId, 0, CHARINDEX('-', @maxId))
		END

		DECLARE @groupBusinessIdCount INT

		SET @groupBusinessIdCount = (
				SELECT CC.GroupBusinessIdDigits
				FROM CountryConfiguration CC
				INNER JOIN Country C ON CC.Id = C.Configuration_Id
				WHERE C.CountryId = @pCountryId
				)

		DECLARE @groupIndividualIdSeqCount INT

		SET @groupIndividualIdSeqCount = (
				SELECT CC.IndividualBusinessIdDigits
				FROM CountryConfiguration CC
				INNER JOIN Country C ON CC.Id = C.Configuration_Id
				WHERE C.CountryId = @pCountryId
				)

		DECLARE @personalIdentificationId BIGINT

		SET @personalIdentificationId = (
				SELECT MAX(PersonalIdentificationId)
				FROM PersonalIdentification
				)

		DECLARE @nextSequence BIGINT ---Move above and set since transaction not completed

		SET @nextSequence = (
				SELECT MAX(Sequence)
				FROM Collective
				WHERE CountryId = @pCountryId
				)

		DECLARE @groupStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupAssignedStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupParticipantStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupTerminatedStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupDeceasedStatusGuid UNIQUEIDENTIFIER

		SET @groupAssignedStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupAssigned'
					AND Country_Id = @pCountryId
				)
		SET @groupParticipantStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupParticipant'
					AND Country_Id = @pCountryId
				)
		SET @groupTerminatedStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupTerminated'
					AND Country_Id = @pCountryId
				)
		SET @groupDeceasedStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupDeceased'
					AND Country_Id = @pCountryId
				)
		SET @groupStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupCandidate'
					AND Country_Id = @pCountryId
				)

		DECLARE @existingroupStatusGuid UNIQUEIDENTIFIER

		SET @existingroupStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupPreseted'
					AND Country_Id = @pCountryId
				)

		DECLARE @individualStatusGuid UNIQUEIDENTIFIER
		DECLARE @individualDeceasedGuid UNIQUEIDENTIFIER
		DECLARE @individualAssignedGuid UNIQUEIDENTIFIER
		DECLARE @individualNonParticipent UNIQUEIDENTIFIER
		DECLARE @individualParticipent UNIQUEIDENTIFIER
		DECLARE @individualGuid UNIQUEIDENTIFIER
		DECLARE @PanelImportStatus UNIQUEIDENTIFIER
		DECLARE @ImportBusinessId VARCHAR(50)
		DECLARE @individualDropOf UNIQUEIDENTIFIER = NULL

		SET @individualDeceasedGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualDeceased'
					AND Country_Id = @pCountryId
				)
		SET @individualDropOf = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualTerminated'
					AND Country_Id = @pCountryId
				)
		SET @individualStatusGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualCandidate'
					AND Country_Id = @pCountryId
				)
		SET @individualAssignedGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualAssigned'
					AND Country_Id = @pCountryId
				)
		SET @individualNonParticipent = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualNonParticipant'
					AND Country_Id = @pCountryId
				)
		SET @individualParticipent = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualParticipant'
					AND Country_Id = @pCountryId
				)

		DECLARE @FromStateIndividualGuid UNIQUEIDENTIFIER

		SET @FromStateIndividualGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'IndividualPreseted'
					AND Country_Id = @pCountryId
				)
		SET @ImportBusinessId = (
				SELECT TOP 1 BusinessId
				FROM @pImportFeed
				)

		IF (@ImportBusinessId IS NOT NULL)
		BEGIN
			SET @individualGuid = (
					SELECT GUIDreference
					FROM Individual
					WHERE IndividualId = @ImportBusinessId
						AND CountryId = @pCountryId
					)
		END

		SET @PanelImportStatus = (
				SELECT TOP 1 To_Id
				FROM statedefinitionhistory
				WHERE candidate_Id = @individualGuid
					AND Country_Id = @pCountryId
				ORDER BY creationtimestamp DESC
				)

		IF (@PanelImportStatus IS NOT NULL)
		BEGIN
			SET @FromStateIndividualGuid = @PanelImportStatus
		END

		DECLARE @nullTitleId UNIQUEIDENTIFIER

		SET @nullTitleId = (
				SELECT GUIDReference
				FROM IndividualTitle
				WHERE Code = 0
					AND Country_Id = @pCountryId
				)

		DECLARE @nullsexId UNIQUEIDENTIFIER

		SET @nullsexId = (
				SELECT GUIDReference
				FROM IndividualSex
				WHERE Code = 0
					AND Country_Id = @pCountryId
				)

		DECLARE @nullCharityId UNIQUEIDENTIFIER

		SET @nullCharityId = (
				SELECT TOP 1 GUIDReference
				FROM CharitySubscription CS
				INNER JOIN CharityAmount CA ON CS.Amount_Id = CA.GUIDReference
				WHERE CA.Value = 0
					AND CA.Country_Id = @pCountryId
				)

		DECLARE @postalAddressTypeGuid UNIQUEIDENTIFIER

		SET @postalAddressTypeGuid = (
				SELECT Id
				FROM AddressType
				WHERE DiscriminatorType = 'PostalAddressType'
					AND IsDefault = 1
				)

		DECLARE @emailAddressTypeGuid UNIQUEIDENTIFIER

		SET @emailAddressTypeGuid = (
				SELECT Id
				FROM AddressType
				WHERE DiscriminatorType = 'ElectronicAddressType'
					AND IsDefault = 1
				)

		DECLARE @homeAddressTypeGuid UNIQUEIDENTIFIER

		SET @homeAddressTypeGuid = (
				SELECT Id
				FROM AddressType AT
				INNER JOIN Translation T ON AT.Description_Id = T.TranslationId
				WHERE AT.DiscriminatorType = 'PhoneAddressType'
					AND T.KeyName = 'HomePhoneType'
				)

		DECLARE @workAddressTypeGuid UNIQUEIDENTIFIER

		SET @workAddressTypeGuid = (
				SELECT Id
				FROM AddressType AT
				INNER JOIN Translation T ON AT.Description_Id = T.TranslationId
				WHERE AT.DiscriminatorType = 'PhoneAddressType'
					AND T.KeyName = 'WorkPhoneType'
				)

		DECLARE @mobileAddressTypeGuid UNIQUEIDENTIFIER

		SET @mobileAddressTypeGuid = (
				SELECT Id
				FROM AddressType AT
				INNER JOIN Translation T ON AT.Description_Id = T.TranslationId
				WHERE AT.DiscriminatorType = 'PhoneAddressType'
					AND T.KeyName = 'MobilePhoneType'
				)

		DECLARE @collectiveTranslationId UNIQUEIDENTIFIER

		SET @collectiveTranslationId = (
				SELECT TranslationId
				FROM Translation
				WHERE KeyName = 'HouseHoldGroupTypeDescriptor'
				)

		DECLARE @defaultGroupMembershipStatusId UNIQUEIDENTIFIER

		SET @defaultGroupMembershipStatusId = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupMembershipResident'
					AND Country_Id = @pCountryId
				)

		DECLARE @FromStateGroupMembershipGuid UNIQUEIDENTIFIER

		SET @FromStateGroupMembershipGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'GroupMembershipPreseted'
					AND Country_Id = @pCountryId
				)

		IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE ColumnName IN ('GroupId')
				)
		BEGIN
			UPDATE CM
			SET CM.Group_Id = NC.GUIDREference
			FROM @pImportFeed F
			JOIN Individual I ON F.BusinessId = I.IndividualId
				AND I.CountryId = @pCountryId
			JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
			JOIN Collective C ON CM.Group_Id = C.GUIDReference
			JOIN Collective NC ON NC.Sequence = F.GroupId
				AND NC.CountryId = @pCountryId
			WHERE CM.CollectiveMembershipId = (
					SELECT TOP 1 CollectiveMembershipId
					FROM CollectiveMembership CM2
					JOIN StateDefinition SD ON CM2.State_Id = SD.Id
					WHERE CM2.Individual_Id = I.GUIDReference
					ORDER BY SD.InactiveBehavior
						,CM2.GPSUpdateTimestamp DESC
					)

			UPDATE I
			SET I.IndividualId = RIGHT('0000000000' + CAST(C.Sequence AS VARCHAR), IIF(LEN(C.Sequence) > @groupBusinessIdCount, LEN(C.Sequence), @groupBusinessIdCount)) + '-' + (
					SELECT RIGHT('0000000000' + CAST(MAX(SUBSTRING(I2.IndividualId, CHARINDEX('-', I2.IndividualId) + 1, 3) + 1) AS VARCHAR), @groupIndividualIdSeqCount)
					FROM CollectiveMembership CM
					JOIN Individual I2 ON CM.Individual_Id = I2.GUIDReference
					WHERE CM.Group_Id = C.GUIDReference
						AND I2.GUIDReference <> I.GUIDReference
					)
			FROM @pImportFeed F
			JOIN Individual I ON F.BusinessId = I.IndividualId
				AND I.CountryId = @pCountryId
			JOIN Collective C ON C.Sequence = F.GroupId
				AND C.CountryId = @pCountryId
				/*UPDATE I SET I.IndividualId = 

                                  RIGHT('0000000000' + CAST(C.Sequence AS VARCHAR), IIF(LEN(C.Sequence) > @groupBusinessIdCount, LEN(C.Sequence), @groupBusinessIdCount)) 

                                  + '-' + 

                                  (SELECT RIGHT('0000000000' + CAST(MAX(SUBSTRING(I2.IndividualId, CHARINDEX('-', I2.IndividualId) + 1, 3) + 1) AS VARCHAR), @groupIndividualIdSeqCount)

                                  FROM CollectiveMembership CM2

                                  JOIN Individual I2 ON CM2.Individual_Id = I2.GUIDReference

                                  WHERE CM2.Group_Id = C.GUIDReference)

                     FROM @pImportFeed F

                     JOIN Individual I ON F.BusinessId = I.IndividualId AND I.CountryId = @pCountryId

                     JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference

                     JOIN Collective C ON CM.Group_Id = C.GUIDReference

                     WHERE CM.CollectiveMembershipId = (SELECT TOP 1 CollectiveMembershipId 

                           FROM CollectiveMembership CM2

                           JOIN StateDefinition SD ON CM2.State_Id = SD.Id

                           WHERE CM2.Individual_Id = I.GUIDReference

                           ORDER BY SD.InactiveBehavior, CM2.GPSUpdateTimestamp DESC)*/
		END

		IF OBJECT_ID('tempdb..#ImportFeedData') IS NOT NULL
			DROP TABLE #ImportFeedData

		CREATE TABLE #ImportFeedData (
			Rownumber INT NOT NULL
			,FirstName NVARCHAR(300) NULL
			,MiddleName NVARCHAR(300) NULL
			,LastName NVARCHAR(300) NULL
			,EmailAddress NVARCHAR(200) NULL
			--,HomePhone NVARCHAR(200) NULL
			--,WorkPhone NVARCHAR(200) NULL
			--,MobilePhone NVARCHAR(200) NULL
			,HomeAddressLine1 NVARCHAR(200) NULL
			,HomeAddressLine2 NVARCHAR(200) NULL
			,HomeAddressLine3 NVARCHAR(200) NULL
			,HomeAddressLine4 NVARCHAR(200) NULL
			,HomePostCode NVARCHAR(100) NULL
			,DateOfBirth DATETIME NULL
			,EnrollmentDate DATETIME NULL
			,Sex INT NULL
			,Title INT NULL
			,GroupMembershipStateCode NVARCHAR(100) NULL
			,SupportCharity BIT NULL
			,NonParticipant BIT NULL
			,FrecuencyValue NVARCHAR(1000) NULL
			,NextEvent DATETIME NULL
			,AmountValue INT NULL
			,GroupId INT NULL
			,CommunicationIncoming BIT NULL
			,CommunicationContactMechanismCode BIT NULL
			,CommunicationCommReasonType INT NULL
			,Alias NVARCHAR(300) NULL
			,Comments NVARCHAR(1000) NULL
			,CommunicationCreationDateTime DATETIME NULL
			,IndividualAlias VARCHAR(100) NULL
			,IndividualId VARCHAR(20) NOT NULL
			,PersonalIdentificationId BIGINT NOT NULL
			,IndividualGuid UNIQUEIDENTIFIER NOT NULL --DEFAULT NEWID()
			,GroupGuid UNIQUEIDENTIFIER NOT NULL --DEFAULT NEWID()
			,PostalAddressGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,ElectronicAddressGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,HomeAddressGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,WorkAddressGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,MobileAddressGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,NextCollectiveSequence BIGINT NOT NULL
			,CollectiveMembershipId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,TitleGuid UNIQUEIDENTIFIER NULL
			,SexGuid UNIQUEIDENTIFIER NULL
			,GroupMembershipStateGuid UNIQUEIDENTIFIER NULL
			,BusinessId VARCHAR(20) NULL
			,GACode NVARCHAR(200) NULL
			)

		INSERT INTO #ImportFeedData (
			Rownumber
			,FirstName
			,MiddleName
			,LastName
			,EmailAddress
			--,HomePhone
			--,WorkPhone
			--,MobilePhone
			,HomeAddressLine1
			,HomeAddressLine2
			,HomeAddressLine3
			,HomeAddressLine4
			,HomePostCode
			,DateOfBirth
			,EnrollmentDate
			,Sex
			,Title
			,GroupMembershipStateCode
			,SupportCharity
			,NonParticipant
			,FrecuencyValue
			,NextEvent
			,AmountValue
			,GroupId
			,CommunicationIncoming
			,CommunicationContactMechanismCode
			,CommunicationCommReasonType
			,Alias
			,Comments
			,CommunicationCreationDateTime
			,IndividualAlias
			,IndividualId
			,PersonalIdentificationId
			,NextCollectiveSequence
			,TitleGuid
			,SexGuid
			,GroupMembershipStateGuid
			,BusinessId
			,IndividualGuid
			,GroupGuid
			,GACode
			)
		SELECT FEED.Rownumber
			,FEED.FirstName
			,FEED.MiddleName
			,FEED.LastName
			,FEED.EmailAddress
			--,FEED.HomePhone
			--,FEED.WorkPhone
			--,FEED.MobilePhone
			,FEED.HomeAddressLine1
			,FEED.HomeAddressLine2
			,FEED.HomeAddressLine3
			,FEED.HomeAddressLine4
			,FEED.HomePostCode
			,FEED.DateOfBirth
			,FEED.EnrollmentDate
			,FEED.Sex
			,FEED.Title
			,FEED.GroupMembershipStateCode
			,FEED.SupportCharity --20
			,ISNULL(NonParticipant, 0)
			,FEED.FrecuencyValue
			,FEED.NextEvent
			,FEED.AmountValue
			,FEED.GroupId
			,FEED.CommunicationIncoming
			,FEED.CommunicationContactMechanismCode
			,FEED.CommunicationCommReasonType
			,FEED.Alias
			,FEED.Comments
			,FEED.CommunicationCreationDateTime
			,FEED.IndividualAlias
			,IND.IndividualId
			,IND.PersonalIdentificationId
			,CMP.Sequence
			,ISNULL(IT.GUIDReference, @nullTitleId)
			,ISNULL(S.GUIDReference, @nullsexId)
			,ISNULL(SD.Id, @defaultGroupMembershipStatusId)
			,FEED.BusinessId
			,IND.GUIDReference
			,CMP.Group_Id
			,Feed.GACode
		FROM @pImportFeed FEED
		INNER JOIN Individual IND ON FEED.BusinessId = IND.IndividualId
			AND IND.CountryId = @pCountryId
		INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IND.GUIDReference
		LEFT JOIN IndividualTitle IT ON FEED.Title = IT.Code
			AND IT.Country_Id = @pCountryId
		LEFT JOIN IndividualSex S ON FEED.Sex = S.Code
			AND S.Country_Id = @pCountryId
		LEFT JOIN StateDefinition SD ON FEED.GroupMembershipStateCode = SD.Code
			AND SD.Country_Id = @pCountryId
		ORDER BY Rownumber

		IF OBJECT_ID('tempdb..#Demographics') IS NOT NULL
			DROP TABLE #Demographics

		CREATE TABLE #Demographics (
			DemographicId UNIQUEIDENTIFIER
			,IndividualId UNIQUEIDENTIFIER
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
			,AttributeScope VARCHAR(100)
			,GroupId UNIQUEIDENTIFIER
			,ColumnNumber INT
			)

		INSERT INTO #Demographics (
			DemographicId
			,IndividualId
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
			,AttributeScope
			,GroupId
			,ColumnNumber
			)
		SELECT A.GUIDReference
			,feed.IndividualGuid
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
			,ats.[Type]
			,cm.Group_Id
			,CP.Rownumber AS [ColumnNumber]
		FROM #ImportFeedData feed
		INNER JOIN @pDemographicData demo ON feed.Rownumber = demo.Rownumber
		JOIN CollectiveMembership cm ON cm.Individual_Id = feed.IndividualGuid
		INNER JOIN Attribute A ON A.[Key] = demo.DemographicName
			AND a.Country_Id = @pCountryId
		JOIN @pColumn CP ON A.[KEY] = CP.COLUMNNAME
			AND A.Country_Id = @pCountryId
		INNER JOIN AttributeScope ats ON ats.GUIDReference = a.[Scope_Id]
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
				,T.Names + ' demographics are exceeds max length at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' are not in range at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' demographics are not in range at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' date demographics are not valid at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
								AND (
									DateFrom IS NULL
									OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
									)
								AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
								THEN 1
							WHEN Today = 0
								--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
								--AND (DateTo IS NULL OR CONVERT(DATETIME, DemographicValue, 103) <= DateTo)
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
							AND (
								DateFrom IS NULL
								OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
								)
							AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
							THEN 1
						WHEN Today = 0
							--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
							--     AND (DateTo IS NULL OR CONVERT(DATETIME, DemographicValue, 103) <= DateTo)
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
							AND (
								DateFrom IS NULL
								OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
								)
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
				,T.Names + ' date demographics are not range at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' enum demographics are not valid at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' demographics are not in range at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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
				,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
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

		IF EXISTS (
				SELECT 1
				FROM @pColumn
				WHERE [ColumnName] = 'Order'
				)
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM @pRepeatableData REP
					JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
					JOIN @pImportFeed feed1 ON feed1.Rownumber = REP.Rownumber
					LEFT JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = REP.[ORDER]
					LEFT JOIN Address A ON OCM.Address_Id = A.GUIDReference
						AND A.[AddressType] = 'PostalAddress'
					WHERE OCM.Id IS NULL
						AND REP.[Order] IS NOT NULL
						AND REP.AddressType = 'PostalAddress'
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
					,'Address with the specified order does not exists at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, 0)
					,@GetDate
					,feed1.[FullRow]
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableData REP
				JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
				JOIN @pImportFeed feed1 ON feed1.Rownumber = REP.Rownumber
				LEFT JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
					AND OCM.[Order] = REP.[ORDER]
				LEFT JOIN Address A ON OCM.Address_Id = A.GUIDReference
					AND A.[AddressType] = 'PostalAddress'
				WHERE OCM.Id IS NULL
					AND REP.[Order] IS NOT NULL
			END
		END

		DECLARE @PanelistDefaultStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistPresetedStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistLiveStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistDropoutStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistRefusalStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistPreLiveStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistSelectedStateId AS UNIQUEIDENTIFIER

		SELECT @PanelistLiveStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistLiveState'
			AND Country_Id = @pCountryId

		SELECT @PanelistPreLiveStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistPreLiveState'
			AND Country_Id = @pCountryId

		SELECT @PanelistDropoutStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistDroppedOffState'
			AND Country_Id = @pCountryId

		SELECT @PanelistSelectedStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistSelectedState'
			AND Country_Id = @pCountryId

		SELECT @PanelistRefusalStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistRefusalState'
			AND Country_Id = @pCountryId

		SELECT @PanelistDefaultStateId = (
				SELECT TOP 1 st.ToState_Id
				FROM statedefinition sd
				INNER JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id = SD.Id
				INNER JOIN StateTransition st ON st.Id = sdt.AvailableTransition_Id
					AND sd.Country_Id = @pCountryId
				WHERE sd.code = 'PanelistPresetedState'
				ORDER BY st.[Priority]
					,IsAdmin
				)

		SELECT @PanelistPresetedStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistPresetedState'
			AND Country_Id = @pCountryId

		IF OBJECT_ID('tempdb..#Insert_AddressList') IS NOT NULL
			DROP TABLE #Insert_AddressList

		CREATE TABLE #Insert_AddressList (
			AddressListGUID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,GroupGUID UNIQUEIDENTIFIER NULL
			,[Order] INT NULL
			,IndividualGuid UNIQUEIDENTIFIER NULL
			,AddressLine1 NVARCHAR(MAX) Collate Database_Default
			,AddressLine2 NVARCHAR(MAX) Collate Database_Default
			,AddressLine3 NVARCHAR(MAX) Collate Database_Default
			,AddressLine4 NVARCHAR(MAX) Collate Database_Default
			,PostCode NVARCHAR(MAX) Collate Database_Default
			,AddressType NVARCHAR(MAX) Collate Database_Default
			,AddressTypeGUID UNIQUEIDENTIFIER NULL
			)

		INSERT INTO #Insert_AddressList (
			GroupGUID
			,[Order]
			,IndividualGuid
			,AddressLine1
			,AddressLine2
			,AddressLine3
			,AddressLine4
			,PostCode
			,AddressType
			,AddressTypeGUID
			)
		SELECT FEED.GroupGuid
			,REp.[Order]
			,FEED.IndividualGuid
			,REP.AddressLine1
			,REP.AddressLine2
			,REP.AddressLine3
			,REP.AddressLine4
			,REP.PostCode
			,REP.AddressType
			,AP.ID
		FROM @pRepeatableData REP
		INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
		INNER JOIN #AddressTypes AP ON REP.AddressType = AP.AddressType

		/*

	IF EXISTS (SELECT 1 FROM @pColumn WHERE [ColumnName] = 'AddressType')

			BEGIN

	IF EXISTS (

							SELECT 1

						FROM @pRepeatableData REP												

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

						,'AddressType is Mandatory'

						,@GetDate

						,IMP.FullRow

						,@REPETSEPARATOER

						,@GetDate

						,@pUser

						,@GetDate

						,@pFileId

					FROM @pRepeatableData Feed

					INNER JOIN @pImportFeed IMP ON Feed.Rownumber = IMP.Rownumber

					WHERE AddressType IS NULL 

				END

			

						IF EXISTS (

							SELECT 1

						FROM @pRepeatableData REP						

						LEFT JOIN #AddressTypes AT ON AT.AddressType = REP.AddressType 

						WHERE REP.AddressType IS NOT NULL AND AT.AddressType IS NULL



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

						,'AddressType is not valid'

							,@GetDate

						,IMP.FullRow

							,@REPETSEPARATOER

							,@GetDate

							,@pUser

							,@GetDate

							,@pFileId

					FROM @pRepeatableData Feed 

					INNER JOIN @pImportFeed IMP ON FEED.Rownumber = IMP.Rownumber 

					LEFT JOIN #AddressTypes AT ON AT.AddressType = Feed.AddressType 

					WHERE Feed.AddressType IS NOT NULL AND AT.AddressType IS NULL				

				END

				

			END

*/
		--IF EXISTS (
		--						SELECT 1
		--						FROM @pColumn
		--		WHERE [ColumnName] = 'Order'
		--						)
		--				BEGIN						
		--					IF EXISTS (
		--				SELECT 1 FROM #Insert_AddressList RData
		--					INNER JOIN OrderedContactMechanism OCM ON RData.IndividualGuid = OCM.Candidate_Id AND OCM.[Order] = RData.[Order]
		--					INNER JOIN [address] A ON A.GUIDReference = OCM.Address_Id						
		--					INNER JOIN AddressType AT ON A.[Type_Id] = AT.Id	
		--					INNER JOIN TranslationTerm TT ON At.Description_Id = TT.Translation_Id
		--                                        WHERE TT.VALUE != RData.AddressType      AND TT.CultureCode = @pCultureCode
		--					)
		--					BEGIN
		--						SET @Error = 1
		--		PRINT 'NOT VALID'
		--					INSERT INTO ImportAudit (
		--						GUIDReference
		--						,Error
		--						,IsInvalid
		--						,[Message]
		--						,[Date]
		--						,SerializedRowData
		--						,SerializedRowErrors
		--						,CreationTimeStamp
		--						,GPSUser
		--						,GPSUpdateTimestamp
		--						,[File_Id]
		--						)
		--					SELECT NEWID()
		--						,1
		--						,0
		--					,'Order is not valid'
		--						,@GetDate
		--					,FEED1.BusinessId 
		--						,@REPETSEPARATOER
		--						,@GetDate
		--						,@pUser
		--						,@GetDate
		--						,@pFileId
		--				FROM #Insert_AddressList Feed 
		--				INNER JOIN #ImportFeedData FEED1 ON Feed.IndividualGuid = FEED1.IndividualGUID 
		--				INNER JOIN OrderedContactMechanism OCM ON Feed.IndividualGuid = OCM.Candidate_Id AND OCM.[Order] = Feed.[Order]
		--					INNER JOIN [address] A ON A.GUIDReference = OCM.Address_Id						
		--					INNER JOIN AddressType AT ON A.[Type_Id] = AT.Id	
		--					INNER JOIN TranslationTerm TT ON At.Description_Id = TT.Translation_Id
		--                                        WHERE TT.VALUE != Feed.AddressType AND TT.CultureCode = @pCultureCode
		--					END
		--				END
		SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'AddressType'
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
			,'Home address already exists at Row ' + CONVERT(VARCHAR, FEED2.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,FEED2.FullRow
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM #Insert_AddressList FEED
		INNER JOIN #ImportFeedData FEED1 ON FEED.IndividualGuid = FEED1.IndividualGUID
		INNER JOIN @pImportFeed FEED2 ON FEED1.Rownumber = FEED2.Rownumber
		WHERE AddressType = 'Home'
			--AND FEED.[Order] IS NULL
			AND (
				FEED.[Order] IS NULL
				OR FEED.[Order] <> 1
				)
			AND EXISTS (
				SELECT *
				FROM OrderedContactMechanism OCM
				JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
				WHERE OCM.Candidate_Id = FEED.IndividualGuid
					AND A.Type_Id = FEED.AddressTypeGUID
				)

		IF @@ROWCOUNT > 0
			SET @Error = 1

		BEGIN -- HOME ADDRESS TYPE CAN NOT BE UPDATED
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
				,'Home address type can not be updated at Row ' + CONVERT(VARCHAR, FEED2.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,FEED2.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM #Insert_AddressList FEED
			INNER JOIN #ImportFeedData FEED1 ON FEED.IndividualGuid = FEED1.IndividualGUID
			INNER JOIN @pImportFeed FEED2 ON FEED1.Rownumber = FEED2.Rownumber
			WHERE AddressType <> 'Home'
				AND FEED.[Order] = 1

			IF @@ROWCOUNT > 0
				SET @Error = 1
		END

		IF OBJECT_ID('tempdb..#Insert_Panelist') IS NOT NULL
			DROP TABLE #Insert_Panelist

		CREATE TABLE #Insert_Panelist (
			PanelistGUID UNIQUEIDENTIFIER NOT NULL
			,PanelGUID UNIQUEIDENTIFIER NULL
			,PanelType NVARCHAR(200) NULL
			,GroupGUID UNIQUEIDENTIFIER NULL
			,IndividualGuid UNIQUEIDENTIFIER NULL
			,PanelStateId UNIQUEIDENTIFIER NULL
			,CommunicationMethodologyGUID UNIQUEIDENTIFIER NULL
			,ChangeReasonId UNIQUEIDENTIFIER NULL
			,MethodologyChangeComment NVARCHAR(MAX) NULL
			,PanelRoleCode INT NULL
			,GroupRoleCode INT NULL
			)

		IF OBJECT_ID('tempdb..#Update_Panelist') IS NOT NULL
			DROP TABLE #Update_Panelist

		CREATE TABLE #Update_Panelist (
			PanelistGUID UNIQUEIDENTIFIER NOT NULL
			,PanelGUID UNIQUEIDENTIFIER NULL
			,PanelType NVARCHAR(200) NULL
			,GroupGUID UNIQUEIDENTIFIER NULL
			,IndividualGuid UNIQUEIDENTIFIER NULL
			,PanelStateId UNIQUEIDENTIFIER NULL
			,CommunicationMethodologyGUID UNIQUEIDENTIFIER NULL
			,ChangeReasonId UNIQUEIDENTIFIER NULL
			,MethodologyChangeComment NVARCHAR(MAX) NULL
			,PanelRoleCode INT NULL
			,GroupRoleCode INT NULL
			)

		INSERT INTO #Insert_Panelist (
			PanelGUID
			,PanelType
			,GroupGUID
			,IndividualGuid
			,PanelStateId
			,CommunicationMethodologyGUID
			,ChangeReasonId
			,MethodologyChangeComment
			,PanelRoleCode
			,GroupRoleCode
			,PanelistGUID
			)
		SELECT P.GUIDReference
			,P.[Type]
			,FEED.GroupGuid
			,FEED.IndividualGuid
			,ISNULL(SD.Id, @PanelistDefaultStateId)
			,CM.GUIDReference
			,CMCR.ChangeReasonId
			,REP.PanelistCommunicationMethodologyChangeComment
			,CAST(ISNULL(REP.[PanelRoleCode], '0') AS INT)
			,CAST(ISNULL(REP.[GroupRoleCode], '0') AS INT)
			,NewID()
		FROM @pRepeatableData REP
		INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
		LEFT JOIN Panel P ON P.PanelCode = REP.PanelCode
			AND P.Country_Id = @pCountryId
		LEFT JOIN Panelist PL ON (
				PL.PanelMember_Id = Feed.IndividualGuid
				OR PL.PanelMember_Id = Feed.GroupGuid
				)
			AND PL.Panel_Id = P.GUIDReference
		LEFT JOIN StateDefinition SD ON SD.Code = REP.PanelistStateCode
			AND SD.Country_Id = @pCountryId
		LEFT JOIN CollaborationMethodology CM ON CM.Code = REP.PanelistCommunicationMethodology
			AND CM.Country_Id = @pCountryId
		LEFT JOIN CollaborationMethodologyChangeReason CMCR ON dbo.GetTranslationValue(Description_Id, @pCultureCode) = REP.PanelistCommunicationMethodologyChangeReason
			AND CMCR.Country_Id = @pCountryId
		WHERE PL.GUIDReference IS NULL

		INSERT INTO #Update_Panelist (
			PanelGUID
			,PanelType
			,GroupGUID
			,IndividualGuid
			,PanelStateId
			,CommunicationMethodologyGUID
			,ChangeReasonId
			,MethodologyChangeComment
			,PanelRoleCode
			,GroupRoleCode
			,PanelistGUID
			)
		SELECT P.GUIDReference
			,P.[Type]
			,FEED.GroupGuid
			,FEED.IndividualGuid
			,SD.Id --ISNULL(SD.Id, @PanelistDefaultStateId)
			,CM.GUIDReference
			,CMCR.ChangeReasonId
			,REP.PanelistCommunicationMethodologyChangeComment
			,CAST(ISNULL(REP.[PanelRoleCode], '0') AS INT)
			,CAST(ISNULL(REP.[GroupRoleCode], '0') AS INT)
			,PL.GUIDReference
		FROM @pRepeatableData REP
		INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
		INNER JOIN Panel P ON P.PanelCode = REP.PanelCode
			AND P.Country_Id = @pCountryId
		INNER JOIN Panelist PL ON (
				PL.PanelMember_Id = Feed.IndividualGuid
				OR PL.PanelMember_Id = Feed.GroupGuid
				)
			AND PL.Panel_Id = P.GUIDReference
		LEFT JOIN StateDefinition SD ON SD.Code = REP.PanelistStateCode
			AND SD.Country_Id = @pCountryId
		LEFT JOIN CollaborationMethodology CM ON CM.Code = REP.PanelistCommunicationMethodology
			AND CM.Country_Id = @pCountryId
		LEFT JOIN CollaborationMethodologyChangeReason CMCR ON dbo.GetTranslationValue(Description_Id, @pCultureCode) = REP.PanelistCommunicationMethodologyChangeReason
			AND CMCR.Country_Id = @pCountryId

		IF OBJECT_ID('tempdb..#IndividualCTE') IS NOT NULL
			DROP TABLE #IndividualCTE

		DECLARE @GuidInd UNIQUEIDENTIFIER;

		SET @GuidInd = (
				SELECT TOP 1 IndividualGuid
				FROM #ImportFeedData
				)

		SELECT tOld.KeyName
			,ocm.Candidate_Id AS CandidateId
			,ocm.[Order] AS tempOrder
			,ocm.Id AS tempId
			,ocm.Address_Id AS tempAddress_Id
			,a.[Type_Id]
			,ROW_NUMBER() OVER (
				PARTITION BY atOld.DiscriminatorType ORDER BY [Order]
				) AS RowNumber
			,atOld.DiscriminatorType
		INTO #IndividualCTE
		FROM OrderedContactMechanism ocm
		JOIN [Address] a ON ocm.Address_Id = a.GUIDReference
		JOIN AddressType atOld ON a.[Type_id] = atOld.id
		JOIN Translation tOld ON tOld.TranslationId = atOld.Description_Id
			AND (
				tOld.KeyName LIKE '%PhoneType%'
				OR tOld.KeyName LIKE '%Email%Type%'
				)
		JOIN #ImportFeedData d ON d.IndividualGuid = ocm.Candidate_Id

		IF (@Error > 0)
		BEGIN
			EXEC InsertImportFile 'ImportFileBusinessValidationError'
				,@pUser
				,@pFileId
				,@pCountryId
		END
		ELSE
		BEGIN
			BEGIN TRY
				--Start Insert
				BEGIN TRANSACTION

				BEGIN
					/* Personal Identification - start */
					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'DateOfBirth'
							)
					BEGIN
						UPDATE PID
						SET PID.DateOfBirth = FEED.DateOfBirth
							,PID.GPSUpdateTimestamp = @GetDate
							,PID.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN PersonalIdentification PID ON FEED.PersonalIdentificationId = PID.PersonalIdentificationId
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'LastName'
							)
					BEGIN
						UPDATE PID
						SET PID.LastOrderedName = FEED.LastName
							,PID.GPSUpdateTimestamp = @GetDate
							,PID.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN PersonalIdentification PID ON FEED.PersonalIdentificationId = PID.PersonalIdentificationId
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'MiddleName'
							)
					BEGIN
						UPDATE PID
						SET PID.MiddleOrderedName = FEED.MiddleName
							,PID.GPSUpdateTimestamp = @GetDate
							,PID.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN PersonalIdentification PID ON FEED.PersonalIdentificationId = PID.PersonalIdentificationId
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'FirstName'
							)
					BEGIN
						UPDATE PID
						SET PID.FirstOrderedName = FEED.FirstName
							,PID.TitleId = FEED.TitleGuid
							,PID.GPSUpdateTimestamp = @GetDate
							,PID.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN PersonalIdentification PID ON FEED.PersonalIdentificationId = PID.PersonalIdentificationId
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'Title'
							)
					BEGIN
						UPDATE PID
						SET PID.TitleId = FEED.TitleGuid
							,PID.GPSUpdateTimestamp = @GetDate
							,PID.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN PersonalIdentification PID ON FEED.PersonalIdentificationId = PID.PersonalIdentificationId
					END

					/* Personal Identification - end */
					/* Enrollment Date change - start */
					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'EnrollmentDate'
							)
					BEGIN
						UPDATE C
						SET C.EnrollmentDate = FEED.EnrollmentDate
							,C.GPSUpdateTimestamp = @GetDate
							,C.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN Candidate C ON FEED.IndividualGuid = C.GUIDReference
					END

					/* Enrollment end date change - end */
					/* Address Changes - Start */
					UPDATE A
					SET A.AddressLine1 = CASE 
							WHEN EXISTS (
									SELECT 1
									FROM @pColumn P
									WHERE P.ColumnName = 'HomeAddressLine1'
									)
								THEN FEED.HomeAddressLine1
							ELSE A.AddressLine1
							END
						,A.AddressLine2 = CASE 
							WHEN EXISTS (
									SELECT 1
									FROM @pColumn P
									WHERE P.ColumnName = 'HomeAddressLine2'
									)
								THEN FEED.HomeAddressLine2
							ELSE A.AddressLine2
							END
						,A.AddressLine3 = CASE 
							WHEN EXISTS (
									SELECT 1
									FROM @pColumn P
									WHERE P.ColumnName = 'HomeAddressLine3'
									)
								THEN FEED.HomeAddressLine3
							ELSE A.AddressLine3
							END
						,A.AddressLine4 = CASE 
							WHEN EXISTS (
									SELECT 1
									FROM @pColumn P
									WHERE P.ColumnName = 'HomeAddressLine4'
									)
								THEN FEED.HomeAddressLine4
							ELSE A.AddressLine4
							END
						,A.PostCode = CASE 
							WHEN EXISTS (
									SELECT 1
									FROM @pColumn P
									WHERE P.ColumnName = 'HomePostCode'
									)
								THEN FEED.HomePostCode
							ELSE A.PostCode
							END
						,A.GPSUser = @pUser
						,A.GPSUpdateTimestamp = @GetDate
					FROM #ImportFeedData FEED
					INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
						AND OCM.[Order] = 1
					INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
						AND A.[Type_Id] = @postalAddressTypeGuid
					WHERE A.[AddressType] = 'PostalAddress'
						AND OCM.[Order] = 1

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
					SELECT FEED.PostalAddressGuid
						,FEED.HomeAddressLine1
						,@pUser
						,@GetDate
						,@GetDate
						,FEED.HomeAddressLine2
						,FEED.HomeAddressLine3
						,FEED.HomeAddressLine4
						,FEED.HomePostCode
						,@postalAddressTypeGuid
						,'PostalAddress'
						,@pCountryId
					FROM #ImportFeedData FEED
					WHERE NOT EXISTS (
							SELECT 1
							FROM OrderedContactMechanism OCM
							INNER JOIN [Address] A ON OCM.Candidate_Id = FEED.IndividualGuid
								AND OCM.Address_Id = A.GUIDReference
								AND OCM.[Order] = 1
								AND A.[Type_Id] = @postalAddressTypeGuid
							)

					INSERT INTO OrderedContactMechanism (
						Id
						,[Order]
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Candidate_Id
						,Address_Id
						,Country_Id
						)
					SELECT NEWID()
						,1
						,@puser
						,@GetDate
						,@GetDate
						,feed.IndividualGuid
						,FEED.PostalAddressGuid
						,@pCountryId
					FROM #ImportFeedData FEED
					WHERE NOT EXISTS (
							SELECT 1
							FROM OrderedContactMechanism OCM
							INNER JOIN [Address] A ON OCM.Candidate_Id = FEED.IndividualGuid
								AND OCM.Address_Id = A.GUIDReference
								AND OCM.[Order] = 1
								AND A.[Type_Id] = @postalAddressTypeGuid
							)

					/**********MULTIPLE ADDRESS HANDLE*********/
					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'AddressType'
							)
					BEGIN
						UPDATE A
						SET A.[Type_Id] = ISNULL(AT.Id, A.[Type_Id])
							,A.GPSUpdateTimestamp = @GetDate
							,A.GPSUser = @pUser
						FROM #Insert_AddressList FEED
						INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
							AND OCM.[Order] = FEED.[Order]
						INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
						JOIN #AddressTypes AT ON AT.AddressType LIKE FEED.AddressType
						WHERE A.[AddressType] = 'PostalAddress'
							AND OCM.[Order] = FEED.[ORDER]
							AND FEED.AddressLine1 IS NOT NULL
					END

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
						FROM #Insert_AddressList FEED
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
						FROM #Insert_AddressList FEED
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
						FROM #Insert_AddressList FEED
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
						FROM #Insert_AddressList FEED
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
						FROM #Insert_AddressList FEED
						INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
							AND OCM.[Order] = FEED.[ORDER]
						INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
						WHERE A.[AddressType] = 'PostalAddress'
							AND OCM.[Order] = FEED.[ORDER]
							AND FEED.PostCode IS NOT NULL
					END

					IF EXISTS (
							SELECT 1
							FROM #Insert_AddressList
							WHERE AddressType IS NOT NULL
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
						FROM #Insert_AddressList FEED
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
							,OORDER + (
								ROW_NUMBER() OVER (
									PARTITION BY O.Candidate_Id ORDER BY O.Candidate_Id
									)
								) AS [Order]
							,@puser AS GPSUser
							,@GetDate AS GPSUpdateTimestamp
							,@GetDate AS CreationTimeStamp
							,feed.IndividualGuid AS Candidate_Id
							,feed.AddressListGUID AS Address_Id
							,@pCountryId
						FROM #Insert_AddressList feed
						JOIN (
							SELECT Candidate_Id
								,MAX(ocm.[ORDER]) AS OORDER
							FROM OrderedContactMechanism ocm
							JOIN [Address] addr ON OCM.Address_Id = addr.GUIDReference
							JOIN #AddressTypes at ON at.Id = addr.[Type_id]
							JOIN #Insert_AddressList ad ON Candidate_Id = ad.IndividualGuid
							WHERE addr.Country_Id = @pCountryId
							GROUP BY Candidate_Id
							) O ON O.Candidate_Id = feed.IndividualGuid
						WHERE AddressType IS NOT NULL
							AND [Order] IS NULL
					END

					IF NOT EXISTS (
							SELECT 1
							FROM #Insert_AddressList IAL
							JOIN OrderedContactMechanism OCM ON IAL.IndividualGuid = OCM.CANDIDATE_ID
							JOIN [ADDRESS] A ON OCM.Address_id = a.GUIDREFERENCE
							WHERE A.AddressType = 'PostalAddress'
								AND OCM.[Order] = IAL.[Order]
								AND IAL.[Order] IS NOT NULL
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
						FROM #Insert_AddressList FEED
						WHERE AddressType IS NOT NULL
							AND FEED.[Order] IS NOT NULL

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
							,feed.[Order] AS [Order]
							,@puser AS GPSUser
							,@GetDate AS GPSUpdateTimestamp
							,@GetDate AS CreationTimeStamp
							,feed.IndividualGuid AS Candidate_Id
							,feed.AddressListGUID AS Address_Id
							,@pCountryId
						FROM #Insert_AddressList feed
						JOIN (
							SELECT Candidate_Id
								,MAX(ocm.[ORDER]) AS OORDER
							FROM OrderedContactMechanism ocm
							JOIN [Address] addr ON OCM.Address_Id = addr.GUIDReference
							JOIN #AddressTypes at ON at.Id = addr.[Type_id]
							JOIN #Insert_AddressList ad ON Candidate_Id = ad.IndividualGuid
							WHERE addr.Country_Id = @pCountryId
							GROUP BY Candidate_Id
							) O ON O.Candidate_Id = feed.IndividualGuid
						WHERE AddressType IS NOT NULL
							AND FEED.[Order] IS NOT NULL
					END

					/*********************************************/
					UPDATE C
					SET C.GeographicArea_Id = GA.GUIDReference
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData Feed
					--INNER JOIN Individual I ON Feed.IndividualGUID = I.GUIDReference
					JOIN COllectiveMembership CM1 ON CM1.Group_Id = Feed.GroupGuid
					INNER JOIN Candidate C ON CM1.Individual_Id = C.GUIDReference
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
					WHERE ISNULL(Feed.GACode, '') <> ''

					UPDATE C
					SET C.GeographicArea_Id = GA.GUIDReference
						,C.GPSUser = @pUser
						,C.GPSUpdateTimestamp = @GetDate
					FROM #ImportFeedData Feed
					INNER JOIN Collective G ON Feed.GroupGuid = G.GUIDReference
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
					WHERE ISNULL(Feed.GACode, '') <> ''

					/* Postal Address Changes - End */
					--UPDATE A
					--SET A.AddressLine1 = ISNULL(FEED.AddressLine1, A.AddressLine1)
					--     ,A.AddressLine2 = ISNULL(FEED.AddressLine2, A.AddressLine2)
					--     ,A.AddressLine3 = ISNULL(FEED.AddressLine3, A.AddressLine3)
					--     ,A.AddressLine4 = ISNULL(FEED.AddressLine4, A.AddressLine4)
					--FROM #ImportFeedData FEED
					--INNER JOIN ADDRESS A ON FEED.PostalAddressGuid = A.GUIDReference
					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'EmailAddress'
							)
					BEGIN
						UPDATE A
						SET A.AddressLine1 = FEED.EmailAddress
							,A.GPSUpdateTimestamp = @GetDate
							,A.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN OrderedContactMechanism OCM ON FEED.IndividualGuid = OCM.Candidate_Id
							AND OCM.[Order] = 1
						INNER JOIN [Address] A ON OCM.Address_Id = A.GUIDReference
							AND A.[Type_Id] = @emailAddressTypeGuid
						WHERE A.[AddressType] = 'ElectronicAddress'
							AND OCM.[Order] = 1

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
						SELECT FEED.ElectronicAddressGuid
							,FEED.EmailAddress
							,@pUser
							,@GetDate
							,@GetDate
							,NULL
							,NULL
							,NULL
							,NULL
							,@emailAddressTypeGuid
							,'ElectronicAddress'
							,@pCountryId
						FROM #ImportFeedData FEED
						WHERE NOT EXISTS (
								SELECT 1
								FROM OrderedContactMechanism OCM
								INNER JOIN [Address] A ON OCM.Candidate_Id = FEED.IndividualGuid
									AND OCM.Address_Id = A.GUIDReference
									AND OCM.[Order] = 1
									AND A.[Type_Id] = @emailAddressTypeGuid
								)
							AND Len(LTRIM(Rtrim(Feed.EmailAddress))) > 0

						INSERT INTO OrderedContactMechanism (
							Id
							,[Order]
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,Candidate_Id
							,Address_Id
							,Country_Id
							)
						SELECT NEWID()
							,1
							,@puser
							,@GetDate
							,@GetDate
							,feed.IndividualGuid
							,feed.ElectronicAddressGuid
							,@pCountryId
						FROM #ImportFeedData FEED
						WHERE NOT EXISTS (
								SELECT 1
								FROM OrderedContactMechanism OCM
								INNER JOIN [Address] A ON OCM.Candidate_Id = FEED.IndividualGuid
									AND OCM.Address_Id = A.GUIDReference
									AND OCM.[Order] = 1
									AND A.[Type_Id] = @emailAddressTypeGuid
								)
							AND Len(LTRIM(Rtrim(Feed.EmailAddress))) > 0
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] IN ('Phone')
							)
					BEGIN
						IF (1 = 1) --EXISTS(SELECT 1 FROM Fieldconfiguration WHERE [Key]= 'IsAddresscardchangesRequired')
						BEGIN
							-- UPDATE EXISTING PHONES
							UPDATE a
							SET AddressLine1 = rdata.Phone
								,[Type_Id] = atNew.Id
								,a.GPSUser = @pUser
								,a.GPSUpdateTimestamp = @GetDate
							FROM @pRepeatableData rdata
							JOIN #ImportFeedData feed ON feed.Rownumber = rdata.Rownumber
							JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id = feed.IndividualGuid
							JOIN [Address] a ON ocm.Address_Id = a.GUIDReference
							JOIN #IndividualCTE Ct ON ct.tempId = ocm.Id
								AND ocm.Address_Id = Ct.tempAddress_Id
								AND ocm.[Order] = Ct.tempOrder
							JOIN Translation tNew ON tNew.KeyName = rdata.PhoneType
							JOIN AddressType atNew ON atNew.Description_Id = tNew.TranslationId
								AND atNew.DiscriminatorType = ct.DiscriminatorType
							WHERE rdata.PhoneOrder IS NOT NULL
								AND rdata.PhoneOrder <> ''
								AND Ct.tempOrder = rdata.PhoneOrder
								AND ocm.Id = Ct.tempId
								AND tNew.KeyName = rdata.PhoneType
								AND a.[Type_Id] = ct.[Type_Id]
						END
						ELSE
						BEGIN
							UPDATE a
							SET AddressLine1 = rdata.Phone
								,[Type_Id] = atNew.Id
								,a.GPSUser = @pUser
								,a.GPSUpdateTimestamp = @GetDate
							FROM @pRepeatableData rdata
							JOIN #ImportFeedData feed ON feed.Rownumber = rdata.Rownumber
							JOIN OrderedContactMechanism ocm ON ocm.[Order] = rdata.PhoneOrder
								AND ocm.Candidate_Id = feed.IndividualGuid
							JOIN [Address] a ON ocm.Address_Id = a.GUIDReference
							JOIN AddressType atOld ON a.[Type_id] = atOld.id
							JOIN Translation tOld ON tOld.TranslationId = atOld.Description_Id
								AND tOld.KeyName LIKE '%PhoneType%'
							JOIN Translation tNew ON tNew.KeyName LIKE rdata.PhoneType
							JOIN AddressType atNew ON atNew.Description_Id = tNew.TranslationId
							WHERE rdata.PhoneOrder IS NOT NULL
								AND rdata.PhoneOrder <> ''
						END

						-- CREATE NEW PHONES
						IF OBJECT_ID('tempdb..#TempPhoneCreate') IS NOT NULL
							DROP TABLE #TempPhoneCreate

						SELECT NEWID() AS AddressId
							,NEWID() AS OrderedId
							,feed.IndividualGuid
							,rdata.Phone
							,rdata.PhoneType
							,AT.Id AS PhoneTypeId
							,CASE 
								WHEN ISNULL(rdata.PhoneOrder, '') <> ''
									THEN rdata.PhoneOrder
								ELSE ISNULL((
											SELECT MAX([Order])
											FROM OrderedContactMechanism ocm
											JOIN [Address] ad ON ad.GUIDReference = ocm.Address_Id
												AND ad.AddressType LIKE '%Phone%'
												AND ocm.Candidate_Id = feed.IndividualGuid
											), 0) + ROW_NUMBER() OVER (
										PARTITION BY feed.IndividualGuid ORDER BY feed.IndividualGuid
										)
								END AS AddressOrder
						INTO #TempPhoneCreate
						FROM @pRepeatableData rdata
						JOIN #ImportFeedData feed ON feed.Rownumber = rdata.Rownumber
						JOIN Translation T ON T.KeyName = rdata.PhoneType
						JOIN AddressType AT ON AT.Description_Id = T.TranslationId
							AND AT.DiscriminatorType = 'PhoneAddressType'
						WHERE (
								rdata.Phone IS NOT NULL
								AND rdata.Phone <> ''
								)
							AND (
								ISNULL(rdata.PhoneOrder, '') = ''
								OR rdata.PhoneOrder NOT IN (
									SELECT tempOrder
									FROM #IndividualCTE ocma
									WHERE ocma.DiscriminatorType = AT.DiscriminatorType
										AND CandidateId = feed.IndividualGuid
									)
								)

						INSERT INTO [Address] (
							GUIDReference
							,AddressLine1
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,[Type_Id]
							,AddressType
							,Country_Id
							)
						SELECT AddressId
							,Phone
							,@pUser
							,@GetDate
							,@GetDate
							,PhoneTypeId
							,'PhoneAddress'
							,@pCountryId
						FROM #TempPhoneCreate tp
						ORDER BY IndividualGuid ASC
							,AddressOrder ASC

						INSERT INTO OrderedContactMechanism (
							Id
							,[Order]
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,Candidate_Id
							,Address_Id
							,Country_Id
							)
						SELECT OrderedID
							,AddressOrder
							,@puser
							,@GetDate
							,@GetDate
							,IndividualGuid
							,tp.AddressId
							,@pCountryId
						FROM #TempPhoneCreate tp
						ORDER BY IndividualGuid ASC
							,AddressOrder ASC
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] IN ('Email')
							)
					BEGIN
						IF (1 = 1) --EXISTS(SELECT 1 FROM Fieldconfiguration WHERE [Key]= 'IsAddresscardchangesRequired')
						BEGIN
							-- UPDATE EXISTING EMAILS
							UPDATE a
							SET AddressLine1 = rdata.Email
								,a.GPSUser = @pUser
								,a.GPSUpdateTimestamp = @GetDate
								,a.Type_Id = atNew.Id
							FROM @pRepeatableData rdata
							JOIN #ImportFeedData feed ON feed.Rownumber = rdata.Rownumber
							JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id = feed.IndividualGuid
							JOIN [Address] a ON ocm.Address_Id = a.GUIDReference
								AND a.AddressType = 'ElectronicAddress'
							JOIN #IndividualCTE Ct ON ct.tempId = ocm.Id
								AND ocm.Address_Id = Ct.tempAddress_Id
								AND ocm.[Order] = Ct.tempOrder
							JOIN Translation tNew ON tNew.KeyName = rdata.EmailType
							JOIN AddressType atNew ON atNew.Description_Id = tNew.TranslationId
								AND atNew.DiscriminatorType = 'ElectronicAddressType'
							WHERE rdata.EmailOrder IS NOT NULL
								AND rdata.EmailOrder <> ''
								AND Ct.tempOrder = rdata.EmailOrder
								AND ocm.Id = Ct.tempId
								AND tNew.KeyName = rdata.EmailType
								AND a.[Type_Id] = ct.[Type_Id]
						END
						ELSE
						BEGIN
							UPDATE a
							SET AddressLine1 = rdata.Email
								,[Type_Id] = atNew.Id
								,a.GPSUser = @pUser
								,a.GPSUpdateTimestamp = @GetDate
							FROM @pRepeatableData rdata
							JOIN #ImportFeedData feed ON feed.Rownumber = rdata.Rownumber
							JOIN OrderedContactMechanism ocm ON ocm.[Order] = rdata.EmailOrder
								AND ocm.Candidate_Id = feed.IndividualGuid
							JOIN [Address] a ON ocm.Address_Id = a.GUIDReference
							JOIN AddressType atOld ON a.[Type_id] = atOld.id
							JOIN Translation tOld ON tOld.TranslationId = atOld.Description_Id
								AND tOld.KeyName LIKE '%EmailType%'
							JOIN Translation tNew ON tNew.KeyName LIKE rdata.EmailType
							JOIN AddressType atNew ON atNew.Description_Id = tNew.TranslationId
							WHERE rdata.EmailOrder IS NOT NULL
								AND rdata.EmailOrder <> ''
						END

						-- CREATE NEW EMAILS
						IF OBJECT_ID('tempdb..#TempEmailCreate') IS NOT NULL
							DROP TABLE #TempEmailCreate

						SELECT NEWID() AS AddressId
							,NEWID() AS OrderedId
							,feed.IndividualGuid
							,rdata.Email
							,rdata.EmailType
							,AT.Id AS EmailTypeId
							,ISNULL((
									SELECT MAX([Order])
									FROM OrderedContactMechanism ocm
									JOIN [Address] ad ON ad.GUIDReference = ocm.Address_Id
									JOIN [AddressType] at ON at.Id = ad.[TYPE_ID]
										AND at.DiscriminatorType = 'ElectronicAddressType'
									WHERE ocm.Candidate_Id = feed.IndividualGuid
									), 0) + ROW_NUMBER() OVER (
								PARTITION BY feed.IndividualGuid ORDER BY feed.IndividualGuid
								) AS AddressOrder
						INTO #TempEmailCreate
						FROM @pRepeatableData rdata
						JOIN #ImportFeedData feed ON feed.Rownumber = rdata.Rownumber
						JOIN Translation T ON T.KeyName = rdata.EmailType
						JOIN AddressType AT ON AT.Description_Id = T.TranslationId
							AND AT.DiscriminatorType = 'ElectronicAddressType'
						WHERE (
								rdata.Email IS NOT NULL
								AND rdata.Email <> ''
								)
							AND (
								rdata.EmailOrder IS NULL
								OR rdata.EmailOrder = ''
								)

						INSERT INTO [Address] (
							GUIDReference
							,AddressLine1
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,[Type_Id]
							,AddressType
							,Country_Id
							)
						SELECT AddressId
							,Email
							,@pUser
							,@GetDate
							,@GetDate
							,EmailTypeId
							,'ElectronicAddress'
							,@pCountryId
						FROM #TempEmailCreate tp
						ORDER BY IndividualGuid ASC
							,AddressOrder ASC

						INSERT INTO OrderedContactMechanism (
							Id
							,[Order]
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,Candidate_Id
							,Address_Id
							,Country_Id
							)
						SELECT OrderedID
							,AddressOrder
							,@puser
							,@GetDate
							,@GetDate
							,IndividualGuid
							,tp.AddressId
							,@pCountryId
						FROM #TempEmailCreate tp
						ORDER BY IndividualGuid ASC
							,AddressOrder ASC
					END

					UPDATE I
					SET I.MainPostalAddress_Id = FEED.PostalAddressGuid
						,I.GPSUpdateTimestamp = @GetDate
						,I.GPSUser = @pUser
					FROM #ImportFeedData FEED
					INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
					WHERE I.MainPostalAddress_Id IS NULL
						AND EXISTS (
							SELECT 1
							FROM [Address]
							WHERE GUIDReference = FEED.PostalAddressGuid
							)

					UPDATE I
					SET I.MainPhoneAddress_Id = FEED.HomeAddressGuid
						,I.GPSUpdateTimestamp = @GetDate
						,I.GPSUser = @pUser
					FROM #ImportFeedData FEED
					INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
					WHERE I.MainPhoneAddress_Id IS NULL
						AND EXISTS (
							SELECT 1
							FROM [Address]
							WHERE GUIDReference = FEED.HomeAddressGuid
							)

					UPDATE I
					SET I.MainEmailAddress_Id = FEED.ElectronicAddressGuid
						,I.GPSUpdateTimestamp = @GetDate
						,I.GPSUser = @pUser
					FROM #ImportFeedData FEED
					INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
					WHERE I.MainEmailAddress_Id IS NULL
						AND EXISTS (
							SELECT 1
							FROM [Address]
							WHERE GUIDReference = FEED.ElectronicAddressGuid
							)

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'Sex'
							)
					BEGIN
						UPDATE I
						SET I.Sex_Id = FEED.SexGuid
							,I.GPSUpdateTimestamp = @GetDate
							,I.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'NonParticipant'
							)
					BEGIN
						UPDATE I
						SET I.Participant = FEED.NonParticipant
							,I.GPSUpdateTimestamp = @GetDate
							,I.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'SupportCharity'
							)
					BEGIN
						UPDATE I
						SET I.CharitySubscription_Id = CA.GUIDReference
							,I.GPSUpdateTimestamp = @GetDate
							,I.GPSUser = @pUser
						FROM #ImportFeedData FEED
						INNER JOIN CharityAmount CA ON FEED.AmountValue = CA.Value
							AND CA.Country_Id = @pCountryId
						INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
						WHERE FEED.SupportCharity = 1
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'Comments'
							)
					BEGIN
						--UPDATE IC
						--SET IC.Comment = FEED.Comments
						--FROM #ImportFeedData FEED
						--INNER JOIN IndividualComment IC ON FEED.IndividualGuid = IC.Individual_Id
						--	AND IC.Country_Id = @pCountryId
						--	AND ( FEED.Comments IS NOT NULL OR FEED.Comments <> '' )
						--	AND IC.Id = (SELECT TOP 1 Id FROM IndividualComment WHERE Individual_Id = FEED.IndividualGuid ORDER BY GPSUpdateTimestamp DESC)
						INSERT INTO IndividualComment (
							Id
							,Comment
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,Country_Id
							,Individual_Id
							)
						SELECT NEWID()
							,feed.Comments
							,@pUser
							,@GetDate
							,@GetDate
							,@pCountryId
							,feed.IndividualGuid
						FROM #ImportFeedData feed
						WHERE feed.Comments IS NOT NULL
							AND NOT EXISTS (
								SELECT 1
								FROM IndividualComment ic
								WHERE ic.Individual_Id = feed.IndividualGuid
									AND ic.Country_Id = @pCountryId
									AND ic.Comment = feed.Comments
								)
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'FrecuencyValue'
							)
					BEGIN
						SELECT NEWID() AS Id
							,FEED.NextEvent AS [Date]
							,(
								CASE 
									WHEN EF.IsNotApplicable = 0
										OR EF.IsDefault = 0
										THEN 'NullCalendarEvent'
									ELSE 'CalendarEvent'
									END
								) AS Discriminator
							,EF.GUIDReference AS Frequency_Id
							,FEED.IndividualGuid
						INTO #CalenderEvent
						FROM #ImportFeedData FEED
						INNER JOIN EventFrequency EF ON FEED.FrecuencyValue = dbo.GetTranslationValue(EF.Translation_Id, @pCultureCode)
							AND Country_Id = @pCountryId

						INSERT INTO CalendarEvent (
							Id
							,[Date]
							,Discriminator
							,Frequency_Id
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							)
						SELECT Id
							,[Date]
							,Discriminator
							,Frequency_Id
							,@pUser
							,@GetDate
							,@GetDate
						FROM #CalenderEvent

						UPDATE I
						SET I.Event_Id = CE.Id
							,I.GPSUpdateTimestamp = @GetDate
							,I.GPSUser = @pUser
						FROM #CalenderEvent CE
						INNER JOIN Individual I ON CE.IndividualGuid = I.GUIDReference
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'CommunicationContactMechanismCode'
							)
					BEGIN
						SELECT ISNULL(CE.GUIDReference, NEWID()) AS CommunicationEventId
							,FEED.CommunicationCreationDateTime AS creationDateTime
							,FEED.IndividualGuid AS candidateId
							,CMT.GUIDReference AS contactMechanismType
							,2 AS [State]
							,(
								CASE 
									WHEN FEED.CommunicationIncoming = 1
										OR FEED.CommunicationIncoming = 'Incoming'
										THEN 1
									ELSE 0
									END
								) AS Incoming
							,FEED.IndividualGuid
						INTO #Insert_CommunicationEvent
						FROM ContactMechanismType CMT
						INNER JOIN #ImportFeedData FEED ON CMT.ContactMechanismCode = FEED.CommunicationContactMechanismCode
							AND CMT.Country_Id = @pCountryId
						LEFT JOIN CommunicationEvent CE ON CE.CreationDate = FEED.CommunicationCreationDateTime
							AND CE.Candidate_Id = FEED.IndividualGuid
							AND CE.Country_Id = @pCountryId

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
						SELECT Newid()
							,'Reason process import' AS Comment
							,@pUser
							,@GetDate
							,@GetDate
							,CRT.GUIDReference AS CommunicationEventReasonType
							,@pCountryId
							,ICE.CommunicationEventId
							,NULL AS Panel
						FROM CommunicationEventReasonType CRT
						INNER JOIN #ImportFeedData FEED ON CRT.CommEventReasonCode = FEED.CommunicationCommReasonType
							AND CRT.Country_Id = @pCountryId
						INNER JOIN #Insert_CommunicationEvent ICE ON ICE.IndividualGuid = FEED.IndividualGuid

						INSERT INTO CommunicationEvent (
							GUIDReference
							,CreationDate
							,Incoming
							,[State]
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,CallLength
							,ContactMechanism_Id
							,Country_Id
							,Candidate_Id
							)
						SELECT ICE.CommunicationEventId
							,ICE.creationDateTime
							,ICE.Incoming
							,ICE.[State]
							,@pUser
							,@GetDate
							,@GetDate
							,'00:00:00.0000000'
							,ICE.contactMechanismType
							,@pCountryId
							,ICE.IndividualGuid
						FROM #Insert_CommunicationEvent ICE
						WHERE NOT EXISTS (
								SELECT 1
								FROM CommunicationEvent CE
								WHERE CE.GUIDReference = ICE.CommunicationEventId
								)
					END

					IF EXISTS (
							SELECT 1
							FROM @pColumn
							WHERE [ColumnName] = 'GroupMembershipStateCode'
							)
					BEGIN
						UPDATE DH
						SET DH.DateTo = @GetDate
							,DH.GPSUpdateTimestamp = @GetDate
							,DH.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
						INNER JOIN DynamicRoleAssignmentHistory DH ON DH.DynamicRoleAssignment_Id = D.DynamicRoleAssignmentId
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipDeceasedId

						UPDATE D
						SET D.Candidate_Id = NULL
							,D.GPSUpdateTimestamp = @GetDate
							,D.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipDeceasedId

						UPDATE DH
						SET DH.DateTo = @GetDate
							,DH.GPSUpdateTimestamp = @GetDate
							,DH.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
						INNER JOIN DynamicRoleAssignmentHistory DH ON DH.DynamicRoleAssignment_Id = D.DynamicRoleAssignmentId
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipNonResidentId

						UPDATE D
						SET D.Candidate_Id = NULL
							,D.GPSUpdateTimestamp = @GetDate
							,D.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipNonResidentId

						INSERT INTO StateDefinitionHistory (
							GUIDReference
							,GPSUser
							,CreationDate
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,Comments
							,CollaborateInFuture
							,From_Id
							,To_Id
							,ReasonForchangeState_Id
							,Country_Id
							,GroupMembership_Id
							)
						SELECT NEWID()
							,@pUser
							,@GetDate
							,@GetDate
							,@GetDate
							,NULL
							,0
							,CM.State_Id
							,Feed.GroupMembershipStateGuid
							,NULL
							,@pCountryId
							,CM.CollectiveMembershipId
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid

						/*

					UPDATE C

					SET C.GroupContact_Id=fn.NextIndividualGUID,C.GPSUpdateTimestamp=@GetDate,C.GPSUser=@pUser

					FROM #ImportFeedData Feed

					INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id

					INNER JOIN Collective C ON CM.Group_Id=C.GUIDReference

					CROSS APPLY dbo.[fnGetNextIndividualId](cmp.Individual_Id) fn 

					WHERE CM.State_Id <> Feed.GroupMembershipStateGuid AND Feed.GroupMembershipStateGuid=@GroupMembershipNonResidentId



					UPDATE CM

					SET CM.State_Id = Feed.GroupMembershipStateGuid

					,CM.GPSUpdateTimestamp=@GetDate,CM.GPSUser=@pUser

					FROM #ImportFeedData Feed

					INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id

					WHERE CM.State_Id <> Feed.GroupMembershipStateGuid AND Feed.GroupMembershipStateGuid=@GroupMembershipNonResidentId

					*/
						UPDATE C
						SET C.GroupContact_Id = fn.NextIndividualGUID
							,C.GPSUpdateTimestamp = @GetDate
							,C.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						INNER JOIN Collective C ON CM.Group_Id = C.GUIDReference
						CROSS APPLY dbo.[fnGetNextIndividualId](CM.Individual_Id) fn
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipDeceasedId
							AND C.GroupContact_Id = Feed.IndividualGuid
							AND fn.NextIndividualGUID IS NOT NULL
							AND fn.NextIndividualGUID <> C.GroupContact_Id

						UPDATE CM
						SET CM.State_Id = @GroupMembershipDeceasedId
							,CM.GPSUpdateTimestamp = @GetDate
							,CM.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipDeceasedId

						UPDATE C
						SET C.CandidateStatus = @individualStatusGuid
							,C.GPSUpdateTimestamp = @GetDate
							,C.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						INNER JOIN Candidate C ON C.GUIDReference = CM.Individual_Id
							AND Feed.IndividualGuid = C.GUIDreference
						WHERE --CM.State_Id <> Feed.GroupMembershipStateGuid AND 
							Feed.GroupMembershipStateGuid = @GroupMembershipNonResidentId
							AND C.CandidateStatus <> @individualStatusGuid

						UPDATE CM
						SET CM.State_Id = Feed.GroupMembershipStateGuid
							,CM.GPSUpdateTimestamp = @GetDate
							,CM.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid <> @GroupMembershipDeceasedId
							AND Feed.GroupMembershipStateGuid <> @GroupMembershipNonResidentId

						IF EXISTS (
								SELECT 1
								FROM #ImportFeedData Feed
								INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
								INNER JOIN Individual I ON I.GUIDReference = CM.Individual_Id
								INNER JOIN @pImportFeed f ON f.BusinessId = I.IndividualId
								WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
									AND Feed.GroupMembershipStateGuid = @GroupMembershipNonResidentId
									AND EXISTS (
										SELECT 1
										FROM Collective C
										WHERE C.GUIDReference = CM.Group_Id
											AND C.GroupContact_Id = Feed.IndividualGuid
										)
								)
						BEGIN
							DECLARE @msgex NVARCHAR(MAX)

							SET @msgex = (
									SELECT TOP 1 Feed.BusinessId
									FROM #ImportFeedData Feed
									INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
									INNER JOIN Individual I ON I.GUIDReference = CM.Individual_Id
									INNER JOIN @pImportFeed f ON f.BusinessId = I.IndividualId
									WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
										AND Feed.GroupMembershipStateGuid = @GroupMembershipNonResidentId
										AND EXISTS (
											SELECT 1
											FROM Collective C
											WHERE C.GUIDReference = CM.Group_Id
												AND C.GroupContact_Id = Feed.IndividualGuid
											)
									)
							SET @msgex = 'Multiple indiviudals group membership status has imported for the same group, Group contact should not be non resident for one of individual (BusinessId:' + @msgex + ')';

							RAISERROR (
									@msgex
									,16
									,1
									)
						END

						UPDATE CM
						SET CM.State_Id = Feed.GroupMembershipStateGuid
							,CM.GPSUpdateTimestamp = @GetDate
							,CM.GPSUser = @pUser
						FROM #ImportFeedData Feed
						INNER JOIN CollectiveMembership CM ON Feed.IndividualGuid = CM.Individual_Id
						WHERE CM.State_Id <> Feed.GroupMembershipStateGuid
							AND Feed.GroupMembershipStateGuid = @GroupMembershipNonResidentId
							AND NOT EXISTS (
								SELECT 1
								FROM Collective C
								WHERE C.GUIDReference = CM.Group_Id
									AND C.GroupContact_Id = Feed.IndividualGuid
								)
					END

					UPDATE av
					SET av.Value = D.DemographicValue
						,av.[Discriminator] = 'StringAttributeValue'
						,av.GPSUpdateTimestamp = @GetDate
						,av.GPSUser = @pUser
					FROM #Demographics D
					INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
						AND (
							AV.CandidateId = D.IndividualId
							OR av.CandidateId = (
								CASE 
									WHEN AttributeScope = 'Individual'
										THEN D.IndividualId
									ELSE d.GroupId
									END
								)
							)
					WHERE D.DemographicType = 'String'

					UPDATE av
					SET av.Value = D.DemographicValue
						,av.[Discriminator] = 'IntAttributeValue'
						,av.GPSUpdateTimestamp = @GetDate
						,av.GPSUser = @pUser
					FROM #Demographics D
					INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
						AND (
							AV.CandidateId = D.IndividualId
							OR av.CandidateId = (
								CASE 
									WHEN AttributeScope = 'Individual'
										THEN D.IndividualId
									ELSE d.GroupId
									END
								)
							)
					WHERE D.DemographicType = 'Int'

					UPDATE av
					SET av.Value = D.DemographicValue
						,av.[Discriminator] = 'FloatAttributeValue'
						,av.GPSUpdateTimestamp = @GetDate
						,av.GPSUser = @pUser
					FROM #Demographics D
					INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
						AND (
							AV.CandidateId = D.IndividualId
							OR av.CandidateId = (
								CASE 
									WHEN AttributeScope = 'Individual'
										THEN D.IndividualId
									ELSE d.GroupId
									END
								)
							)
					WHERE D.DemographicType = 'Float'

					UPDATE av
					SET av.Value = CONVERT(VARCHAR(30), CONVERT(DATETIME, D.DemographicValue), 20)
						,av.[Discriminator] = 'DateAttributeValue'
						,av.GPSUpdateTimestamp = @GetDate
						,av.GPSUser = @pUser
					FROM #Demographics D
					INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
						AND (
							AV.CandidateId = D.IndividualId
							OR av.CandidateId = (
								CASE 
									WHEN AttributeScope = 'Individual'
										THEN D.IndividualId
									ELSE d.GroupId
									END
								)
							)
					WHERE LOWER(D.DemographicType) IN (
							'date'
							,'datetime'
							)

					UPDATE av
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
						AND (
							AV.CandidateId = D.IndividualId
							OR av.CandidateId = CASE 
								WHEN AttributeScope = 'Individual'
									THEN D.IndividualId
								ELSE d.GroupId
								END
							)
					WHERE DemographicType = 'Boolean'

					UPDATE av
					SET av.[EnumDefinition_Id] = ED.Id
						,av.Value = DemographicValue
						,av.ValueDesc = TT.Value
						,av.[Discriminator] = 'EnumAttributeValue'
						,av.GPSUpdateTimestamp = @GetDate
						,av.GPSUser = @pUser
					FROM #Demographics D
					INNER JOIN AttributeValue AV ON AV.DemographicId = D.DemographicId
						AND (
							AV.CandidateId = D.IndividualId
							OR av.CandidateId = (
								CASE 
									WHEN AttributeScope = 'Individual'
										THEN D.IndividualId
									ELSE d.GroupId
									END
								)
							)
					INNER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.DemographicId
						AND ED.Value = D.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
					LEFT JOIN TranslationTerm TT ON ED.Translation_Id = TT.Translation_Id
						AND TT.CultureCode = @pCultureCode
					WHERE D.DemographicType = 'Enum'

					IF OBJECT_ID('tempdb..#InsertAttributeValue') IS NOT NULL
						DROP TABLE #InsertAttributeValue

					SELECT AttributeValueId AS AttributeValueId
						,DemographicId AS DemographicId
						,IndividualId AS IndividualId
						,NULL AS RespondentId
						,@pUser AS [User]
						,@GETDATE AS GPSUpdateTimestamp
						,@GETDATE AS CreationTimeStamp
						,NULL AS Address_Id
						,DemographicType
						,DemographicValue
						,AttributeScope
					INTO #InsertAttributeValue
					FROM #Demographics D
					WHERE NOT EXISTS (
							SELECT 1
							FROM AttributeValue AV
							WHERE AV.DemographicId = D.DemographicId
								AND (
									AV.CandidateId = D.IndividualId
									OR av.CandidateId = (
										CASE 
											WHEN AttributeScope = 'Individual'
												THEN D.IndividualId
											ELSE d.GroupId
											END
										)
									)
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
						,CASE 
							WHEN i.AttributeScope = 'HouseHold'
								THEN cm.Group_Id
							ELSE Individual_Id
							END
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
							WHEN DemographicType = 'Enum'
								THEN DemographicValue
							END
						,CASE 
							WHEN DemographicType = 'Enum'
								THEN (
										SELECT TOP 1 TT.Value
										FROM dbo.EnumDefinition ED
										LEFT JOIN TranslationTerm TT ON ED.Translation_Id = TT.Translation_Id
											AND TT.CultureCode = @pCultureCode
										WHERE ED.Demographic_Id = i.DemographicId
											AND ED.Value = i.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
										)
							END
						,CASE 
							WHEN DemographicType = 'Enum'
								THEN (
										SELECT ED.Id
										FROM dbo.EnumDefinition ED
										WHERE ED.Demographic_Id = i.DemographicId
											AND ED.Value = i.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
										)
							END
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
							WHEN DemographicType = 'Enum'
								THEN 'EnumAttributeValue'
							END
						,@pCountryId
					FROM #InsertAttributeValue i
					JOIN CollectiveMembership cm ON cm.Individual_Id = i.IndividualId

					/* Panel Repetable */
					/* individual panels */
					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,PL.State_Id
						,PanelStateId
						,NULL
						,@pCountryId
						,PanelistGUID
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.PanelStateId IS NOT NULL
						AND CMP.State_Id <> @GroupMembershipDeceasedId
						AND CMP.State_Id <> @GroupMembershipNonResidentId
						AND PL.State_Id <> PanelStateId

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,PL.State_Id
						,IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,NULL
						,@pCountryId
						,PanelistGUID
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.PanelStateId IS NOT NULL
						AND CMP.State_Id IN (
							@GroupMembershipDeceasedId
							,@GroupMembershipNonResidentId
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,PL.State_Id
						,IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,NULL
						,@pCountryId
						,PL.GUIDReference
					FROM #ImportFeedData IFD
					INNER JOIN Individual I ON IFD.IndividualGuid = I.GUIDReference
					INNER JOIN Panelist PL ON PL.PanelMember_Id = I.GUIDReference
					INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
					WHERE P.[Type] = 'Individual'
						AND CMP.State_Id IN (
							@GroupMembershipDeceasedId
							,@GroupMembershipNonResidentId
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = I.GUIDReference
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = I.GUIDReference
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					INSERT INTO CollaborationMethodologyHistory (
						GUIDReference
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,[Date]
						,GPSUser
						,Comments
						,Panelist_Id
						,OldCollaborationMethodology_Id
						,NewCollaborationMethodology_Id
						,Country_Id
						,CollaborationMethodologyChangeReason_Id
						)
					SELECT NEWID()
						,@GetDate
						,@GetDate
						,@GetDate
						,@pUser
						,IPL.MethodologyChangeComment
						,PL.GUIDReference
						,PL.CollaborationMethodology_Id
						,IPL.CommunicationMethodologyGUID
						,@pCountryId
						,IPL.ChangeReasonId
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					UPDATE PL
					SET CollaborationMethodology_Id = IPL.CommunicationMethodologyGUID
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					UPDATE PL
					SET State_Id = IPL.PanelStateId
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.PanelStateId IS NOT NULL
						AND CMP.State_Id <> @GroupMembershipDeceasedId
						AND CMP.State_Id <> @GroupMembershipNonResidentId
						AND PL.State_Id <> IPL.PanelStateId

					UPDATE PL
					SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.PanelStateId IS NOT NULL
						AND CMP.State_Id IN (
							@GroupMembershipDeceasedId
							,@GroupMembershipNonResidentId
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					UPDATE PL
					SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Individual I ON IFD.IndividualGuid = I.GUIDReference
					INNER JOIN Panelist PL ON PL.PanelMember_Id = I.GUIDReference
					INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
					INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
					WHERE P.[Type] = 'Individual'
						AND CMP.State_Id IN (
							@GroupMembershipDeceasedId
							,@GroupMembershipNonResidentId
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = I.GUIDReference
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = I.GUIDReference
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					UPDATE PL
					SET IncentiveLevel_Id = IL.GUIDReference
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IL.GUIDReference IS NOT NULL

					UPDATE PL
					SET ChangeReason_Id = IPL.ChangeReasonId
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.ChangeReasonId IS NOT NULL

					INSERT INTO Panelist (
						GUIDReference
						,CreationDate
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Panel_Id
						,RewardsAccount_Id
						,PanelMember_Id
						,CollaborationMethodology_Id
						,State_Id
						,IncentiveLevel_Id
						,ExpectedKit_Id
						,ChangeReason_Id
						,Country_Id
						)
					SELECT PanelistGUID
						,@GetDate
						,@pUser
						,@GetDate
						,@GetDate
						,PanelGUID
						,NULL
						,IndividualGuid
						,CommunicationMethodologyGUID
						,IIF(CMP.CollectiveMembershipId IS NOT NULL, @PanelistDropoutStateId, PanelStateId)
						,IL.GUIDReference
						,p.ExpectedKit_Id
						,ChangeReasonId
						,@pCountryId
					FROM #Insert_Panelist IPL
					JOIN Panel p ON p.GUIDReference = IPL.PanelGUID
					LEFT JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
						AND CMP.State_Id IN (
							@GroupMembershipNonResidentId
							,@GroupMembershipDeceasedId
							)
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,@PanelistPresetedStateId
						,IIF(CMP.CollectiveMembershipId IS NOT NULL, @PanelistDropoutStateId, PanelStateId)
						,NULL
						,@pCountryId
						,PanelistGUID
					FROM #Insert_Panelist IPL
					LEFT JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
						AND CMP.State_Id IN (
							@GroupMembershipNonResidentId
							,@GroupMembershipDeceasedId
							)
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'

					INSERT INTO CollaborationMethodologyHistory (
						GUIDReference
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,[Date]
						,GPSUser
						,Comments
						,Panelist_Id
						,OldCollaborationMethodology_Id
						,NewCollaborationMethodology_Id
						,Country_Id
						,CollaborationMethodologyChangeReason_Id
						)
					SELECT NEWID()
						,@GetDate
						,@GetDate
						,@GetDate
						,@pUser
						,MethodologyChangeComment
						,PanelistGUID
						,NULL
						,CommunicationMethodologyGUID
						,@pCountryId
						,ChangeReasonId
					FROM #Insert_Panelist IPL
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					INSERT INTO CollaborationMethodologyHistory (
						GUIDReference
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,[Date]
						,GPSUser
						,Comments
						,Panelist_Id
						,OldCollaborationMethodology_Id
						,NewCollaborationMethodology_Id
						,Country_Id
						,CollaborationMethodologyChangeReason_Id
						)
					SELECT NEWID()
						,@GetDate
						,@GetDate
						,@GetDate
						,@pUser
						,MethodologyChangeComment
						,PanelistGUID
						,NULL
						,CommunicationMethodologyGUID
						,@pCountryId
						,ChangeReasonId
					FROM #Insert_Panelist IPL
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'Individual'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					/* Automated Individual Alias Per Panel*/
					IF OBJECT_ID('tempdb..#AliasesTemp') IS NOT NULL
						DROP TABLE #AliasesTemp

					SELECT nac.NamedAliasContextId AS AliasContext_Id
						,IndividualGuid AS Candidate_id
						,[Next] + ROW_NUMBER() OVER (
							PARTITION BY nac.Strategy_Id ORDER BY nac.Strategy_Id
							) - 1 AS Number
						,ISNULL(Prefix, '') AS Prefix
						,ISNULL(Postfix, '') AS Postfix
						,[Min]
						,[Max]
						,nas.NamedAliasStrategyId AS NasId
					INTO #AliasesTemp
					FROM NamedAliasContext nac
					JOIN NamedAliasStrategy nas ON nac.Strategy_Id = nas.NamedAliasStrategyId
					JOIN #Insert_Panelist ipl ON ipl.PanelGUID = nac.Panel_Id
					WHERE nas.[Type] = 'Sequential'
						AND nac.AutomaticallyGenerated = 1

					INSERT INTO NamedAlias (
						NamedAliasId
						,[Key]
						,AliasContext_Id
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,[Guid]
						,Incentive_Id
						,Candidate_Id
						,[Type]
						)
					SELECT NEWID() AS NamedAliasId
						,CONCAT (
							Prefix
							,RIGHT(CONCAT (
									REPLICATE('0', IIF(LEN(CONCAT (
													Prefix
													,Number
													,Postfix
													)) < [Min], [Min], 0))
									,Number
									), ISNULL([Max], 99999) - LEN(Prefix + PostFix))
							,Postfix
							) AS [Key]
						,AliasContext_Id
						,@pUser AS GPSUser
						,@GetDate AS GPSUpdateTimestamp
						,@GetDate AS CreationTimeStamp
						,NULL AS [Guid]
						,NULL AS Incentive_Id
						,Candidate_id
						,'CandidateAlias' AS [Type]
					FROM #AliasesTemp

					UPDATE nas
					SET [Next] = NextNumber
					FROM NamedAliasStrategy nas
					JOIN (
						SELECT MAX(Number) + 1 AS NextNumber
							,NasId
						FROM #AliasesTemp
						GROUP BY NasId
						) at ON nas.NamedAliasStrategyId = at.NasId

					--- Panel Roles for updated panel-- 
					UPDATE DRA
					SET DRA.Candidate_Id = IPL.IndividualGuid
						,DRA.GPSUpdateTimestamp = @GetDate
						,DRA.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN DynamicRole DR ON IPL.[PanelRoleCode] = DR.[Code]
						AND DR.Country_Id = @pCountryId
					INNER JOIN DynamicRoleAssignment DRA ON DRA.DynamicRole_Id = DR.DynamicRoleId
						AND DRA.Panelist_Id = IPL.PanelistGUID
						AND DRA.Candidate_Id <> IPL.IndividualGuid
					WHERE DR.Country_Id = @pCountryId

					/*History*/
					/* household panels */
					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,PL.State_Id
						,PanelStateId
						,NULL
						,@pCountryId
						,PanelistGUID
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.PanelStateId IS NOT NULL
						AND 0 = ANY (
							SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
									AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM Collective C
							INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
							WHERE C.GUIDReference = IPL.GroupGUID
							)
						AND PL.State_Id <> PanelStateId

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,PL.State_Id
						,IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,NULL
						,@pCountryId
						,PanelistGUID
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.PanelStateId IS NOT NULL
						AND 1 = ALL (
							SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
									AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM Collective C
							INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
							WHERE C.GUIDReference = IPL.GroupGUID
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					INSERT INTO CollaborationMethodologyHistory (
						GUIDReference
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,[Date]
						,GPSUser
						,Comments
						,Panelist_Id
						,OldCollaborationMethodology_Id
						,NewCollaborationMethodology_Id
						,Country_Id
						,CollaborationMethodologyChangeReason_Id
						)
					SELECT NEWID()
						,@GetDate
						,@GetDate
						,@GetDate
						,@pUser
						,IPL.MethodologyChangeComment
						,PL.GUIDReference
						,PL.CollaborationMethodology_Id
						,IPL.CommunicationMethodologyGUID
						,@pCountryId
						,IPL.ChangeReasonId
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					UPDATE PL
					SET CollaborationMethodology_Id = IPL.CommunicationMethodologyGUID
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					UPDATE PL
					SET State_Id = IPL.PanelStateId
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.PanelStateId IS NOT NULL
						AND 0 = ANY (
							SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
									AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM Collective C
							INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
							WHERE C.GUIDReference = IPL.GroupGUID
							)
						AND PL.State_Id <> IPL.PanelStateId

					UPDATE PL
					SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.PanelStateId IS NOT NULL
						AND 1 = ALL (
							SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
									AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM Collective C
							INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
							WHERE C.GUIDReference = IPL.GroupGUID
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,PL.State_Id
						,IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,NULL
						,@pCountryId
						,PL.GUIDReference
					FROM Panelist PL
					INNER JOIN #ImportFeedData IPL ON PL.PanelMember_Id = IPL.GroupGUID
					INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
						AND P.Country_Id = @pCountryId
					WHERE P.[Type] = 'HouseHold'
						AND NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IPL.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IPL.IndividualGuid
							)
						AND 1 = ALL (
							SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
									AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM Collective C
							INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
							WHERE C.GUIDReference = IPL.GroupGUID
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					UPDATE PL
					SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #ImportFeedData IPL ON PL.PanelMember_Id = IPL.GroupGUID
					INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
						AND P.Country_Id = @pCountryId
					WHERE P.[Type] = 'HouseHold'
						AND NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IPL.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IPL.IndividualGuid
							)
						AND 1 = ALL (
							SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
									AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM Collective C
							INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
							WHERE C.GUIDReference = IPL.GroupGUID
							)
						AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
							AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

					UPDATE PL
					SET IncentiveLevel_Id = IL.GUIDReference
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IL.GUIDReference IS NOT NULL

					UPDATE PL
					SET ChangeReason_Id = IPL.ChangeReasonId
						,PL.GPSUpdateTimestamp = @GetDate
						,PL.GPSUser = @pUser
					FROM Panelist PL
					INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
						AND PL.PanelMember_Id = IPL.GroupGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.ChangeReasonId IS NOT NULL

					INSERT INTO Panelist (
						GUIDReference
						,CreationDate
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Panel_Id
						,RewardsAccount_Id
						,PanelMember_Id
						,CollaborationMethodology_Id
						,State_Id
						,IncentiveLevel_Id
						,ExpectedKit_Id
						,ChangeReason_Id
						,Country_Id
						)
					SELECT PanelistGUID
						,@GetDate
						,@pUser
						,@GetDate
						,@GetDate
						,PanelGUID
						,NULL
						,GroupGUID
						,CommunicationMethodologyGUID
						,PanelStateId
						,IL.GUIDReference
						,p.ExpectedKit_Id
						,ChangeReasonId
						,@pCountryId
					FROM #Insert_Panelist IPL
					JOIN Panel p ON p.GUIDReference = IPL.PanelGUID
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Panelist_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,@PanelistPresetedStateId
						,PanelStateId
						,NULL
						,@pCountryId
						,PanelistGUID
					FROM #Insert_Panelist IPL
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'

					INSERT INTO CollaborationMethodologyHistory (
						GUIDReference
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,[Date]
						,GPSUser
						,Comments
						,Panelist_Id
						,OldCollaborationMethodology_Id
						,NewCollaborationMethodology_Id
						,Country_Id
						,CollaborationMethodologyChangeReason_Id
						)
					SELECT NEWID()
						,@GetDate
						,@GetDate
						,@GetDate
						,@pUser
						,MethodologyChangeComment
						,PanelistGUID
						,NULL
						,CommunicationMethodologyGUID
						,@pCountryId
						,ChangeReasonId
					FROM #Insert_Panelist IPL
					LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
						AND IL.[Description] = 'DEFAULT'
						AND IL.IsDefault = 1
						AND IL.Country_Id = @pCountryId
					WHERE IPL.PanelType = 'HouseHold'
						AND IPL.CommunicationMethodologyGUID IS NOT NULL

					/* Panel Roles */
					UPDATE DRA
					SET DRA.Candidate_Id = IPL.IndividualGuid
						,DRA.GPSUpdateTimestamp = @GetDate
						,DRA.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN DynamicRole DR ON IPL.[PanelRoleCode] = DR.[Code]
						AND DR.Country_Id = @pCountryId
					INNER JOIN DynamicRoleAssignment DRA ON DRA.DynamicRole_Id = DR.DynamicRoleId
						AND DRA.Panelist_Id = IPL.PanelistGUID
						AND DRA.Candidate_Id <> IPL.IndividualGuid
					WHERE DR.Country_Id = @pCountryId

					INSERT INTO DynamicRoleAssignment (
						DynamicRoleAssignmentId
						,DynamicRole_Id
						,Candidate_Id
						,Panelist_Id
						,CreationTimeStamp
						,GPSUpdateTimestamp
						,GPSUser
						,Country_Id
						)
					SELECT NEWID()
						,DR.DynamicRoleId
						,IPL.IndividualGuid
						,IPL.PanelistGUID
						,@GetDate
						,@GetDate
						,@pUser
						,@pCountryId
					FROM #Insert_Panelist IPL
					INNER JOIN DynamicRole DR ON IPL.[PanelRoleCode] = DR.[Code]
						AND DR.Country_Id = @pCountryId
					WHERE DR.Country_Id = @pCountryId

					DECLARE @MainContactGUID UNIQUEIDENTIFIER

					SELECT @MainContactGUID = DR.DynamicRoleId
					FROM DynamicRole DR
					INNER JOIN Translation TR ON DR.Translation_Id = TR.TranslationId
					WHERE TR.KeyName = 'MainContact'
						AND DR.Country_Id = @pCountryId

					INSERT INTO DynamicRoleAssignment (
						DynamicRoleAssignmentId
						,DynamicRole_Id
						,Candidate_Id
						,Panelist_Id
						,CreationTimeStamp
						,GPSUpdateTimestamp
						,GPSUser
						,Country_Id
						)
					SELECT NEWID()
						,DR.DynamicRoleId
						,IPL.IndividualGuid
						,IPL.PanelistGUID
						,@GetDate
						,@GetDate
						,@pUser
						,@pCountryId
					FROM #Update_Panelist IPL
					INNER JOIN DynamicRole DR ON IPL.[PanelRoleCode] = DR.[Code]
						AND DR.Country_Id = @pCountryId
					WHERE DR.Country_Id = @pCountryId

					IF NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist IPL
							INNER JOIN DynamicRole DR ON DR.Country_Id = @pCountryId
							INNER JOIN DynamicRoleConfiguration drc ON drc.DynamicRoleId = DR.DynamicRoleId
							INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = drc.ConfigurationSetId
								AND cs.CountryId = @pCountryId
								AND cs.PanelId = IPL.PanelGUID
								AND cs.[Type] = 'Panel'
							INNER JOIN DynamicRoleAssignment DRA ON DRA.DynamicRole_Id = DR.DynamicRoleId
								AND DRA.Panelist_Id = IPL.PanelistGUID
							WHERE DR.Country_Id = @pCountryId
							)
					BEGIN
						INSERT INTO DynamicRoleAssignment (
							DynamicRoleAssignmentId
							,DynamicRole_Id
							,Candidate_Id
							,Panelist_Id
							,CreationTimeStamp
							,GPSUpdateTimestamp
							,GPSUser
							,Country_Id
							)
						SELECT NEWID()
							,DR.DynamicRoleId
							,IPL.IndividualGuid
							,IPL.PanelistGUID
							,@GetDate
							,@GetDate
							,@pUser
							,@pCountryId
						FROM #Insert_Panelist IPL
						INNER JOIN DynamicRole DR ON DR.Country_Id = @pCountryId
						INNER JOIN DynamicRoleConfiguration drc ON drc.DynamicRoleId = DR.DynamicRoleId
						INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = drc.ConfigurationSetId
							AND cs.CountryId = @pCountryId
							AND cs.PanelId = IPL.PanelGUID
							AND cs.[Type] = 'Panel'
						WHERE DR.Country_Id = @pCountryId
					END

					---------------------------------------------- individual state ----------------------
					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT *
					FROM (
						SELECT NEWID() AS GUIDReference
							,@pUser AS UserId
							,@GetDate AS CreationDate
							,@GetDate AS GPSUpdateTimestamp
							,@GetDate AS CreationTimestamp
							,NULL AS Comments
							,0 AS CollaborateInFuture
							,C.CandidateStatus AS StateFrom
							,fns.[NextStatus] AS StateTo
							,NULL AS ReasonForChange
							,@pCountryId AS CountryId
							,IPL.IndividualGuid AS CandidateId
						FROM #Update_Panelist IPL
						INNER JOIN CollectiveMembership CMP ON IPL.GroupGUID = CMP.Group_Id
						INNER JOIN Candidate C ON CMP.Individual_Id = C.GUIDReference
						CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
						) AS St
					WHERE StateFrom <> StateTo

					UPDATE C
					SET C.CandidateStatus = fns.[NextStatus]
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN CollectiveMembership CMP ON IPL.GroupGUID = CMP.Group_Id
					INNER JOIN Candidate C ON CMP.Individual_Id = C.GUIDReference
					CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
					WHERE C.CandidateStatus <> fns.[NextStatus]

					UPDATE C
					SET C.CandidateStatus = fns.[NextStatus]
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Insert_Panelist IPL
					INNER JOIN Candidate C ON IPL.IndividualGuid = C.GUIDReference
					CROSS APPLY [fnGetIndividualStatusTbl](IPL.IndividualGuid) fns

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,@FromStateIndividualGuid
						,C.CandidateStatus
						,NULL
						,@pCountryId
						,feed.IndividualGuid
					FROM #ImportFeedData feed
					INNER JOIN Candidate C ON feed.IndividualGuid = C.GUIDReference
					WHERE EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = C.GUIDReference
							)
						AND C.CandidateStatus <> @FromStateIndividualGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT *
					FROM (
						SELECT NEWID() AS GUIDReference
							,@pUser AS UserId
							,@GetDate AS CreationDate
							,@GetDate AS GPSUpdateTimestamp
							,@GetDate AS CreationTimestamp
							,NULL AS Comments
							,0 AS CollaborateInFuture
							,C.CandidateStatus AS StateFrom
							,fns.[NextStatus] AS StateTo
							,NULL AS ReasonForChange
							,@pCountryId AS CountryId
							,IFD.IndividualGuid AS CandidateId
						FROM #ImportFeedData IFD
						INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = IFD.GroupGuid
						INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
						CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
						WHERE NOT EXISTS (
								SELECT 1
								FROM #Update_Panelist UPL
								WHERE UPL.IndividualGuid = CMP.Individual_Id
								)
							AND NOT EXISTS (
								SELECT 1
								FROM #Insert_Panelist IPL
								WHERE IPL.IndividualGuid = CMP.Individual_Id
								)
							AND C.CandidateStatus <> fns.[NextStatus]
						) AS St
					WHERE StateFrom <> StateTo

					UPDATE C
					SET C.CandidateStatus = CASE 
							WHEN CMP.State_Id = @GroupMembershipNonResidentId
								THEN @individualStatusGuid
							ELSE fns.[NextStatus]
							END
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = IFD.GroupGuid
					INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
					CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = CMP.Individual_Id
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = CMP.Individual_Id
							)
						AND C.CandidateStatus <> fns.[NextStatus]

					------------------------------------ group state ------------------------
					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupTerminatedStatusGuid
						,NULL
						,@pCountryId
						,IPL.GroupGuid
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE @individualDropOf = ALL (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE @individualDropOf = ALL (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupTerminatedStatusGuid
						,NULL
						,@pCountryId
						,IPL.GroupGuid
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE C.CandidateStatus <> @groupTerminatedStatusGuid
						AND 1 = ALL (
							SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
									AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE C.CandidateStatus <> @groupTerminatedStatusGuid
						AND 1 = ALL (
							SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
									AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupDeceasedStatusGuid
						,NULL
						,@pCountryId
						,IPL.GroupGuid
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE C.CandidateStatus <> @groupDeceasedStatusGuid
						AND 0 = ALL (
							SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					UPDATE C
					SET C.CandidateStatus = @groupDeceasedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE C.CandidateStatus <> @groupDeceasedStatusGuid
						AND 0 = ALL (
							SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupParticipantStatusGuid
						,NULL
						,@pCountryId
						,IPL.GroupGuid
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE @individualParticipent = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupParticipantStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupParticipantStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE @individualParticipent = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupParticipantStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupAssignedStatusGuid
						,NULL
						,@pCountryId
						,IPL.GroupGuid
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE EXISTS (
							SELECT 1
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
								AND I.CandidateStatus NOT IN (
									@individualParticipent
									,@individualStatusGuid
									,@individualDropOf
									)
							)
						AND @individualAssignedGuid = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupAssignedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupAssignedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Update_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE EXISTS (
							SELECT 1
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
								AND I.CandidateStatus NOT IN (
									@individualParticipent
									,@individualStatusGuid
									,@individualDropOf
									)
							)
						AND @individualAssignedGuid = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupAssignedStatusGuid

					-------------------------------------------------------------
					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Insert_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE @individualDropOf = ALL (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Insert_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE C.CandidateStatus <> @groupTerminatedStatusGuid
						AND 1 = ALL (
							SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
									AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					UPDATE C
					SET C.CandidateStatus = @groupDeceasedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Insert_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE C.CandidateStatus <> @groupDeceasedStatusGuid
						AND 0 = ALL (
							SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					UPDATE C
					SET C.CandidateStatus = @groupParticipantStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Insert_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE @individualParticipent = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					UPDATE C
					SET C.CandidateStatus = @groupAssignedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #Insert_Panelist IPL
					INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
					WHERE EXISTS (
							SELECT 1
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
								AND I.CandidateStatus NOT IN (
									@individualParticipent
									,@individualStatusGuid
									,@individualDropOf
									)
							)
						AND @individualAssignedGuid = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,@existingroupStatusGuid
						,C.CandidateStatus
						,NULL
						,@pCountryId
						,feed.GroupGuid
					FROM #ImportFeedData feed
					INNER JOIN Candidate C ON feed.GroupGUID = C.GUIDReference
					WHERE EXISTS (
							SELECT 1
							FROM #Insert_Panelist UPL
							WHERE UPL.IndividualGuid = C.GUIDReference
							)
						AND C.CandidateStatus <> @existingroupStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupTerminatedStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND @individualDropOf = ALL (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND @individualDropOf = ALL (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupTerminatedStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND 1 = ALL (
							SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
									AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND 1 = ALL (
							SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
									AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupDeceasedStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND 0 = ALL (
							SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupDeceasedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupDeceasedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND 0 = ALL (
							SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupDeceasedStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupParticipantStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND @individualParticipent = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupParticipantStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupParticipantStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND @individualParticipent = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupParticipantStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupAssignedStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND EXISTS (
							SELECT 1
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
								AND I.CandidateStatus NOT IN (
									@individualParticipent
									,@individualStatusGuid
									,@individualDropOf
									)
							)
						AND @individualAssignedGuid = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupAssignedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupAssignedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE NOT EXISTS (
							SELECT 1
							FROM #Update_Panelist UPL
							WHERE UPL.IndividualGuid = IFD.IndividualGuid
							)
						AND NOT EXISTS (
							SELECT 1
							FROM #Insert_Panelist IPL
							WHERE IPL.IndividualGuid = IFD.IndividualGuid
							)
						AND EXISTS (
							SELECT 1
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
								AND I.CandidateStatus NOT IN (
									@individualParticipent
									,@individualStatusGuid
									,@individualDropOf
									)
							)
						AND @individualAssignedGuid = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupAssignedStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupTerminatedStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE 1 = ALL (
							SELECT IIF(I.CandidateStatus IN (
										@individualStatusGuid
										,@individualDropOf
										,@individualDeceasedGuid
										), 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(I.CandidateStatus IN (
										@individualDropOf
										,@individualDeceasedGuid
										), 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupTerminatedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE 1 = ALL (
							SELECT IIF(I.CandidateStatus IN (
										@individualStatusGuid
										,@individualDropOf
										,@individualDeceasedGuid
										), 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(I.CandidateStatus IN (
										@individualDropOf
										,@individualDeceasedGuid
										), 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND 1 = ANY (
							SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupTerminatedStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupDeceasedStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE 0 = ALL (
							SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupDeceasedStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupDeceasedStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE 0 = ALL (
							SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupDeceasedStatusGuid

					INSERT INTO StateDefinitionHistory (
						GUIDReference
						,GPSUser
						,CreationDate
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,Comments
						,CollaborateInFuture
						,From_Id
						,To_Id
						,ReasonForchangeState_Id
						,Country_Id
						,Candidate_Id
						)
					SELECT NEWID()
						,@pUser
						,@GetDate
						,@GetDate
						,@GetDate
						,NULL
						,0
						,C.CandidateStatus
						,@groupStatusGuid
						,NULL
						,@pCountryId
						,IFD.GroupGuid
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE 1 = ALL (
							SELECT IIF(I.CandidateStatus = @individualStatusGuid, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupStatusGuid

					UPDATE C
					SET C.CandidateStatus = @groupStatusGuid
						,C.GPSUpdateTimestamp = @GetDate
						,C.GPSUser = @pUser
					FROM #ImportFeedData IFD
					INNER JOIN Candidate C ON IFD.GroupGuid = C.GUIDReference
					WHERE 1 = ALL (
							SELECT IIF(I.CandidateStatus = @individualStatusGuid, 1, 0)
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
						AND C.CandidateStatus <> @groupStatusGuid

					-------------------------------------------------------------
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
						,IPL.IndividualGuid
						,IPL.GroupGUID
						,@GetDate
						,@GetDate
						,@pUser
						,@pCountryId
					FROM #Update_Panelist IPL
					INNER JOIN DynamicRole DR ON IPL.[GroupRoleCode] = DR.[Code]
						AND DR.Country_Id = @pCountryId
					WHERE DR.Country_Id = @pCountryId
						AND NOT EXISTS (
							SELECT 1
							FROM DynamicRoleAssignment DRA
							WHERE DRA.DynamicRole_Id = DR.DynamicRoleId
								AND DRA.Candidate_Id = IPL.IndividualGuid
								AND DRA.Group_Id = IPL.GroupGUID
							)

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
						,IPL.IndividualGuid
						,IPL.GroupGUID
						,@GetDate
						,@GetDate
						,@pUser
						,@pCountryId
					FROM #Insert_Panelist IPL
					INNER JOIN DynamicRole DR ON IPL.[GroupRoleCode] = DR.[Code]
						AND DR.Country_Id = @pCountryId
					WHERE DR.Country_Id = @pCountryId
						AND NOT EXISTS (
							SELECT 1
							FROM DynamicRoleAssignment DRA
							WHERE DRA.DynamicRole_Id = DR.DynamicRoleId
								AND DRA.Candidate_Id = IPL.IndividualGuid
								AND DRA.Group_Id = IPL.GroupGUID
							)

					/* Panel Repetable */
					UPDATE ImportFile
					SET State_Id = (
							SELECT Id
							FROM StateDefinition
							WHERE Code = 'ImportFileSuccess'
								AND Country_Id = @pCountryId
							)
					WHERE GUIDReference = @pFileId

					/* Closed Actions start*/
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
						DECLARE @ActiontaskId UNIQUEIDENTIFIER = newid();
						DECLARE @countryid UNIQUEIDENTIFIER;
						DECLARE @TypeTranslationid UNIQUEIDENTIFIER;
						DECLARE @TranslaionIds UNIQUEIDENTIFIER;
						DECLARE @AssigneeId UNIQUEIDENTIFIER;
						DECLARE @GUIDRefActionTask UNIQUEIDENTIFIER;

						SET @AssigneeId = (
								SELECT Id
								FROM IdentityUser
								WHERE UserName = @pUser
									AND Country_Id = @pCountryId
								)
						SET @TranslaionIds = (
								SELECT TranslationId
								FROM Translation
								WHERE KeyName = 'AddressChanges'
								)
						SET @TypeTranslationid = (
								SELECT TranslationId
								FROM Translation
								WHERE KeyName = 'DealtByCommunicationTeamActionTaskTypeTypeDescriptor'
								)
						SET @GUIDRefActionTask = (
								SELECT GUIDReference
								FROM ActionTaskType axc
								WHERE TagTranslation_Id = @TranslaionIds
									AND axc.Country_Id = @pCountryId
								)

						IF @GUIDRefActionTask IS NULL
						BEGIN
							SET @GUIDRefActionTask = NEWID()

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
								@GUIDRefActionTask
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
							DECLARE @ChangesCount INT = 0
							DECLARE @ChangeDesc NVARCHAR(4000)

							IF (
									EXISTS (
										SELECT *
										FROM @pColumn
										WHERE ColumnName IN (
												'HomeAddressLine1'
												,'HomeAddressLine2'
												,'HomeAddressLine3'
												,'HomeAddressLine4'
												,'HomePostCode'
												)
										)
									)
							BEGIN
								SET @ChangesCount = @ChangesCount + 1
								SET @ChangeDesc = 'Postal Address type has changed'
							END

							IF (
									EXISTS (
										SELECT *
										FROM @pColumn
										WHERE ColumnName IN (
												'HomePhone'
												,'WorkPhone'
												,'Phone'
												)
										)
									)
							BEGIN
								SET @ChangesCount = @ChangesCount + 1
								SET @ChangeDesc = 'Phone Address type has changed'
							END

							IF (
									EXISTS (
										SELECT *
										FROM @pColumn
										WHERE ColumnName IN ('EmailAddress')
										)
									)
							BEGIN
								SET @ChangesCount = @ChangesCount + 1
								SET @ChangeDesc = 'Email Address type has changed'
							END

							IF (@ChangesCount > 1)
								SET @ChangeDesc = 'More than one address type has changed'

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
							SELECT NewID()
								,@getdate
								,@getdate
								,@getdate
								,@ChangeDesc
								,0
								,@pUser
								,@getdate
								,@getdate
								,4
								,NULL
								,@GUIDRefActionTask
								,IndividualGuid
								,@pCountryId
								,NULL
								,@AssigneeId
								,NULL
							FROM #ImportFeedData
						END
					END

					IF OBJECT_ID('tempdb..#Aliasfeed') IS NOT NULL
						DROP TABLE #Aliasfeed

					/*Named Alias*/
					CREATE TABLE #Aliasfeed (
						NamedAliasContextId UNIQUEIDENTIFIER
						,CandidateId UNIQUEIDENTIFIER
						,NamedAliasKey NVARCHAR(500)
						,NamedAliasKeyValue NVARCHAR(500)
						)

					INSERT INTO #Aliasfeed (
						NamedAliasContextId
						,CandidateId
						,NamedAliasKey
						,NamedAliasKeyValue
						)
					SELECT NAC.NamedAliasContextId
						,feed.IndividualGuid
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
						AND NA.Candidate_Id = AF.CandidateId

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
						,AF.CandidateId
						,N'CandidateAlias'
					FROM #Aliasfeed AF
					WHERE NOT EXISTS (
							SELECT 1
							FROM NamedAlias NA
							WHERE NA.AliasContext_Id = AF.NamedAliasContextId
								AND NA.Candidate_Id = AF.CandidateId
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
						,0
						,0
						,'Individual updated successfully'
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
				END

				COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION

				INSERT INTO ImportAudit
				VALUES (
					NEWID()
					,1
					,1
					,CONCAT (
						ERROR_LINE()
						,' --- '
						,ERROR_MESSAGE()
						)
					,@GetDate
					,NULL
					,NULL
					,NULL
					,@pUser
					,@GetDate
					,@pFileId
					)

				UPDATE ImportFile
				SET State_Id = (
						SELECT Id
						FROM StateDefinition
						WHERE Code = 'ImportFileBusinessValidationError'
							AND Country_Id = @pCountryId
						)
				WHERE GUIDReference = @pFileId
			END CATCH
		END
	END

	IF OBJECT_ID('tempdb..#AddressTypes') IS NOT NULL
	BEGIN
		DROP TABLE #AddressTypes
	END

	IF OBJECT_ID('tempdb..#Insert_AddressList') IS NOT NULL
	BEGIN
		DROP TABLE #Insert_AddressList
	END
END

