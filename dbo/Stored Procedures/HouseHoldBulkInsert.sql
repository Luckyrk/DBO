CREATE PROCEDURE [dbo].[HouseHoldBulkInsert] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed HouseHoldImportFeed READONLY
	,@pDemographicData Demographics READONLY
	,@AliasImportFeed NamedAliasImportFeed READONLY
	,@RepeatableFeed RepeatableFeed READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	SET NOCOUNT ON

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
			,'file already processed'
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

	/*
	EXEC InsertImportFile 'ImportFileProcessing'
		,@pUser
		,@pFileId
		,@pCountryId
		*/
	DECLARE @Error BIT

	SET @Error = 0

	DECLARE @importDataCount BIGINT

	SET @importDataCount = (
			SELECT COUNT(0)
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

			IF (@columnName = 'GroupContact')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE [GroupContact] IS NULL
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
						,'GroupContact is mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE Feed.[GroupContact] IS NULL
				END

				IF EXISTS (
						SELECT 1
						FROM @pImportFeed Feed
						WHERE NOT EXISTS (
								SELECT 1
								FROM Individual I
								WHERE I.IndividualId = Feed.GroupContact
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
						,'GroupContact is not exists at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
							WHERE I.IndividualId = Feed.GroupContact
							)
				END

				IF EXISTS (
						SELECT Feed.GroupContact
							,Count(1)
						FROM @pImportFeed Feed
						GROUP BY Feed.GroupContact
						HAVING COUNT(1) > 1
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
						,'Duplicate GroupContacts are found at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE ISNULL(Feed.GroupContact, '''') <> ''''
						AND Feed.GroupContact IN (
							SELECT F.GroupContact
							FROM @pImportFeed F
							GROUP BY F.GroupContact
							HAVING COUNT(1) > 1
							)
				END

				IF EXISTS (
						SELECT 1
						FROM DynamicRoleAssignment DRA
						INNER JOIN Individual I ON DRA.Candidate_Id = I.GUIDReference
							AND I.CountryId = @pCountryId
						INNER JOIN @pImportFeed F ON I.IndividualId = F.GroupContact
						INNER JOIN DynamicRoleConfiguration DRC ON DRC.DynamicRoleId = DRA.DynamicRole_Id
						INNER JOIN ConfigurationSet CS ON DRC.ConfigurationSetId = CS.ConfigurationSetId
							AND CS.CountryId = I.CountryId
						WHERE DRA.Panelist_Id IS NULL
							AND CS.[Type] = 'group'
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
						,'GroupContact is should not have dynamic role at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
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
							FROM DynamicRoleAssignment DRA
							INNER JOIN Individual I ON DRA.Candidate_Id = I.GUIDReference
								AND I.CountryId = @pCountryId
								AND I.IndividualId = Feed.GroupContact
							INNER JOIN DynamicRoleConfiguration DRC ON DRC.DynamicRoleId = DRA.DynamicRole_Id
							INNER JOIN ConfigurationSet CS ON DRC.ConfigurationSetId = CS.ConfigurationSetId
								AND CS.CountryId = I.CountryId
							WHERE DRA.Panelist_Id IS NULL
								AND CS.[Type] = 'group'
							)
				END
			END

			IF (@columnName = 'HomeAddressLine1')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE LEN(ISNULL(HomeAddressLine1, '')) = 0
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
						,'Home AddressLine1 is mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE LEN(ISNULL(Feed.HomeAddressLine1, '')) = 0
				END
			END

			--------------------------------------------
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

			--------------------------------------------
			IF (@columnName = 'HomePostCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
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
						,'Home PostCode is mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,Feed.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed Feed
					WHERE LEN(ISNULL(Feed.HomePostCode, '')) = 0
				END
			END

			SET @columnsincrement = @columnsincrement + 1
		END
	END

	IF EXISTS (
			SELECT 1
			FROM @pColumn
			WHERE [ColumnName] = 'AddressLine1'
			)
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM @RepeatableFeed REP
				WHERE AddressLine1 IS NULL
					AND (AddressType IS NOT NULL)
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
				,'AddressLine1 Mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,IMP.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @RepeatableFeed Feed
			INNER JOIN @pImportFeed IMP ON Feed.Rownumber = IMP.Rownumber
			WHERE AddressLine1 IS NULL
		END
	END

	IF EXISTS (
			SELECT 1
			FROM @pColumn
			WHERE [ColumnName] = 'PostCode'
			)
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM @RepeatableFeed REP
				WHERE PostCode IS NULL
					AND (AddressType IS NOT NULL)
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
				,'PostCode Mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
				,@GetDate
				,IMP.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @RepeatableFeed Feed
			INNER JOIN @pImportFeed IMP ON Feed.Rownumber = IMP.Rownumber
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
				,'AddressType is Mandatory at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
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
				,'AddressType is not valid at Row ' + CONVERT(VARCHAR, IMP.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
				,@GetDate
				,IMP.FullRow
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @RepeatableFeed REP
			INNER JOIN @pImportFeed IMP ON REP.Rownumber = IMP.Rownumber
			LEFT JOIN #AddressTypes AT ON AT.AddressType = REP.AddressType
			WHERE REP.AddressType IS NOT NULL
				AND AT.AddressType IS NULL
		END
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

	DECLARE @StateDefnition_GroupMembershipNonResident UNIQUEIDENTIFIER

	SET @StateDefnition_GroupMembershipNonResident = (
			SELECT TOP (1) [sd].[Id] AS [Id]
			FROM [dbo].[StateDefinition] AS [sd]
			WHERE ([sd].[Country_Id] = @pCountryId)
				AND ([sd].[Code] = N'GroupMembershipNonResident')
			)

	DECLARE @MaxSequenceId BIGINT

	SELECT @MaxSequenceId = MAX(T.[Sequence])
	FROM (
		SELECT [Sequence]
		FROM Collective
		WHERE Countryid = @pCountryId
			AND DiscriminatorType IN (
				N'Business'
				,N'HouseHold'
				)
		
		UNION
		
		SELECT [CS].[Sequence] AS [Sequence]
		FROM [dbo].[CollectiveSequenceBatch] AS [CSB]
		INNER JOIN [dbo].[CollectiveSequencing] AS [CS] ON [CSB].[CollectiveSequenceBatchId] = [CS].[GroupSequenceBatch_Id]
		WHERE [CSB].[Country_Id] = @pCountryId
		) T

	DECLARE @postalAddressTypeGuid UNIQUEIDENTIFIER

	SET @postalAddressTypeGuid = (
			SELECT Id
			FROM AddressType
			WHERE DiscriminatorType = 'PostalAddressType'
				AND IsDefault = 1
			)

	DECLARE @groupBusinessIdCount INT

	SET @groupBusinessIdCount = (
			SELECT CC.GroupBusinessIdDigits
			FROM CountryConfiguration CC
			INNER JOIN Country C ON CC.Id = C.Configuration_Id
			WHERE C.CountryId = @pCountryId
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

	IF OBJECT_ID('tempdb..#ImportFeedData') IS NULL
	BEGIN
		CREATE TABLE #ImportFeedData (
			Rownumber INT NOT NULL
			,BusinessId NVARCHAR(300) NULL
			,GroupContact NVARCHAR(300) NULL
			,HeadOfHouseHold NVARCHAR(300) NULL
			,MainShopper NVARCHAR(200) NULL
			,HomeAddressLine1 NVARCHAR(200) NULL
			,HomeAddressLine2 NVARCHAR(200) NULL
			,HomeAddressLine3 NVARCHAR(200) NULL
			,HomeAddressLine4 NVARCHAR(200) NULL
			,HomePostCode NVARCHAR(200) NULL
			,GroupAlias NVARCHAR(200) NULL
			,AliasContextName NVARCHAR(200) NULL
			,IndividualGUID UNIQUEIDENTIFIER
			,CollectiveMembershipId UNIQUEIDENTIFIER
			,CollectiveMembershipStateId UNIQUEIDENTIFIER
			,PropesedSqeuence BIGINT
			,PropesedIndividualId NVARCHAR(200) NULL
			,OldMainPostalAddressId UNIQUEIDENTIFIER NULL
			,GACode NVARCHAR(200) NULL
			,PostalAddressGuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,NewGroupId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,NEWCollectiveMembershipId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
			,InterviewerCode BIGINT
			)
	END

	IF OBJECT_ID('tempdb..#RepeatableData') IS NULL
	BEGIN
		CREATE TABLE #RepeatableData (
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
	END

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

	DECLARE @nextSequence BIGINT = 0

	SET @nextSequence = (
			SELECT ISNULL(MAX(Sequence), 0)
			FROM Collective
			WHERE CountryId = @pCountryId
				AND LEN(Sequence) <= @groupBusinessIdCount
			)

	/*
	WHILE @I <= @maxInsertCount
	BEGIN
		SET @missedRowId = @missedRowId + 1

		IF NOT EXISTS (
				SELECT 1
				FROM Collective C
				WHERE CountryId = @pCountryId
					AND Sequence = @missedRowId
				)
			AND (
				@missedRowId NOT BETWEEN @nextSequence
					AND @vCollectiveTableMax
				)
		BEGIN
			INSERT INTO #GenerateMissingNumbers (Value)
			VALUES (@missedRowId)

			SET @I = @I + 1
		END
	END
	*/
	DECLARE @SeqLimit BIGINT

	SET @SeqLimit = (
			SELECT CASE 
					WHEN @nextSequence > @vCollectiveTableMax
						THEN @nextSequence
					ELSE @vCollectiveTableMax
					END
			)
	SET @SeqLimit = @SeqLimit + @maxInsertCount

	INSERT INTO #GenerateMissingNumbers (Value)
	SELECT TOP (@maxInsertCount) id
	FROM (
		SELECT ROW_NUMBER() OVER (
				ORDER BY s1.[GUIDReference]
				) id
		FROM dbo.AttributeValue AS s1(NOLOCK)
		CROSS JOIN dbo.AttributeValue AS s2(NOLOCK)
		ORDER BY ROW_NUMBER() OVER (
				ORDER BY s1.[GUIDReference]
				) OFFSET @missedRowId ROWS FETCH NEXT @nextSequence ROWS ONLY
		) v
	WHERE NOT EXISTS (
			SELECT 1
			FROM Collective
			WHERE CountryId = @pCountryId
				AND sequence = id
			)
		AND (
			id NOT BETWEEN @nextSequence
				AND @vCollectiveTableMax
			)

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
		,BusinessId
		,GroupContact
		,HeadOfHouseHold
		,MainShopper
		,HomeAddressLine1
		,HomeAddressLine2
		,HomeAddressLine3
		,HomeAddressLine4
		,HomePostCode
		,IndividualGUID
		,CollectiveMembershipId
		,CollectiveMembershipStateId
		,PropesedSqeuence
		,PropesedIndividualId
		,OldMainPostalAddressId
		,GACode
		,InterviewerCode
		)
	SELECT Feed.Rownumber
		,Feed.GroupContact
		,Feed.GroupContact
		,Feed.HeadOfHouseHold
		,Feed.MainShopper
		,Feed.HomeAddressLine1
		,Feed.HomeAddressLine2
		,Feed.HomeAddressLine3
		,Feed.HomeAddressLine4
		,Feed.HomePostCode
		,I.GUIDReference
		,NULL --CM.CollectiveMembershipId
		,NULL --sd.Id
		,GN.Value
		,RIGHT('0000000000' + CAST(GN.Value AS VARCHAR), CASE 
				WHEN LEN(GN.Value) > @groupBusinessIdCount
					THEN LEN(GN.Value)
				ELSE @groupBusinessIdCount
				END) + '-' + RIGHT('0000000000' + CAST(@groupIndividualIdStartsWith AS VARCHAR), @groupIndividualIdSeqCount)
		,I.MainPostalAddress_Id
		,Feed.GACode
		,Feed.InterviewerCode
	FROM @pImportFeed Feed
	INNER JOIN #GenerateMissingNumbers GN ON FEED.Rownumber = GN.Id
	INNER JOIN Individual I ON I.IndividualId = Feed.GroupContact
		AND i.CountryId = @pCountryId

	IF EXISTS (
			SELECT 1
			FROM @pImportFeed Feed
			JOIN #GenerateMissingNumbers GN ON FEED.Rownumber = GN.Id
			LEFT JOIN Individual I ON I.IndividualId = Feed.GroupContact
				AND i.CountryId = @pCountryId
			WHERE i.IndividualId IS NULL
			)
	BEGIN
		SET @Error = 1

		SELECT @ColumnNumber = RowNumber
		FROM @pColumn
		WHERE [ColumnName] = 'GroupContact'

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
			,'invalid business id or business id not found at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,Feed.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed Feed
		JOIN #GenerateMissingNumbers GN ON FEED.Rownumber = GN.Id
		LEFT JOIN Individual I ON I.IndividualId = Feed.GroupContact
			AND i.CountryId = @pCountryId
		WHERE i.IndividualId IS NULL
	END

	INSERT INTO #RepeatableData (
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
	SELECT FEED.NewGroupId
		,(
			ROW_NUMBER() OVER (
				PARTITION BY FEED.IndividualGuid ORDER BY FEED.IndividualGuid
				) + (
				SELECT ISNULL(MAX([ORDER]), 0)
				FROM ORDEREDCONTACTMECHANISM
				WHERE Candidate_Id = feed.IndividualGuid
				)
			) AS [Order1]
		,FEED.IndividualGuid
		,REP.AddressLine1
		,REP.AddressLine2
		,REP.AddressLine3
		,REP.AddressLine4
		,REP.PostCode
		,REP.AddressType
		,AP.ID
	FROM @RepeatableFeed REP
	INNER JOIN #ImportFeedData FEED ON REP.Rownumber = FEED.Rownumber
	INNER JOIN #AddressTypes AP ON REP.AddressType = AP.AddressType

	--INNER JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
	--INNER JOIN StateDefinition sd ON CM.State_Id = sd.Id
	DECLARE @groupStatusGuid UNIQUEIDENTIFIER

	SET @groupStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupCandidate'
				AND Country_Id = @pCountryId
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

	IF OBJECT_ID('tempdb..#Demographics') IS NULL
	BEGIN
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
	END

	IF OBJECT_ID('tempdb..#Aliasfeed') IS NULL
	BEGIN
		CREATE TABLE #Aliasfeed (
			NamedAliasContextId UNIQUEIDENTIFIER
			,GroupId UNIQUEIDENTIFIER
			,NamedAliasKey NVARCHAR(50)
			,NamedAliasKeyValue NVARCHAR(50)
			)
	END

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
		,feed.NewGroupId
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
			,T.Names + ' demographics are exceeds max length at Row ' + CONVERT(VARCHAR, Feed.Rownumber + 1) + ' and column ' + CONVERT(VARCHAR, D.ColumnNmber)
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

	IF (@Error > 0)
	BEGIN
		EXEC InsertImportFile 'ImportFileError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END
	ELSE
	BEGIN
		INSERT INTO #Aliasfeed (
			NamedAliasContextId
			,GroupId
			,NamedAliasKey
			,NamedAliasKeyValue
			)
		SELECT NAC.NamedAliasContextId
			,feed.NewGroupId
			,NAC.NAME
			,aliasfeed.[NamedAliasValue]
		FROM #ImportFeedData feed
		INNER JOIN @AliasImportFeed aliasfeed ON feed.Rownumber = aliasfeed.Rownumber
		INNER JOIN NamedAliasContext NAC ON NAC.NAME = aliasfeed.NamedAliasKey
			AND NAC.Country_Id = @pCountryId

		DECLARE @IsTransactionHasErrors INT = 0

		BEGIN TRANSACTION T

		BEGIN TRY
			UPDATE CM
			SET CM.State_Id = @StateDefnition_GroupMembershipNonResident
				,CM.GPSUser = @pUser
				,CM.GPSUpdateTimestamp = @GetDate
			FROM #ImportFeedData Feed
			INNER JOIN CollectiveMembership CM(NOLOCK) ON CM.Individual_Id = Feed.IndividualGUID
			INNER JOIN StateDefinition sd(NOLOCK) ON CM.State_Id = sd.Id

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

			/**********************satish***********************/
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

			/**********************satish***********************/
			UPDATE I
			SET I.[IndividualId] = Feed.PropesedIndividualId
				,I.[MainPostalAddress_Id] = Feed.PostalAddressGuid
				,I.GPSUser = @pUser
				,I.GPSUpdateTimestamp = @GetDate
			FROM #ImportFeedData Feed
			INNER JOIN Individual I(NOLOCK) ON Feed.IndividualGUID = I.GUIDReference

			UPDATE C
			SET C.GeographicArea_Id = GA.GUIDReference
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
			FROM #ImportFeedData Feed
			INNER JOIN Candidate C ON Feed.IndividualGUID = C.GUIDReference
			INNER JOIN Country Country ON Country.CountryId = C.Country_Id
			LEFT JOIN GeographicArea GA ON GA.Code = Feed.GACode COLLATE SQL_Latin1_General_CP1_CI_AI
				AND EXISTS (
					SELECT 1
					FROM dbo.Respondent R(NOLOCK)
					WHERE R.GUIDReference = GA.GUIDReference
						AND R.CountryID = @pCountryId
					)
			WHERE Feed.GACode IS NOT NULL

			DELETE OCM
			FROM ORDEREDCONTACTMECHANISM OCM
			INNER JOIN #ImportFeedData Feed ON OCM.Address_Id = Feed.OldMainPostalAddressId
				AND OCM.Candidate_Id = Feed.IndividualGUID

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
			SELECT feed.NewGroupId
				,@GetDate
				,NULL
				,NULL
				,@groupStatusGuid
				,NULL
				,NULL
				,NULL
				,@pUser
				,@GetDate
				,@GetDate
				,@pCountryId
			FROM #ImportFeedData feed

			INSERT [dbo].[Collective] (
				[GUIDReference]
				,[GroupContact_Id]
				,[IsDuplicate]
				,[CountryId]
				,[TypeTranslation_Id]
				,[Sequence]
				,[DiscriminatorType]
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,Interviewer_Id
				)
			SELECT feed.NewGroupId
				,feed.IndividualGUID
				,0
				,@pCountryId
				,@collectiveTranslationId
				,feed.PropesedSqeuence
				,N'HouseHold'
				,@pUser
				,@GetDate
				,@GetDate
				,I.ID
			FROM #ImportFeedData feed
			LEFT JOIN [dbo].[Interviewer] I ON I.InterviewerCode = feed.InterviewerCode
				AND I.Country_Id = @pCountryId

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
				,feed.NewGroupId
				,feed.IndividualGUID
				,@pCountryId
			FROM #ImportFeedData feed

			INSERT [dbo].[CollectiveMembership] (
				[CollectiveMembershipId]
				,[Sequence]
				,[SignUpDate]
				,[DeletedDate]
				,[GPSUser]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				,[Group_Id]
				,[State_Id]
				,[Individual_Id]
				,[DiscriminatorType]
				,[Country_Id]
				)
			SELECT feed.NEWCollectiveMembershipId
				,@groupIndividualIdStartsWith
				,@GetDate
				,NULL
				,@pUser
				,@GetDate
				,@GetDate
				,feed.NewGroupId
				,@defaultGroupMembershipStatusId
				,feed.IndividualGUID
				,N'HouseHold'
				,@pCountryId
			FROM #ImportFeedData feed

			UPDATE C
			SET C.GeographicArea_Id = GA.GUIDReference
				,C.GPSUser = @pUser
				,C.GPSUpdateTimestamp = @GetDate
			FROM #ImportFeedData Feed
			INNER JOIN Candidate C ON Feed.NewGroupId = C.GUIDReference
			INNER JOIN Country Country ON Country.CountryId = C.Country_Id
			LEFT JOIN GeographicArea GA ON GA.Code = Feed.GACode COLLATE SQL_Latin1_General_CP1_CI_AI
				AND EXISTS (
					SELECT 1
					FROM dbo.Respondent R(NOLOCK)
					WHERE R.GUIDReference = GA.GUIDReference
						AND R.CountryID = @pCountryId
					)
			WHERE Feed.GACode IS NOT NULL

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
				,1 AS [Order]
				,@puser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@GetDate AS CreationTimeStamp
				,feed.IndividualGuid AS Candidate_Id
				,feed.PostalAddressGuid AS Address_Id
				,@pCountryId
			FROM #ImportFeedData feed
			
			UNION ALL
			
			SELECT NEWID() AS Id
				,1 AS [Order]
				,@puser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@GetDate AS CreationTimeStamp
				,feed.NewGroupId AS Candidate_Id
				,feed.PostalAddressGuid AS Address_Id
				,@pCountryId
			FROM #ImportFeedData feed

			/******************SATISH***************/
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
			FROM #RepeatableData feed
			
			UNION ALL
			
			SELECT NEWID() AS Id
				,feed.[Order] AS [Order]
				,@puser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@GetDate AS CreationTimeStamp
				,feed.GroupGUID AS Candidate_Id
				,feed.AddressListGUID AS Address_Id
				,@pCountryId
			FROM #RepeatableData feed

			--Insert Attribute Values
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
					WHEN LOWER(DemographicType) IN (
							'date'
							,'datetime'
							)
						THEN DemographicValue
					END
				,NULL
				,CASE 
					WHEN DemographicType = 'Enum'
						THEN (
								SELECT DISTINCT ED.ID
								FROM dbo.EnumDefinition ED
								WHERE ED.Demographic_Id = #Demographics.DemographicId
									AND ED.Value = #Demographics.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI
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
					WHEN DemographicType = 'Boolean'
						THEN 'BooleanAttributeValue'
					WHEN DemographicType IN (
							'date'
							,'datetime'
							)
						THEN 'DateAttributeValue'
					WHEN DemographicType = 'Enum'
						THEN 'EnumAttributeValue'
					END
				,@pCountryId
			FROM #Demographics

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

			COMMIT TRANSACTION T
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION T

			SET @IsTransactionHasErrors = 1

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

		IF (@IsTransactionHasErrors = 0)
		BEGIN
			/* Address change Action task */
			DECLARE @ActiontaskId UNIQUEIDENTIFIER = newid()
			DECLARE @countryid UNIQUEIDENTIFIER
			DECLARE @TypeTranslationid UNIQUEIDENTIFIER
			DECLARE @TranslaionIds UNIQUEIDENTIFIER
			DECLARE @AssigneeId UNIQUEIDENTIFIER
			DECLARE @GUIDRefActionTask UNIQUEIDENTIFIER

			--DECLARE @getdate DATETIME = @GetDate
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
						,feed.NewGroupId
						,@pCountryId
						,NULL
						,@AssigneeId
						,NULL
					FROM #ImportFeedData feed
				END
			END

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
				,'Household created successfully ( ' + IFD.PropesedIndividualId + ' )'
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeed Feed
			INNER JOIN #ImportFeedData IFD ON Feed.[Rownumber] = IFD.Rownumber
		END
	END

	DROP TABLE #GenerateMissingNumbers

	DROP TABLE #ImportFeedData

	DROP TABLE #Demographics

	DROP TABLE #Aliasfeed

	IF OBJECT_ID('tempdb..#AddressTypes') IS NOT NULL
	BEGIN
		DROP TABLE #AddressTypes
	END

	IF OBJECT_ID('tempdb..#RepeatableData') IS NOT NULL
	BEGIN
		DROP TABLE #RepeatableData
	END
END
