CREATE PROCEDURE [dbo].[IndividualBulkInsert] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed ImportFeed READONLY
	,@pRepeatableData PanelTableType READONLY
	,@pDemographicData Demographics READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pSystemDate DATETIME
	)
AS
BEGIN --1
	SET NOCOUNT ON;

	DECLARE @pImportFeedInternal ImportFeed
	DECLARE @pRepeatableDataInternal PanelTableType
	DECLARE @pDemographicDataInternal Demographics
	DECLARE @ColumnNumber INT = 0

	INSERT INTO @pImportFeedInternal
	SELECT Rownumber
		,FirstName
		,MiddleName
		,LastName
		,EmailAddress
		,HomeAddressLine1
		,HomeAddressLine2
		,HomeAddressLine3
		,HomeAddressLine4
		,HomePostCode
		,DateOfBirth
		,EnrollmentDate
		,RefererBussinesId
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
		,FullRow
		,GACode
	FROM ImportFeedDummy
	WHERE [fileid] = @pFileId

	INSERT INTO @pRepeatableDataInternal
	SELECT Rownumber
		,PanelCode
		,GroupRoleCode
		,PanelRoleCode
		,PanelistStateCode
		,PanelistCommunicationMethodology
		,PanelistCommunicationMethodologyChangeReason
		,PanelistCommunicationMethodologyChangeComment
		,AddressLine1
		,AddressLine2
		,AddressLine3
		,AddressLine4
		,PostCode
		,AddressType
		,[Order]
		,HomePhone
		,WorkPhone
		,MobilePhone
		,PhoneOrder
		,PhoneType
		,Phone
		,EmailOrder
		,EmailType
		,Email
	FROM PanelTableTypeDummy
	WHERE [fileid] = @pFileId

	INSERT INTO @pDemographicDataInternal
	SELECT Rownumber
		,DemographicName
		,DemographicValue
		,UseShortCode
	FROM DemographicsDummy
	WHERE [fileid] = @pFileId

	DECLARE @GetDate DATETIME

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

	SET @Error = 0

	DECLARE @importDataCount BIGINT

	SET @importDataCount = (
			SELECT COUNT(*)
			FROM @pImportFeedInternal
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
			FROM @pImportFeedInternal
			)

	DECLARE @FirstNameReqired BIT;
	DECLARE @MiddleNameReqired BIT;
	DECLARE @LastNameReqired BIT;
	DECLARE @PostReqired BIT;

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
	SET @PostReqired = (
			SELECT [Required]
			FROM FieldConfiguration FC
			INNER JOIN Country C ON FC.CountryConfiguration_Id = C.Configuration_Id
				AND C.CountryId = @pCountryId
				AND FC.[Key] = 'PostCode'
			)

	DECLARE @ImportFormatId UNIQUEIDENTIFIER

	SELECT @ImportFormatId = ImportFormat_Id
	FROM ImportFile
	WHERE GUIDReference = @pFileId

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

			IF (
					@columnName = 'FirstName'
					AND @FirstNameReqired > 0
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal
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
					FROM @pImportFeedInternal Feed
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
						FROM @pImportFeedInternal
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
					FROM @pImportFeedInternal Feed
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
						FROM @pImportFeedInternal
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.LastName IS NULL
				END
			END
					--PostCode mandatory is added for the purpose of import
			ELSE IF (
					@columnName = 'HomePostCode'
					AND @PostReqired > 0
					)
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal
						WHERE HomePostCode IS NULL
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
						,'HomePostCode Mandatory at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeedInternal Feed
					WHERE HomePostCode IS NULL
				END
			END
			ELSE IF (@columnName = 'HomeAddressLine1')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.[HomeAddressLine1] IS NULL
				END

				/*

				---New Validation Logic Added

				IF NOT EXISTS (

						SELECT 1

						FROM @pImportFeedInternal feed

						INNER JOIN TRANSLATIONTERM TT ON feed.AddressLine1 = TT.Value

							AND TT.CultureCode = @pCultureCode

						INNER JOIN GEOGRAPHICAREA G ON TT.Translation_Id = G.Translation_Id

						)

				BEGIN

					SET @Error = 1



					EXEC InsertImportAudit 'AddressLine1 doesnot exits in the GeographicArea'

						,@pUser

						,@pFileId

				END

						---------------------------Logic End

				*/
				/**/
				/* Inrule validation check start */
				/*** SET DEFAULT GA CODE STARTING FROM THE GROUP ***/
				UPDATE ifeed
				SET [GACode] = ga.Code
				FROM @pImportFeedInternal ifeed
				JOIN Collective cv ON cv.Sequence = CAST(ifeed.[GroupId] AS INT)
				JOIN Candidate c ON c.GuidReference = cv.GuidReference
				JOIN GeographicArea ga ON ga.GuidReference = c.GeographicArea_Id
				WHERE ifeed.GACode IS NULL

				/*** CHECK IF GA EXISTS ***/
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal
						WHERE GACode IS NOT NULL
						)
					AND EXISTS (
						SELECT 1
						FROM @pImportFeedInternal ifeed
						LEFT JOIN GeographicArea ga ON ga.Code = ifeed.GACode
						LEFT JOIN Respondent r ON r.GUIDReference = ga.GUIDReference
						WHERE ga.code IS NULL
						)
				BEGIN
					SET @Error = 1

					SELECT @ColumnNumber = RowNumber
					FROM @pColumn
					WHERE [ColumnName] = 'GACode'

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
						,'GA code ' + Feed.[GACode] + ' doesn''t exist at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeedInternal Feed
					LEFT JOIN GeographicArea ga ON ga.Code = Feed.GACode
					LEFT JOIN Respondent r ON r.GUIDReference = ga.GUIDReference
					WHERE GA.Code IS NULL
				END

				--IF EXISTS (SELECT 1 FROM @pImportFeedInternal WHERE GACode IS NOT NULL)
				--	AND 
				--	 EXISTS (SELECT 1
				--		FROM @pImportFeedInternal ifeed
				--		JOIN GeographicArea ga ON ga.Code=ifeed.GACode
				--		JOIN Respondent r ON r.GUIDReference = ga.GUIDReference
				--		WHERE ifeed.GACode IS NOT NULL)
				--BEGIN
				--	SET @Error = 1
				--	INSERT INTO ImportAudit (
				--		GUIDReference
				--		,Error
				--		,IsInvalid
				--		,[Message]
				--		,[Date]
				--		,SerializedRowData
				--		,SerializedRowErrors
				--		,CreationTimeStamp
				--		,GPSUser
				--		,GPSUpdateTimestamp
				--		,[File_Id]
				--		)
				--	SELECT NEWID()
				--		,1
				--		,0
				--		,'GA code '+ Feed.[GACode] +' already exists'
				--		,@GetDate
				--		,Feed.[FullRow]
				--		,@REPETSEPARATOER
				--		,@GetDate
				--		,@pUser
				--		,@GetDate
				--		,@pFileId
				--	FROM @pImportFeedInternal Feed
				--	WHERE Feed.[GACode] IS NOT NULL
				--END
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.[GACode] IS NULL
				END
			END
			ELSE IF (@columnName = 'RefererBussinesId')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
						LEFT JOIN Individual I ON feed.RefererBussinesId = I.IndividualId
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
						,'Invalid ReferBusinessId at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeedInternal Feed
					WHERE NOT EXISTS (
							SELECT 1
							FROM Individual I
							WHERE I.IndividualId = Feed.RefererBussinesId
							)
				END
			END
			ELSE IF (@columnName = 'GroupMembershipStateCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
						LEFT JOIN StateDefinition SD ON feed.GroupMembershipStateCode = SD.Code
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
					FROM @pImportFeedInternal Feed
					WHERE NOT EXISTS (
							SELECT 1
							FROM StateDefinition SD
							WHERE SD.Code = Feed.GroupMembershipStateCode
							)
				END
			END
			ELSE IF (@columnName = 'NextEvent')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
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
					FROM @pImportFeedInternal Feed
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
						RIGHT JOIN @pImportFeedInternal feed ON TT.Value = feed.FrecuencyValue
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
					FROM @pImportFeedInternal Feed
					WHERE NOT EXISTS (
							SELECT 1
							FROM EventFrequency EF
							INNER JOIN TranslationTerm TT ON EF.Translation_Id = TT.Translation_Id
							WHERE TT.Value = Feed.FrecuencyValue
							)
				END
			END
			ELSE IF (@columnName = 'GroupId')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
						LEFT JOIN (
							SELECT SUBSTRING(IndividualId, 0, CHARINDEX('-', IndividualId)) AS GroupId
							FROM Individual
							WHERE CountryId = @pCountryId
							) I ON feed.GroupId IS NOT NULL
							AND feed.GroupId <> ''
							AND feed.GroupId = I.GroupId
						WHERE feed.GroupId IS NOT NULL
							AND feed.GroupId <> ''
							AND I.GroupId IS NULL
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
					FROM @pImportFeedInternal Feed
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
						FROM @pImportFeedInternal feed
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
					FROM @pImportFeedInternal Feed
					WHERE NOT EXISTS (
							SELECT 1
							FROM CommunicationEventReasonType CE
							WHERE CE.CommEventReasonCode = Feed.CommunicationCommReasonType
							)
				END
			END
			ELSE IF (@columnName = 'Alias')
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
						JOIN NamedAlias na ON na.[Key] = feed.Alias
						JOIN Collective c ON c.GUIDReference = na.Candidate_Id
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
						,'Invalid Alias at Row ' + CONVERT(VARCHAR, Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeedInternal feed
				END
			END
					--ELSE IF (@columnName='IndividualAlias')
					--BEGIN
					--Need to add validation on Alias
					-- 	IF EXISTS(SELECT 1 FROM @pImportFeedInternal feed  LEFT JOIN ContactMechanismType CT
					--            ON feed.CommunicationContactMechanismCode=CT.ContactMechanismCode WHERE CT.ContactMechanismCode IS NULL)
					--BEGIN
					--insert into ImportAudit values(NEWID(),1,1,'Invalid IndividualAlias',@GetDate,null,null,null,@pUser,@GetDate,@pFileId)
					--END
			ELSE IF (@columnName = 'CommunicationContactMechanismCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
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
					FROM @pImportFeedInternal feed
					LEFT JOIN ContactMechanismType CMT ON CMT.ContactMechanismCode = feed.CommunicationContactMechanismCode
						AND CMT.Country_Id = @pCountryId
					WHERE CMT.GUIDReference IS NULL
				END
			END
			ELSE IF (@columnName = 'Incoming')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeedInternal feed
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
					FROM @pImportFeedInternal feed
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
						FROM @pRepeatableDataInternal feed
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableDataInternal Rep
							LEFT JOIN Panel P ON Rep.PanelCode = P.PanelCode
								AND P.Country_Id = @pCountryId
							WHERE P.PanelCode IS NULL
							)
				END
			END
			ELSE IF (@columnName = 'GroupRoleCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pRepeatableDataInternal feed
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableDataInternal Rep
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
						FROM @pRepeatableDataInternal feed
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
					FROM @pImportFeedInternal F
					WHERE F.Rownumber IN (
							SELECT feed.Rownumber
							FROM @pRepeatableDataInternal feed
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
						FROM @pRepeatableDataInternal REP
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableDataInternal REP
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
						FROM @pRepeatableDataInternal REP
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
					FROM @pImportFeedInternal Feed
					WHERE Feed.Rownumber IN (
							SELECT DISTINCT Rep.Rownumber
							FROM @pRepeatableDataInternal REP
							LEFT JOIN CollaborationMethodologyChangeReason CMCR ON dbo.GetTranslationValue(Description_Id, @pCultureCode) = REP.PanelistCommunicationMethodologyChangeReason
								AND CMCR.Country_Id = @pCountryId
							WHERE CMCR.Description_Id IS NULL
							)
				END
			END

			SET @columnsincrement = @columnsincrement + 1
		END --3

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
					FROM @pRepeatableDataInternal REP
					WHERE AddressLine1 IS NULL
						AND (
							AddressType IS NOT NULL
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
					,'AddressLine1 Mandatory at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,IMP.FullRow
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableDataInternal Feed
				INNER JOIN @pImportFeedInternal IMP ON Feed.Rownumber = IMP.Rownumber
				WHERE AddressLine1 IS NULL
			END

			SELECT NEWID()
				,1
				,0
				,'AddressLine1 Mandatory at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,IMP.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pRepeatableDataInternal Feed
			INNER JOIN @pImportFeedInternal IMP ON Feed.Rownumber = IMP.Rownumber
			WHERE AddressLine1 IS NULL
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
					FROM @pRepeatableDataInternal REP
					WHERE PostCode IS NULL
						AND (
							AddressType IS NOT NULL
							OR AddressLine1 IS NOT NULL
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
					,'PostCode Mandatory at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,IMP.FullRow
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableDataInternal Feed
				INNER JOIN @pImportFeedInternal IMP ON Feed.Rownumber = IMP.Rownumber
				WHERE PostCode IS NULL
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
					FROM @pRepeatableDataInternal REP
					WHERE AddressType IS NULL
						AND (
							AddressLine1 IS NOT NULL
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
					,'AddressType is Mandatory at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
					,@GetDate
					,IMP.FullRow
					,@REPETSEPARATOER
					,@GetDate
					,@pUser
					,@GetDate
					,@pFileId
				FROM @pRepeatableDataInternal Feed
				INNER JOIN @pImportFeedInternal IMP ON Feed.Rownumber = IMP.Rownumber
				WHERE AddressType IS NULL
					AND (
						AddressLine1 IS NOT NULL
						OR PostCode IS NOT NULL
						)
			END

			IF EXISTS (
					SELECT 1
					FROM @pRepeatableDataInternal REP
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
				FROM @pRepeatableDataInternal Feed
				INNER JOIN @pImportFeedInternal IMP ON FEED.Rownumber = IMP.Rownumber
				LEFT JOIN #AddressTypes AT ON AT.AddressType = Feed.AddressType
				WHERE Feed.AddressType IS NOT NULL
					AND AT.AddressType IS NULL
			END
		END

		IF OBJECT_ID('tempdb..#ImportFeedData') IS NOT NULL
			DROP TABLE #ImportFeedData

		CREATE TABLE #ImportFeedData (
			Rownumber INT NOT NULL
			,FirstName NVARCHAR(300) Collate Database_Default NULL
			,MiddleName NVARCHAR(300) Collate Database_Default NULL
			,LastName NVARCHAR(300) Collate Database_Default NULL
			,EmailAddress NVARCHAR(200) Collate Database_Default NULL
			--,HomePhone NVARCHAR(200) Collate Database_Default NULL
			--,WorkPhone NVARCHAR(200) Collate Database_Default NULL
			--,MobilePhone NVARCHAR(200) Collate Database_Default NULL
			,HomeAddressLine1 NVARCHAR(200) Collate Database_Default NULL
			,HomeAddressLine2 NVARCHAR(200) Collate Database_Default NULL
			,HomeAddressLine3 NVARCHAR(200) Collate Database_Default NULL
			,HomeAddressLine4 NVARCHAR(200) Collate Database_Default NULL
			,HomePostCode NVARCHAR(100) Collate Database_Default NULL
			,DateOfBirth DATETIME NULL
			,EnrollmentDate DATETIME NULL
			,RefererBussinesId VARCHAR(20) Collate Database_Default NULL
			,Sex INT NULL
			,Title INT NULL
			,GroupMembershipStateCode NVARCHAR(100) Collate Database_Default NULL
			,SupportCharity BIT NULL
			,NonParticipant BIT NULL
			,FrecuencyValue NVARCHAR(1000) Collate Database_Default NULL
			,NextEvent DATETIME NULL
			,AmountValue INT NULL
			,GroupId NVARCHAR(100) Collate Database_Default NULL
			,CommunicationIncoming BIT NULL
			,CommunicationContactMechanismCode BIT NULL
			,CommunicationCommReasonType BIT NULL
			,Alias NVARCHAR(300) Collate Database_Default NULL
			,Comments NVARCHAR(1000) Collate Database_Default NULL
			,CommunicationCreationDateTime DATETIME NULL
			,IndividualAlias VARCHAR(100) Collate Database_Default NULL
			,IndividualId VARCHAR(20) Collate Database_Default NOT NULL
			,PersonalIdentificationId BIGINT NOT NULL
			,IndividualGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
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
			,IndividualRefererGuid UNIQUEIDENTIFIER NULL
			,GroupMembershipStateGuid UNIQUEIDENTIFIER NULL
			,GeographicAreaId UNIQUEIDENTIFIER NULL
			,CMSequence INT NULL
			)

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

		/*

		SET @personalIdentificationId = (

				SELECT MAX(PersonalIdentificationId)

				FROM PersonalIdentification

				)

			*/
		DECLARE @nextSequence BIGINT = 0

		SET @nextSequence = (
				SELECT ISNULL(MAX(Sequence), 0)
				FROM Collective
				WHERE CountryId = @pCountryId
					AND LEN(Sequence) <= @groupBusinessIdCount
				)

		DECLARE @groupStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupAssignedStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupParticipantStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupTerminatedStatusGuid UNIQUEIDENTIFIER

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
		DECLARE @individualAssignedGuid UNIQUEIDENTIFIER
		DECLARE @individualNonParticipent UNIQUEIDENTIFIER
		DECLARE @individualParticipent UNIQUEIDENTIFIER
		DECLARE @individualDropOf UNIQUEIDENTIFIER = NULL

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

		DECLARE @groupIndividualIdStartsWith INT

		SET @groupIndividualIdStartsWith = (
				SELECT CC.IndBusinessIdStartWith
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

		/* missed row id concept */
		DECLARE @missedRowId BIGINT = 0
		DECLARE @I INT = 1
		DECLARE @vCollectiveTableMax BIGINT = 0;

		SELECT @vCollectiveTableMax = (
				SELECT CASE 
						WHEN KV.Value IS NULL
							THEN KS.DefaultValue
						ELSE KV.Value
						END AS Value
				FROM KeyAppSetting KS
				LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id = KS.GUIDReference
					AND KV.Country_Id = @pCountryId
				WHERE KS.KeyName = 'MinIndividualID'
				)

		SET @vCollectiveTableMax = ISNULL(@vCollectiveTableMax, 0);

		SELECT @missedRowId = ISNULL(MAX(X.Sequence), 0)
		FROM (
			SELECT Sequence
				,DENSE_RANK() OVER (
					PARTITION BY CountryId ORDER BY Sequence ASC
					) + @vCollectiveTableMax [ROW]
			FROM Collective
			WHERE COuntryId = @pCountryId
				AND Sequence > @vCollectiveTableMax
			) X
		WHERE X.Sequence = X.[ROW]

		IF OBJECT_ID('tempdb..#GenerateMissingNumbers') IS NULL
		BEGIN
			CREATE TABLE #GenerateMissingNumbers (
				Id INT IDENTITY(1, 1)
				,Value INT
				)
		END

		IF (@missedRowId <= @vCollectiveTableMax)
			SET @missedRowId = @vCollectiveTableMax

		WHILE @I <= @maxInsertCount
		BEGIN
			SET @missedRowId = @missedRowId + 1

			IF NOT EXISTS (
					SELECT 1
					FROM Collective C
					WHERE CountryId = @pCountryId
						AND Sequence = @missedRowId
					)
				AND (@missedRowId > @vCollectiveTableMax)
			BEGIN
				INSERT INTO #GenerateMissingNumbers (Value)
				VALUES (@missedRowId)

				SET @I = @I + 1
			END
		END

		DECLARE @vMaxSeq BIGINT

		SET @vMaxSeq = (
				SELECT MAX(Value)
				FROM #GenerateMissingNumbers
				)

		INSERT INTO CollectiveSequenceMaxValues
		SELECT NEWID()
			,0
			,c.CountryId
			,0
		FROM Country c
		LEFT JOIN CollectiveSequenceMaxValues sq ON c.CountryId = sq.Country_id
		WHERE sq.GUIDReference IS NULL
			AND c.CountryId = @pCountryId

		UPDATE sq
		SET MaxMissingSequenceIdValue = (
				CASE 
					WHEN @vCollectiveTableMax > @vMaxSeq
						THEN @vCollectiveTableMax
					ELSE @vMaxSeq
					END
				)
		FROM CollectiveSequenceMaxValues sq
		WHERE Country_id = @pCountryId

		/* missed row id concept */
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
			,RefererBussinesId
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
			,IndividualRefererGuid
			,GroupMembershipStateGuid
			,GeographicAreaId
			,GroupGuid
			,CMSequence
			)
		SELECT Rownumber
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
			,RefererBussinesId
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
			,IndividualRefererGuid
			,GroupMembershipStateGuid
			,GeographicAreaId
			,GroupGuid
			,CMSequence
		FROM (
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
				,ISNULL(FEED.EnrollmentDate, @pSystemDate) AS EnrollmentDate
				,FEED.RefererBussinesId AS RefererBussinesId
				,FEED.Sex
				,FEED.Title
				,FEED.GroupMembershipStateCode
				,FEED.SupportCharity
				,ISNULL(NonParticipant, 0) NonParticipant
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
				,RIGHT('0000000000' + CAST(ISNULL(C.Sequence, GN.Value) AS VARCHAR), IIF(LEN(ISNULL(C.Sequence, GN.Value)) > @groupBusinessIdCount, LEN(ISNULL(C.Sequence, GN.Value)), @groupBusinessIdCount)) + '-' + (
					CASE 
						WHEN C.GUIDReference IS NULL
							THEN RIGHT('0000000000' + CAST(@groupIndividualIdStartsWith AS VARCHAR), IIF(LEN(@groupIndividualIdStartsWith) > @groupBusinessIdCount, LEN(@groupIndividualIdStartsWith), @groupIndividualIdSeqCount))
						ELSE (
								SELECT RIGHT('0000000000' + CAST((ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + 1) AS VARCHAR(50)), IIF(LEN(ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + 1) > @groupIndividualIdSeqCount, LEN(ISNULL(MAX(Sequence), 0) + 1), @groupIndividualIdSeqCount))
								FROM CollectiveMembership
								JOIN Individual I ON Individual_Id = I.GUIDReference
								WHERE Group_Id = C.GUIDReference
								)
						END
					) AS IndividualId
				,FEED.Rownumber AS PersonalIdentificationId
				,RIGHT(CAST(GN.Value AS VARCHAR), IIF(LEN(GN.Value) > @groupBusinessIdCount, LEN(GN.Value), @groupBusinessIdCount)) AS NextCollectiveSequence
				,ISNULL(IT.GUIDReference, @nullTitleId) AS TitleGuid
				,ISNULL(S.GUIDReference, @nullsexId) AS SexGuid
				,I.GUIDReference AS IndividualRefererGuid
				,ISNULL(SD.Id, @defaultGroupMembershipStatusId) AS GroupMembershipStateGuid
				,G.GUIDReference AS GeographicAreaId
				,ISNULL(C.GUIDReference, NEWID()) AS GroupGuid
				,(
					CASE 
						WHEN C.GUIDReference IS NULL
							THEN @groupIndividualIdStartsWith
						ELSE (
								SELECT ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + 1
								FROM CollectiveMembership
								JOIN Individual I ON Individual_Id = I.GUIDReference
								WHERE Group_Id = C.GUIDReference
								)
						END
					) AS CMSequence
			FROM @pImportFeedInternal FEED
			INNER JOIN #GenerateMissingNumbers GN ON FEED.Rownumber = GN.Id
			LEFT JOIN IndividualTitle IT ON FEED.Title = IT.Code
				AND IT.Country_Id = @pCountryId
			LEFT JOIN IndividualSex S ON FEED.Sex = S.Code
				AND S.Country_Id = @pCountryId
			LEFT JOIN Individual I ON FEED.RefererBussinesId = I.IndividualId
				AND I.CountryId = @pCountryId
			LEFT JOIN StateDefinition SD ON FEED.GroupMembershipStateCode = SD.Code
				AND SD.Country_Id = @pCountryId
			LEFT JOIN GEOGRAPHICAREA G ON G.Code = Feed.GACode
				AND EXISTS (
					SELECT GUIDReference
					FROM dbo.Respondent R
					WHERE R.GUIDReference = G.GUIDReference
						AND R.CountryID = @pCountryId
					)
			LEFT JOIN Collective C ON FEED.GroupId IS NULL
				AND C.Sequence = CAST(FEED.GroupId AS INT)
				AND C.CountryId = @pCountryId
			WHERE FEED.GroupId IS NULL
				AND feed.Alias IS NULL
			
			UNION ALL
			
			SELECT Rownumber
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
				,RefererBussinesId
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
				,RIGHT('0000000000' + CAST(ISNULL(Sequence, 0) AS VARCHAR), IIF(LEN(ISNULL(Sequence, 0)) > @groupBusinessIdCount, LEN(ISNULL(Sequence, 0)), @groupBusinessIdCount)) + '-' + (
					(
						SELECT RIGHT('0000000000' + CAST((ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + SeqId) AS VARCHAR(50)), IIF(LEN(ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + SeqId) > @groupIndividualIdSeqCount, LEN(ISNULL(MAX(Sequence), 0) + SeqId), @groupIndividualIdSeqCount))
						FROM CollectiveMembership
						JOIN Individual I ON Individual_Id = I.GUIDReference
						WHERE Group_Id = GroupGuid
						)
					) AS IndividualId
				,PersonalIdentificationId
				,NextCollectiveSequence
				,TitleGuid
				,SexGuid
				,IndividualRefererGuid
				,GroupMembershipStateGuid
				,GeographicAreaId
				,GroupGuid
				,(
					SELECT (ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + T.SeqId)
					FROM CollectiveMembership
					JOIN Individual I ON Individual_Id = I.GUIDReference
					WHERE Group_Id = GroupGuid
					) AS CMSequence
			FROM (
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
					,ISNULL(FEED.EnrollmentDate, @pSystemDate) AS EnrollmentDate
					,FEED.RefererBussinesId AS RefererBussinesId
					,FEED.Sex
					,FEED.Title
					,FEED.GroupMembershipStateCode
					,FEED.SupportCharity
					,ISNULL(NonParticipant, 0) NonParticipant
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
					,FEED.Rownumber AS PersonalIdentificationId
					,RIGHT(CAST(GN.Value AS VARCHAR), IIF(LEN(GN.Value) > @groupBusinessIdCount, LEN(GN.Value), @groupBusinessIdCount)) AS NextCollectiveSequence
					,ISNULL(IT.GUIDReference, @nullTitleId) AS TitleGuid
					,ISNULL(S.GUIDReference, @nullsexId) AS SexGuid
					,I.GUIDReference AS IndividualRefererGuid
					,ISNULL(SD.Id, @defaultGroupMembershipStatusId) AS GroupMembershipStateGuid
					--	,GACode
					,G.GUIDReference AS GeographicAreaId
					,ISNULL(C.GUIDReference, NEWID()) AS GroupGuid
					,ROW_NUMBER() OVER (
						PARTITION BY C.Sequence ORDER BY C.Sequence
						) AS SeqId
					,C.Sequence
				FROM @pImportFeedInternal FEED
				INNER JOIN #GenerateMissingNumbers GN ON FEED.Rownumber = GN.Id
				LEFT JOIN IndividualTitle IT ON FEED.Title = IT.Code
					AND IT.Country_Id = @pCountryId
				LEFT JOIN IndividualSex S ON FEED.Sex = S.Code
					AND S.Country_Id = @pCountryId
				LEFT JOIN Individual I ON FEED.RefererBussinesId = I.IndividualId
					AND I.CountryId = @pCountryId
				LEFT JOIN StateDefinition SD ON FEED.GroupMembershipStateCode = SD.Code
					AND SD.Country_Id = @pCountryId
				LEFT JOIN GEOGRAPHICAREA G ON G.Code = Feed.GACode
					AND EXISTS (
						SELECT GUIDReference
						FROM dbo.Respondent R
						WHERE R.GUIDReference = G.GUIDReference
							AND R.CountryID = @pCountryId
						)
				INNER JOIN Collective C ON FEED.GroupId IS NOT NULL
					AND C.Sequence = CAST(FEED.GroupId AS INT)
					AND C.CountryId = @pCountryId
				) T
			
			UNION ALL
			
			SELECT Rownumber
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
				,RefererBussinesId
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
				,RIGHT('0000000000' + CAST(ISNULL(Sequence, 0) AS VARCHAR), IIF(LEN(ISNULL(Sequence, 0)) > @groupBusinessIdCount, LEN(ISNULL(Sequence, 0)), @groupBusinessIdCount)) + '-' + (
					(
						SELECT RIGHT('0000000000' + CAST((ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + SeqId) AS VARCHAR(50)), IIF(LEN(ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + SeqId) > @groupIndividualIdSeqCount, LEN(ISNULL(MAX(Sequence), 0) + SeqId), @groupIndividualIdSeqCount))
						FROM CollectiveMembership
						JOIN Individual I ON Individual_Id = I.GUIDReference
						WHERE Group_Id = GroupGuid
						)
					) AS IndividualId
				,PersonalIdentificationId
				,NextCollectiveSequence
				,TitleGuid
				,SexGuid
				,IndividualRefererGuid
				,GroupMembershipStateGuid
				,GeographicAreaId
				,GroupGuid
				,(
					SELECT (ISNULL(MAX(SUBSTRING(I.IndividualId, CHARINDEX('-', I.IndividualId) + 1, 3)), 0) + T2.SeqId)
					FROM CollectiveMembership
					JOIN Individual I ON Individual_Id = I.GUIDReference
					WHERE Group_Id = GroupGuid
					) AS CMSequence
			FROM (
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
					,ISNULL(FEED.EnrollmentDate, @pSystemDate) AS EnrollmentDate
					,FEED.RefererBussinesId AS RefererBussinesId
					,FEED.Sex
					,FEED.Title
					,FEED.GroupMembershipStateCode
					,FEED.SupportCharity
					,ISNULL(NonParticipant, 0) NonParticipant
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
					,FEED.Rownumber AS PersonalIdentificationId
					,RIGHT(CAST(GN.Value AS VARCHAR), IIF(LEN(GN.Value) > @groupBusinessIdCount, LEN(GN.Value), @groupBusinessIdCount)) AS NextCollectiveSequence
					,ISNULL(IT.GUIDReference, @nullTitleId) AS TitleGuid
					,ISNULL(S.GUIDReference, @nullsexId) AS SexGuid
					,I.GUIDReference AS IndividualRefererGuid
					,ISNULL(SD.Id, @defaultGroupMembershipStatusId) AS GroupMembershipStateGuid
					--	,GACode
					,G.GUIDReference AS GeographicAreaId
					,ISNULL(C.GUIDReference, NEWID()) AS GroupGuid
					,ROW_NUMBER() OVER (
						PARTITION BY C.Sequence ORDER BY C.Sequence
						) AS SeqId
					,C.Sequence
				FROM @pImportFeedInternal FEED
				INNER JOIN #GenerateMissingNumbers GN ON FEED.Rownumber = GN.Id
				LEFT JOIN IndividualTitle IT ON FEED.Title = IT.Code
					AND IT.Country_Id = @pCountryId
				LEFT JOIN IndividualSex S ON FEED.Sex = S.Code
					AND S.Country_Id = @pCountryId
				LEFT JOIN Individual I ON FEED.RefererBussinesId = I.IndividualId
					AND I.CountryId = @pCountryId
				LEFT JOIN StateDefinition SD ON FEED.GroupMembershipStateCode = SD.Code
					AND SD.Country_Id = @pCountryId
				LEFT JOIN GEOGRAPHICAREA G ON G.Code = Feed.GACode
					AND EXISTS (
						SELECT GUIDReference
						FROM dbo.Respondent R
						WHERE R.GUIDReference = G.GUIDReference
							AND R.CountryID = @pCountryId
						)
				INNER JOIN NamedAlias na ON feed.Alias IS NOT NULL
					AND na.[Key] = FEED.Alias
				INNER JOIN Collective C ON na.Candidate_Id = c.GUIDReference
					AND C.CountryId = @pCountryId
				) T2
			) AS TBL
		ORDER BY TBL.Rownumber

		-- Update group main contact address to #ImportFeedData table
		UPDATE FEED
		SET FEED.PostalAddressGuid = I.MainPostalAddress_Id
		FROM #ImportFeedData FEED
		JOIN Collective C ON FEED.GroupId = C.Sequence
			AND C.CountryId = @pCountryId
		JOIN Individual I ON C.GroupContact_Id = I.GUIDReference
		WHERE FEED.GroupId IS NOT NULL

		IF EXISTS (
				SELECT IndividualId
				FROM #ImportFeedData feed
				WHERE LEFT(RIGHT(individualid, @groupIndividualIdSeqCount + 1), 1) <> '-'
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
				,'Group Individual number exceeds the max Individual number for that Household: ' + IndividualId + ' at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,IMP.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeedInternal IMP
			JOIN #ImportFeedData Feed ON Feed.Rownumber = IMP.Rownumber
			WHERE LEFT(RIGHT(individualid, @groupIndividualIdSeqCount + 1), 1) <> '-'

			RETURN;
		END

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
			,CP.RowNumber AS [ColumnNumber]
		FROM #ImportFeedData feed
		INNER JOIN @pDemographicDataInternal demo ON feed.Rownumber = demo.Rownumber
		INNER JOIN Attribute A ON A.[Key] = demo.DemographicName
			AND Country_Id = @pCountryId
		JOIN @pColumn CP ON A.[KEY] = CP.COLUMNNAME
			AND Country_Id = @pCountryId
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
				,T.Names + ' demographics are exceeds max length at Row ' + CONVERT(VARCHAR, T.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
								--Commented for PBI39098
								--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
								--AND CONVERT(DATETIME, DemographicValue, 103) <= CONVERT(DATETIME, @GetDate, 103)
								AND (
									DateFrom IS NULL
									OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
									)
								AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
								THEN 1
							WHEN Today = 0
								--Commented for PBI39098
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
							--Commented for PBI39098
							--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
							--AND CONVERT(DATETIME, DemographicValue, 103) <= CONVERT(DATETIME, @GetDate, 103)
							AND (
								DateFrom IS NULL
								OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
								)
							AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
							THEN 1
						WHEN Today = 0
							--Commented for PBI39098
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
							--Commented for PBI39098
							--AND CONVERT(DATETIME, DemographicValue, 103) >= DateFrom
							--AND CONVERT(DATETIME, DemographicValue, 103) <= CONVERT(DATETIME, @GetDate, 103)
							AND (
								DateFrom IS NULL
								OR CONVERT(DATETIME, DemographicValue, 101) >= DateFrom
								)
							AND CONVERT(DATETIME, DemographicValue, 101) <= CONVERT(DATETIME, @GetDate, 101)
							THEN 1
						WHEN Today = 0
							--Commented for PBI39098
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
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
			FROM @pImportFeedInternal Feed
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
				,T.Names + ' demographics are not valid at Row ' + CONVERT(VARCHAR, t.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNumber)
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeedInternal Feed
			INNER JOIN @BooleanTable T ON Feed.[Rownumber] = T.[Rownumber]
			JOIN #Demographics D ON Feed.[Rownumber] = D.[Rownumber]
				AND T.Names = D.DemographicName
		END

		DECLARE @PanelistDefaultStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistPresetedStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistLiveStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistDropoutStateId AS UNIQUEIDENTIFIER
		DECLARE @PanelistRefusalStateId AS UNIQUEIDENTIFIER

		SELECT @PanelistLiveStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistLiveState'
			AND Country_Id = @pCountryId

		SELECT @PanelistDropoutStateId = Id
		FROM StateDefinition
		WHERE Code = 'PanelistDroppedOffState'
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
			,(
				ROW_NUMBER() OVER (
					PARTITION BY FEED.IndividualGuid ORDER BY FEED.IndividualGuid
					) + 1
				) AS [Order1]
			,FEED.IndividualGuid
			,REP.AddressLine1
			,REP.AddressLine2
			,REP.AddressLine3
			,REP.AddressLine4
			,REP.PostCode
			,REP.AddressType
			,AP.ID
		FROM @pRepeatableDataInternal REP
		INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
		INNER JOIN #AddressTypes AP ON REP.AddressType = AP.AddressType

		IF OBJECT_ID('tempdb..#Insert_Panelist') IS NOT NULL
			DROP TABLE #Insert_Panelist

		CREATE TABLE #Insert_Panelist (
			PanelistGUID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
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
			,ExpectedKitId UNIQUEIDENTIFIER NULL
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
			,ExpectedKitId
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
			,P.ExpectedKit_Id
		FROM @pRepeatableDataInternal REP
		INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
		LEFT JOIN Panel P ON P.PanelCode = REP.PanelCode
			AND P.Country_Id = @pCountryId
		LEFT JOIN StateDefinition SD ON SD.Code = REP.PanelistStateCode
			AND SD.Country_Id = @pCountryId
		LEFT JOIN CollaborationMethodology CM ON CM.Code = REP.PanelistCommunicationMethodology
			AND CM.Country_Id = @pCountryId
		LEFT JOIN CollaborationMethodologyChangeReason CMCR ON dbo.GetTranslationValue(Description_Id, @pCultureCode) = REP.PanelistCommunicationMethodologyChangeReason
			AND CMCR.Country_Id = @pCountryId

		IF (@Error > 0)
		BEGIN
			EXEC InsertImportFile 'ImportFileBusinessValidationError'
				,@pUser
				,@pFileId
				,@pCountryId

			RETURN;
		END
		ELSE
			DECLARE @personalIdentificationId BIGINT

		SET @personalIdentificationId = (
				SELECT Ident_Current('PersonalIdentification')
				)
		SET IDENTITY_INSERT PersonalIdentification ON

		BEGIN TRANSACTION

		BEGIN TRY
			--Start Insert
			INSERT INTO PersonalIdentification (
				PersonalIdentificationId
				,DateOfBirth
				,LastOrderedName
				,MiddleOrderedName
				,FirstOrderedName
				,TitleId
				,Country_Id
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				)
			SELECT (@personalIdentificationId + feed.PersonalIdentificationId)
				,feed.DateOfBirth
				,feed.LastName
				,feed.MiddleName
				,feed.FirstName
				,feed.TitleGuid
				,@pCountryId
				,@pUser
				,@GetDate
				,@GetDate
			FROM #ImportFeedData feed

			INSERT INTO Candidate (
				GUIDReference
				,ValidFromDate
				,EnrollmentDate
				,Comments
				,CandidateStatus
				,GeographicArea_Id
				,RewardsAccountGUID_Id
				,PreallocatedBatch_Id
				,GPSUser
				,CreationTimeStamp
				,GPSUpdateTimestamp
				,Country_Id
				)
			SELECT feed.GroupGuid
				,@GetDate
				,feed.EnrollmentDate
				,NULL
				,@groupStatusGuid
				,feed.GeographicAreaId
				,NULL
				,NULL
				,@pUser
				,@GetDate
				,@GetDate
				,@pCountryId
			FROM #ImportFeedData feed
			WHERE NOT EXISTS (
					SELECT 1
					FROM Candidate C
					WHERE C.GUIDReference = feed.GroupGuid
					)

			INSERT INTO Candidate (
				GUIDReference
				,ValidFromDate
				,EnrollmentDate
				,Comments
				,CandidateStatus
				,GeographicArea_Id
				,RewardsAccountGUID_Id
				,PreallocatedBatch_Id
				,GPSUser
				,CreationTimeStamp
				,GPSUpdateTimestamp
				,Country_Id
				)
			SELECT feed.IndividualGuid
				,@GetDate
				,feed.EnrollmentDate
				,NULL
				,@individualStatusGuid
				,feed.GeographicAreaId
				,NULL
				,NULL
				,@pUser
				,@GetDate
				,@GetDate
				,@pCountryId
			FROM #ImportFeedData feed

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE ColumnName IN ('GroupId')
					)
			BEGIN
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
					,oc.Address_Id
					,@pCountryId
				FROM #ImportFeedData feed
				JOIN Collective cl ON cl.sequence = feed.GroupId
					AND cl.CountryId = @pCountryId
				JOIN OrderedContactMechanism oc ON cl.guidreference = oc.Candidate_Id
				JOIN [Address] a ON a.GUIDReference = oc.Address_Id
				WHERE oc.[Order] = 1
					AND a.AddressType = 'PostalAddress'
			END
			ELSE
			BEGIN
				INSERT INTO Address (
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
				WHERE FEED.GroupId IS NULL

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
					,feed.PostalAddressGuid
					,@pCountryId
				FROM #ImportFeedData feed

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
					,feed.GroupGuid
					,feed.PostalAddressGuid
					,@pCountryId
				FROM #ImportFeedData feed
			END

			/********************MULTIPLE ADDRESS HANDLE******************/
			INSERT INTO Address (
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
				,[Order]
				,@puser
				,@GetDate
				,@GetDate
				,FeedAdd.IndividualGuid
				,FeedAdd.AddressListGUID
				,@pCountryId
			FROM #Insert_AddressList FeedAdd

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
				,[Order]
				,@puser
				,@GetDate
				,@GetDate
				,FeedAdd.GroupGUID
				,FeedAdd.AddressListGUID
				,@pCountryId
			FROM #Insert_AddressList FeedAdd

			/**************************************/
			INSERT INTO Address (
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
			WHERE FEED.EmailAddress IS NOT NULL
				AND LEN(LTRIM(RTRIM(Feed.EmailAddress))) > 0

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
			FROM #ImportFeedData feed
			WHERE FEED.EmailAddress IS NOT NULL
				AND LEN(LTRIM(RTRIM(Feed.EmailAddress))) > 0

			/******************************/
			IF OBJECT_ID('tempdb..#TempPhones') IS NOT NULL
				DROP TABLE #TempPhones

			SELECT ROW_NUMBER() OVER (
					PARTITION BY Phones.Rownumber ORDER BY Phones.Rownumber ASC
						,CHARINDEX('|' + Phones.Phone + '|', feed.FullRow + '|') ASC
					) AS InternalRow
				,Phones.*
			INTO #TempPhones
			FROM (
				SELECT [Rownumber]
					,[HomePhone] AS Phone
					,@homeAddressTypeGuid AS PhoneType
					,NEWID() AS AddressId
					,NEWID() AS OrderedID
				FROM @pRepeatableDataInternal
				WHERE [HomePhone] IS NOT NULL
					AND [HomePhone] <> ''
				
				UNION
				
				SELECT [Rownumber]
					,[WorkPhone] AS Phone
					,@workAddressTypeGuid AS PhoneType
					,NEWID() AS AddressId
					,NEWID() AS OrderedID
				FROM @pRepeatableDataInternal
				WHERE [WorkPhone] IS NOT NULL
					AND [WorkPhone] <> ''
				
				UNION
				
				SELECT [Rownumber]
					,[MobilePhone] AS Phone
					,@mobileAddressTypeGuid AS PhoneType
					,NEWID() AS AddressId
					,NEWID() AS OrderedID
				FROM @pRepeatableDataInternal
				WHERE [MobilePhone] IS NOT NULL
					AND [MobilePhone] <> ''
				) AS Phones
			JOIN @pImportFeedInternal feed ON feed.Rownumber = Phones.Rownumber

			--SELECT * FROM #TempPhones
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
				,PhoneType
				,'PhoneAddress'
				,@pCountryId
			FROM #TempPhones tp
			ORDER BY tp.Rownumber
				,InternalRow

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
				,InternalRow
				,@puser
				,@GetDate
				,@GetDate
				,feed.IndividualGuid
				,
				--feed.GroupGuid,
				tp.AddressId
				,@pCountryId
			FROM #TempPhones tp
			JOIN #ImportFeedData feed ON feed.Rownumber = tp.Rownumber
			ORDER BY tp.Rownumber
				,InternalRow

			/******************************/
			SELECT FEED.IndividualGuid
				,(@personalIdentificationId + feed.PersonalIdentificationId)
				,FEED.SexGuid
				,FEED.IndividualRefererGuid
				,NULL
				,NULL
				,FEED.NonParticipant
				,FEED.IndividualId
				,NULL
				,FEED.PostalAddressGuid
				,CASE 
					WHEN tp.Phone IS NOT NULL
						THEN tp.AddressId
					ELSE NULL
					END
				,CASE 
					WHEN FEED.EmailAddress IS NOT NULL
						AND LEN(LTRIM(RTRIM(Feed.EmailAddress))) > 0
						THEN FEED.ElectronicAddressGuid
					ELSE NULL
					END
				,@pCountryId
				,@pUser
				,@GetDate
				,@GetDate
			FROM #ImportFeedData FEED
			LEFT JOIN #TempPhones tp ON feed.Rownumber = tp.Rownumber
				AND PhoneType = @homeAddressTypeGuid

			INSERT INTO Individual (
				GUIDReference
				,PersonalIdentificationId
				,Sex_Id
				,Referer
				,Event_Id
				,CharitySubscription_Id
				,Participant
				,IndividualId
				,CATI3DCode
				,MainPostalAddress_Id
				,MainPhoneAddress_Id
				,MainEmailAddress_Id
				,CountryId
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				)
			SELECT FEED.IndividualGuid
				,(@personalIdentificationId + feed.PersonalIdentificationId)
				,FEED.SexGuid
				,FEED.IndividualRefererGuid
				,NULL
				,NULL
				,FEED.NonParticipant
				,FEED.IndividualId
				,NULL
				,FEED.PostalAddressGuid
				,CASE 
					WHEN tp.Phone IS NOT NULL
						THEN tp.AddressId
					ELSE NULL
					END
				,CASE 
					WHEN FEED.EmailAddress IS NOT NULL
						AND LEN(LTRIM(RTRIM(Feed.EmailAddress))) > 0
						THEN FEED.ElectronicAddressGuid
					ELSE NULL
					END
				,@pCountryId
				,@pUser
				,@GetDate
				,@GetDate
			FROM #ImportFeedData FEED
			LEFT JOIN #TempPhones tp ON feed.Rownumber = tp.Rownumber
				AND PhoneType = @homeAddressTypeGuid

			/* Automated Individual Alias Per Panel*/
			IF OBJECT_ID('tempdb..#CountryAliasesTemp') IS NOT NULL
				DROP TABLE #CountryAliasesTemp

			SELECT nac.NamedAliasContextId AS AliasContext_Id
				,FEED.IndividualGuid AS Candidate_id
				,[Next] + ROW_NUMBER() OVER (
					PARTITION BY nac.Strategy_Id ORDER BY nac.Strategy_Id
					) - 1 AS Number
				,ISNULL(Prefix, '') AS Prefix
				,ISNULL(Postfix, '') AS Postfix
				,[Min]
				,[Max]
				,nas.NamedAliasStrategyId AS NasId
			INTO #CountryAliasesTemp
			FROM NamedAliasContext nac
			JOIN NamedAliasStrategy nas ON nac.Strategy_Id = nas.NamedAliasStrategyId
			JOIN #ImportFeedData FEED ON 1 = 1
			WHERE nas.[Type] = 'Sequential'
				AND nac.AutomaticallyGenerated = 1
				AND nac.Country_Id = @pCountryId
				AND nac.Discriminator = 'CountryAliasContext'

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
			FROM #CountryAliasesTemp

			UPDATE nas
			SET [Next] = NextNumber
			FROM NamedAliasStrategy nas
			JOIN (
				SELECT MAX(Number) + 1 AS NextNumber
					,NasId
				FROM #CountryAliasesTemp
				GROUP BY NasId
				) at ON nas.NamedAliasStrategyId = at.NasId

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

			INSERT INTO Collective (
				GUIDReference
				,TypeTranslation_Id
				,Sequence
				,DiscriminatorType
				,GroupContact_Id
				,IsDuplicate
				,CountryId
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				)
			SELECT FEED.GroupGuid
				,@collectiveTranslationId
				,FEED.NextCollectiveSequence
				,'HouseHold'
				,FEED.IndividualGuid
				,0
				,@pCountryId
				,@pUser
				,@GetDate
				,@GetDate
			FROM #ImportFeedData FEED
			WHERE NOT EXISTS (
					SELECT 1
					FROM Collective C
					WHERE C.GUIDReference = FEED.GroupGuid
					)

			INSERT INTO CollectiveMembership (
				CollectiveMembershipId
				,Sequence
				,SignUpDate
				,DeletedDate
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,State_Id
				,Group_Id
				,Individual_Id
				,DiscriminatorType
				,Country_Id
				)
			SELECT FEED.CollectiveMembershipId
				,FEED.CMSequence
				,@GetDate
				,NULL
				,@pUser
				,@GetDate
				,@GetDate
				,FEED.GroupMembershipStateGuid
				,FEED.GroupGuid
				,FEED.IndividualGuid
				,'HouseHold'
				,@pCountryId
			FROM #ImportFeedData FEED

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
				,@FromStateGroupMembershipGuid
				,FEED.GroupMembershipStateGuid
				,NULL
				,@pCountryId
				,FEED.CollectiveMembershipId
			FROM #ImportFeedData FEED

			SET IDENTITY_INSERT PersonalIdentification OFF

			/* Panel Repetable */
			/* individual panels */
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
				,PanelStateId
				,IL.GUIDReference
				,IPL.ExpectedKitId
				,ChangeReasonId
				,@pCountryId
			FROM #Insert_Panelist IPL
			LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
				AND IL.[Description] = 'DEFAULT'
				AND IL.IsDefault = 1
				AND IL.Country_Id = @pCountryId
			WHERE IPL.PanelType = 'Individual'

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

			/*History*/
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
				AND CommunicationMethodologyGUID IS NOT NULL

			/* household panels */
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
				,IPL.ExpectedKitId
				,ChangeReasonId
				,@pCountryId
			FROM #Insert_Panelist IPL
			LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
				AND IL.[Description] = 'DEFAULT'
				AND IL.IsDefault = 1
				AND IL.Country_Id = @pCountryId
			LEFT JOIN Panelist P ON P.Country_Id = @pCountryId
				AND P.Panel_Id = PanelGUID
				AND P.PanelMember_Id = GroupGUID
			WHERE IPL.PanelType = 'HouseHold'
				AND P.GUIDReference IS NULL

			INSERT INTO StockKitHistory (
				Id
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,From_Id
				,To_Id
				,Reason_Id
				,Country_Id
				,Panelist_Id
				)
			SELECT NEWID()
				,@pUser
				,@GetDate
				,@GetDate
				,NULL
				,ExpectedKitId
				,NULL
				,@pCountryId
				,PanelistGUID
			FROM #Insert_Panelist
			WHERE ExpectedKitId IS NOT NULL

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
			JOIN Panelist P ON P.GUIDReference = PanelistGUID
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
				AND CommunicationMethodologyGUID IS NOT NULL

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
				AND ISNULL(ipl.[PanelRoleCode], 0) != 0

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

			DECLARE @MainContactGUID UNIQUEIDENTIFIER

			SELECT @MainContactGUID = DR.DynamicRoleId
			FROM DynamicRole DR
			INNER JOIN Translation TR ON DR.Translation_Id = TR.TranslationId
			WHERE TR.KeyName = 'MainContact'
				AND DR.Country_Id = @pCountryId

			UPDATE C
			SET C.CandidateStatus = (
					CASE 
						WHEN (
								@MainContactGUID = DR.DynamicRoleId
								OR G.GUIDReference IS NOT NULL
								)
							AND IPL.PanelStateId = @PanelistLiveStateId
							THEN @individualParticipent
						WHEN (
								IPL.PanelStateId = @PanelistDropoutStateId
								OR IPL.PanelStateId = @PanelistRefusalStateId
								)
							THEN @individualDropOf
						ELSE @individualAssignedGuid
						END
					)
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
			FROM #Insert_Panelist IPL
			INNER JOIN Candidate C ON IPL.IndividualGuid = C.GUIDReference
			LEFT JOIN Collective G ON IPL.GroupGUID = G.GUIDReference
				AND G.GroupContact_Id = IPL.IndividualGuid
			LEFT JOIN DynamicRole DR ON IPL.[PanelRoleCode] = DR.[Code]
				AND DR.Country_Id = @pCountryId
			WHERE C.Country_Id = @pCountryId
				AND EXISTS (
					SELECT 1
					FROM Panelist P
					WHERE P.GUIDReference = IPL.PanelistGUID
					)

			UPDATE C
			SET C.CandidateStatus = (
					CASE 
						WHEN (
								PL.State_Id = @PanelistDropoutStateId
								OR PL.State_Id = @PanelistRefusalStateId
								)
							THEN @individualDropOf
						WHEN IFD.GroupMembershipStateCode = 'GroupMembershipNonResident'
							THEN @individualStatusGuid
						ELSE @individualAssignedGuid
						END
					)
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
			FROM #ImportFeedData IFD
			INNER JOIN Candidate C ON IFD.IndividualGuid = C.GUIDReference
			INNER JOIN Collective G ON IFD.GroupGUID = G.GUIDReference
			INNER JOIN Panelist PL ON (
					PL.PanelMember_Id = IFD.IndividualGuid
					OR PL.PanelMember_Id = IFD.GroupGUID
					)
				AND PL.Country_Id = @pCountryId
			WHERE C.Country_Id = @pCountryId
				AND NOT EXISTS (
					SELECT 1
					FROM #Insert_Panelist IPL
					WHERE IPL.IndividualGuid = IPL.PanelistGUID
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
				,@FromStateIndividualGuid
				,C.CandidateStatus
				,NULL
				,@pCountryId
				,feed.IndividualGuid
			FROM #ImportFeedData feed
			INNER JOIN Candidate C ON feed.IndividualGuid = C.GUIDReference

			UPDATE C
			SET C.CandidateStatus = @groupTerminatedStatusGuid
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
			FROM #Insert_Panelist IPL
			INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
			WHERE @individualDropOf = ALL (
					SELECT I.CandidateStatus
					FROM CollectiveMembership CM
					INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
					WHERE CM.Group_Id = C.GUIDReference
					)

			UPDATE C
			SET C.CandidateStatus = @groupParticipantStatusGuid
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
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
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
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
						AND @individualAssignedGuid = ANY (
							SELECT I.CandidateStatus
							FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
							WHERE CM.Group_Id = C.GUIDReference
							)
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

			INSERT INTO IncentiveAccount (
				IncentiveAccountId
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,Beneficiary_Id
				,[Type]
				,Country_Id
				)
			SELECT Feed.IndividualGuid
				,@pUser
				,@GetDate
				,@GetDate
				,NULL
				,'OwnAccount'
				,@pCountryId
			FROM #ImportFeedData Feed

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'SupportCharity'
					)
			BEGIN
				UPDATE I
				SET I.CharitySubscription_Id = CA.GUIDReference
					,I.GPSUser = @pUser
					,I.GPSUpdateTimestamp = @GetDate
				FROM #ImportFeedData FEED
				INNER JOIN CharityAmount CA ON FEED.AmountValue = CA.Value
					AND CA.Country_Id = @pCountryId
				INNER JOIN Individual I ON FEED.IndividualGuid = I.GUIDReference
				WHERE FEED.SupportCharity = 1
			END

			IF EXISTS (
					SELECT 1
					FROM @pColumn
					WHERE [ColumnName] = 'FrecuencyValue'
					)
			BEGIN
				SELECT NEWID() AS Id
					,FEED.NextEvent AS [Date]
					,IIF(EF.IsNotApplicable = 0
						OR EF.IsDefault = 0, 'NullCalendarEvent', 'CalendarEvent') AS Discriminator
					,EF.GUIDReference AS Frequency_Id
					,FEED.IndividualGuid
				INTO #CalenderEvent
				FROM #ImportFeedData FEED
				JOIN TranslationTerm TT ON TT.Value LIKE FEED.FrecuencyValue
				INNER JOIN EventFrequency EF ON TT.Translation_Id = EF.Translation_Id
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
					,I.GPSUser = @pUser
					,I.GPSUpdateTimestamp = @GetDate
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
					,FEED.CommunicationIncoming AS Incoming
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

			/* Panel Repetable */
			--BEGIN TRY
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
				,d.DemographicId
				,CASE 
					WHEN d.AttributeScope = 'HouseHold'
						THEN cm.Group_Id
					ELSE IndividualId
					END
				,NULL
				,@pUser
				,@GetDate
				,@GetDate
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
						THEN CONVERT(VARCHAR(30), CONVERT(DATETIME, DemographicValue), 20)
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
				,CASE 
					WHEN DemographicType = 'Enum'
						THEN (
								SELECT ed.ID
								FROM dbo.EnumDefinition ED
								WHERE ED.Demographic_Id = d.DemographicId
									AND ED.Value = d.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
								)
					END [EnumDefinition_Id]
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
					END AS [Discriminator]
				,@pCountryId
			FROM #Demographics d
			JOIN CollectiveMembership cm ON cm.Individual_Id = d.IndividualId

			EXEC InsertImportFile 'ImportFileSuccess'
				,@pUser
				,@pFileId
				,@pCountryId

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
				,'Individual created successfully ( ' + ISNULL(IFD.IndividualId, '') + ' )'
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeedInternal Feed
			INNER JOIN #ImportFeedData IFD ON Feed.[Rownumber] = IFD.Rownumber

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION

			SELECT ERROR_MESSAGE()

			INSERT INTO ImportAudit
			VALUES (
				NEWID()
				,1
				,1
				,CASE ERROR_NUMBER()
					WHEN 8152
						THEN 'Address Line should not be more than 100 characters'
					ELSE ERROR_MESSAGE()
					END
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

	IF OBJECT_ID('tempdb..#AddressTypes') IS NOT NULL
	BEGIN
		DROP TABLE #AddressTypes
	END

	IF OBJECT_ID('tempdb..#Insert_AddressList') IS NOT NULL
	BEGIN
		DROP TABLE #Insert_AddressList
	END

	DELETE
	FROM ImportFeedDummy
	WHERE [fileid] = @pFileId

	DELETE
	FROM PanelTableTypeDummy
	WHERE [fileid] = @pFileId

	DELETE
	FROM DemographicsDummy
	WHERE [fileid] = @pFileId
END
