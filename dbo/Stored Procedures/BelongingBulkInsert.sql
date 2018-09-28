
CREATE PROCEDURE [dbo].[BelongingBulkInsert] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed BelongingImport READONLY
	,@pDemographicData Demographics READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @COLUMNNUMBER INT = 0
	DECLARE @pImportFeedDummy AS TABLE (
		[Rownumber] [int] NULL
		,[BelongingTypeName] [nvarchar](300) NULL
		,[BelongingCode] [nvarchar](300) NULL
		,[BelongingStateCode] [nvarchar](100) NULL
		,[Alias] [nvarchar](300) NULL
		,[IndividualBusinessId] [nvarchar](200) NULL
		,[GroupBusinessId] [nvarchar](200) NULL
		,[FullRow] [nvarchar](max) NULL
		)
	DECLARE @pDemographicDataDummy AS TABLE (
		[Rownumber] [int] NULL
		,[DemographicName] [nvarchar](max) NULL
		,[DemographicValue] [nvarchar](max) NULL
		,[UseShortCode] [bit] NULL
		)

	INSERT INTO @pImportFeedDummy (
		[Rownumber]
		,[BelongingTypeName]
		,[BelongingCode]
		,[BelongingStateCode]
		,[Alias]
		,[IndividualBusinessId]
		,[GroupBusinessId]
		,FullRow
		)
	SELECT Rownumber
		,BelongingTypeName
		,BelongingCode
		,BelongingStateCode
		,Alias
		,IndividualBusinessId
		,GroupBusinessId
		,FullRow
	FROM BelongingImportDummy WITH (NOLOCK)
	WHERE fileid = @pFileId

	INSERT INTO @pDemographicDataDummy (
		[Rownumber]
		,[DemographicName]
		,[DemographicValue]
		,[UseShortCode]
		)
	SELECT Rownumber
		,DemographicName
		,DemographicValue
		,UseShortCode
	FROM DemographicsDummy WITH (NOLOCK)
	WHERE fileid = @pFileId

	/** ERROR CHECKING **/
	DECLARE @GetDate DATETIME = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pCountryId)
			)

	IF (@GetDate IS NULL)
	BEGIN
		INSERT INTO ImportAudit (
			[GUIDReference]
			,[Error]
			,[IsInvalid]
			,[Date]
			,[SerializedRowData]
			,[SerializedRowErrors]
			,[CreationTimeStamp]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[File_Id]
			,[Message]
			)
		VALUES (
			NEWID()
			,1
			,1
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,'1'
			,@GetDate
			,@pFileId
			,'Time zone is not configured for the Country'
			);

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END

	IF NOT EXISTS (
			SELECT 1
			FROM ImportFile I
			JOIN StateDefinition SD ON SD.Id = I.State_Id
				AND I.GUIDReference = @pFileId
			WHERE SD.Code = 'ImportFileProcessing'
				AND SD.Country_Id = @pCountryId
			)
	BEGIN
		INSERT INTO ImportAudit (
			[GUIDReference]
			,[Error]
			,[IsInvalid]
			,[Date]
			,[SerializedRowData]
			,[SerializedRowErrors]
			,[CreationTimeStamp]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[File_Id]
			,[Message]
			)
		VALUES (
			NEWID()
			,1
			,1
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,'2'
			,@GetDate
			,@pFileId
			,'File already is processed'
			);

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END

	DECLARE @Error BIT = 0;
	DECLARE @importDataCount BIGINT = (
			SELECT COUNT(*)
			FROM @pImportFeedDummy
			);
	DECLARE @maxColumnCount INT = (
			SELECT MAX(Rownumber)
			FROM @pColumn
			);
	DECLARE @repeatedSeparator NVARCHAR(MAX) = REPLICATE('|', @maxColumnCount);

	IF OBJECT_ID('tempdb..#TempFeed') IS NOT NULL
		DROP TABLE #TempFeed

	CREATE TABLE #TempFeed (
		[Rownumber] INT NOT NULL
		,StateId UNIQUEIDENTIFIER NULL
		,BelongingTypeId UNIQUEIDENTIFIER NULL
		,CandidateGuid UNIQUEIDENTIFIER NULL
		,FullRow NVARCHAR(MAX)
		,RespondentId UNIQUEIDENTIFIER NULL
		,IsIndividual BIT NOT NULL
		)

	IF EXISTS (
			SELECT 1
			FROM @pColumn
			WHERE ColumnName LIKE 'GroupBusinessId'
			)
	BEGIN
		INSERT INTO #TempFeed
		SELECT DISTINCT f.[Rownumber]
			,sd.Id AS StateId
			,bt.Id AS BelongingTypeId
			,c.GUIDReference AS CandidateGuid
			,f.FullRow
			,'00000000-0000-0000-0000-000000000000'
			,0
		FROM @pImportFeedDummy f
		LEFT JOIN (
			SELECT sd.*
				,ttsd.Value AS TranslationValue
			FROM StateDefinition sd
			JOIN translationterm ttsd ON sd.Label_Id = ttsd.translation_id
				AND ttsd.CultureCode = @pCultureCode
			WHERE sd.Country_id = @pCountryId
				AND sd.Code LIKE 'Belonging%'
			) AS sd ON IIF(f.BelongingStateCode IS NULL, IIF(sd.Code = 'BelongingActive', 1, 0), IIF(sd.TranslationValue LIKE f.BelongingStateCode, 1, 0)) = 1
		LEFT JOIN (
			SELECT bt.*
				,ttbt.Value AS TranslationValue
			FROM BelongingType bt
			JOIN translationterm ttbt ON ttbt.translation_id = bt.translation_id
				AND ttbt.CultureCode = @pCultureCode
			WHERE bt.Country_id = @pCountryId
				AND bt.[Type] = 'GroupBelongingType'
			) AS bt ON bt.TranslationValue LIKE f.BelongingTypeName
		LEFT JOIN Collective c WITH (NOLOCK) ON c.CountryId = @pCountryId
			AND c.Sequence = CAST(f.GroupBusinessId AS INT) -- AND DiscriminatorType='HouseHold'    
	END
	ELSE
	BEGIN
		INSERT INTO #TempFeed
		SELECT DISTINCT f.[Rownumber]
			,sd.Id AS StateId
			,bt.Id AS BelongingTypeId
			,i.GUIDReference AS CandidateGuid
			,f.FullRow
			,'00000000-0000-0000-0000-000000000000'
			,1
		FROM @pImportFeedDummy f
		LEFT JOIN (
			SELECT sd.*
				,ttsd.Value AS TranslationValue --select * from StateDefinition where Code LIKE 'Belonging%'    
			FROM StateDefinition sd
			JOIN translationterm ttsd ON sd.Label_Id = ttsd.translation_id
				AND ttsd.CultureCode = @pCultureCode
			WHERE sd.Country_id = @pCountryId
				AND sd.Code LIKE 'Belonging%'
			) AS sd ON IIF(f.BelongingStateCode IS NULL, IIF(sd.Code = 'BelongingActive', 1, 0), IIF(sd.TranslationValue LIKE f.BelongingStateCode, 1, 0)) = 1
		LEFT JOIN (
			SELECT bt.*
				,ttbt.Value AS TranslationValue
			FROM BelongingType bt
			JOIN translationterm ttbt ON ttbt.translation_id = bt.translation_id
				AND ttbt.CultureCode = @pCultureCode
			WHERE bt.Country_id = @pCountryId
				AND bt.[Type] = 'IndividualBelongingType'
			) AS bt ON bt.TranslationValue LIKE f.BelongingTypeName
		LEFT JOIN Individual i WITH (NOLOCK) ON i.CountryId = @pCountryId
			AND i.IndividualId LIKE f.IndividualBusinessId
	END

	UPDATE #TempFeed
	SET RespondentId = NEWID();

	IF OBJECT_ID('tempdb..#TempAttributes') IS NOT NULL
		DROP TABLE #TempAttributes

	SELECT DISTINCT CAST('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER) AS AttributeValueId
		,a.GUIDReference AS AttributeId
		,tf.RespondentId
		,@pUser AS GPSUser
		,@GetDate AS GPSUpdateTimestamp
		,@GetDate AS CreationDate
		,d.DemographicValue AS Value
		,d.DemographicValue AS ValueDesc
		,ed.Id AS EnumDemogId
		,@pCountryId AS CountryId
		,CONCAT (
			UPPER(LEFT(a.[Type], 1))
			,LOWER(SUBSTRING(a.[Type], 2, LEN(a.[Type])))
			,'AttributeValue'
			) AS AttType
		,tf.Rownumber
		,CP.RowNumber AS [ColumnNumber]
	INTO #TempAttributes
	FROM #TempFeed tf
	JOIN @pDemographicDataDummy d ON d.Rownumber = tf.Rownumber
	LEFT JOIN Attribute a WITH (NOLOCK) ON a.[Key] = d.DemographicName
		AND a.Country_Id = @pCountryId
	JOIN @pColumn CP ON A.[KEY] = CP.COLUMNNAME
	LEFT JOIN EnumDefinition ed ON ed.Demographic_Id = a.GUIDReference
		AND ed.Value LIKE d.DemographicValue
		AND a.[Type] LIKE 'Enum'

	UPDATE #TempAttributes
	SET AttributeValueId = NEWID();

	UPDATE ta
	SET Value = IIF(tt.Translation_Id = ttrue.TranslationId, 1, 0)
	FROM #TempAttributes ta
	JOIN Translation ttrue ON ttrue.KeyName = 'True'
	JOIN Translation tfalse ON tfalse.KeyName = 'False'
	JOIN TranslationTerm tt ON (
			tt.Translation_Id = ttrue.TranslationId
			AND (
				tt.Value LIKE ta.Value
				OR ta.Value LIKE 'True'
				)
			)
		OR (
			tt.Translation_Id = tfalse.TranslationId
			AND (
				tt.Value LIKE ta.Value
				OR ta.Value LIKE 'False'
				)
			)
	WHERE ta.AttType = 'BooleanAttributeValue'

	--VALIDATE IF GROUP OR INDIVIDUAL EXIST      
	IF EXISTS (
			SELECT 1
			FROM #TempFeed
			WHERE CandidateGuid IS NULL
			)
	BEGIN
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER, 0)
		FROM @pColumn
		WHERE ColumnName LIKE 'IndividualBusinessId'
			OR ColumnName LIKE 'GroupBusinessId'

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
			,'Target Group or Individual does not exist at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'3'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
		WHERE tf.CandidateGuid IS NULL;

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	--VALIDATE IF BELONGING NAME EXIST      
	IF EXISTS (
			SELECT 1
			FROM #TempFeed
			WHERE BelongingTypeId IS NULL
			)
	BEGIN
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER, 0)
		FROM @pColumn
		WHERE ColumnName LIKE 'BelongingTypeName'

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
			,'Belonging not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'4'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
		WHERE tf.BelongingTypeId IS NULL;

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	--VALIDATE IF BELONGING STATE EXIST      
	IF EXISTS (
			SELECT 1
			FROM #TempFeed
			WHERE StateId IS NULL
			)
	BEGIN
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER, 0)
		FROM @pColumn
		WHERE ColumnName LIKE 'BelongingStateCode'

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
			,'Belonging State not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'5'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
		WHERE tf.StateId IS NULL;

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	--VALIDATE IF ATTRIBUTES EXIST      
	IF EXISTS (
			SELECT 1
			FROM #TempAttributes
			WHERE AttributeId IS NULL
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
			,'Attribute not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'6'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempAttributes tf ON tf.Rownumber = f.Rownumber
		WHERE tf.AttributeId IS NULL;

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	IF EXISTS (
			SELECT 1
			FROM #TempAttributes
			WHERE EnumDemogId IS NULL
				AND AttType LIKE 'Enum%'
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
			,'Enum Attribute Value not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'7'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempAttributes tf ON tf.Rownumber = f.Rownumber
		WHERE EnumDemogId IS NULL
			AND AttType LIKE 'Enum%';

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	IF EXISTS (
			SELECT 1
			FROM #TempAttributes
			WHERE RTRIM(LTRIM(Value)) NOT IN (
					'0'
					,'1'
					)
				AND AttType LIKE 'Bool%'
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
			,'Boolean Attribute Value is not correct. Try 0 and 1  at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'8'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempAttributes tf ON tf.Rownumber = f.Rownumber
		WHERE RTRIM(LTRIM(Value)) NOT IN (
				'0'
				,'1'
				)
			AND AttType LIKE 'Bool%';

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	IF EXISTS (
			SELECT 1
			FROM #TempAttributes
			WHERE TRY_PARSE(Value AS INT) IS NULL
				AND Value IS NOT NULL
				AND AttType LIKE 'Int%'
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
			,'Int Attribute Value is not correct at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'9'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempAttributes tf ON tf.Rownumber = f.Rownumber
		WHERE TRY_PARSE(Value AS INT) IS NULL
			AND Value IS NOT NULL
			AND AttType LIKE 'Int%';

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	IF EXISTS (
			SELECT 1
			FROM #TempAttributes
			WHERE TRY_PARSE(Value AS INT) IS NULL
				AND Value IS NOT NULL
				AND AttType LIKE 'Float%'
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
			,'Float Attribute Value is not correct at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber, 0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'10'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f
		JOIN #TempAttributes tf ON tf.Rownumber = f.Rownumber
		WHERE TRY_PARSE(Value AS INT) IS NULL
			AND Value IS NOT NULL
			AND AttType LIKE 'Float%';

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END

	IF (@Error = 1)
	BEGIN
		RETURN;
	END

	----OK. No errors    
	IF OBJECT_ID('tempdb..#TempBelong') IS NOT NULL
		DROP TABLE #TempBelong

	SELECT DISTINCT tf.RespondentId AS GuidReference
		,tf.CandidateGuid AS CandidateId
		,tf.BelongingTypeId AS TypeId
		,ISNULL(maxc.MaxCode, 0) + ROW_NUMBER() OVER (
			PARTITION BY tf.CandidateGuid
			,tf.BelongingTypeId ORDER BY tf.RespondentId ASC
			) AS BelongingCode
		,@pUser AS GPSUser
		,@GetDate AS GPSUpdateTimestamp
		,@GetDate AS CreationTimestamp
		,tf.StateId AS StateId
		,IIF(tf.IsIndividual = 1, 'Individual', 'Group') + 'Belonging' AS [Type]
	INTO #TempBelong
	FROM #TempFeed tf
	LEFT JOIN (
		SELECT ii.guidreference
			,TypeId
			,MAX(bb.BelongingCode) AS MaxCode
		FROM Candidate ii
		JOIN Belonging bb ON bb.Candidateid = ii.guidreference
		GROUP BY ii.guidreference
			,bb.TypeId
		) AS maxc ON maxc.guidreference = tf.CandidateGuid
		AND maxc.TypeId = tf.BelongingTypeId

	BEGIN TRANSACTION

	BEGIN TRY
		INSERT INTO Respondent
		SELECT Guidreference
			,'Belonging'
			,bt.Country_Id
			,@pUser
			,@GetDate
			,@GetDate
		FROM #TempBelong tb
		JOIN BelongingType bt ON bt.Id = tb.TypeId;

		INSERT INTO Belonging
		SELECT *
		FROM #TempBelong;

		IF OBJECT_ID('tempdb..#TempSortAttMax') IS NOT NULL
			DROP TABLE #TempSortAttMax

		SELECT sa.Id
			,MAX(ob.[Order]) AS MaxOrder
		INTO #TempSortAttMax
		FROM SortAttribute sa
		JOIN OrderedBelonging ob ON ob.BelongingSection_Id = sa.Id
		GROUP BY sa.Id

		INSERT INTO OrderedBelonging
		SELECT NEWID()
			,sa.id
			,tb.GuidReference
			,ISNULL(tm.MaxOrder, 0) + ROW_NUMBER() OVER (
				PARTITION BY sa.Id ORDER BY tb.GuidReference ASC
				)
			,@pUser
			,@GetDate
			,@GetDate
		FROM #TempBelong tb
		JOIN SortAttribute sa ON SA.BelongingType_Id = tb.TypeId
		LEFT JOIN #TempSortAttMax tm ON tm.Id = sa.Id

		INSERT INTO AttributeValue (
			GUIDReference
			,DemographicId
			,RespondentId
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Value
			,ValueDesc
			,EnumDefinition_Id
			,Country_Id
			,Discriminator
			)
		SELECT ta.AttributeValueId
			,ta.AttributeId
			,ta.RespondentId
			,ta.GPSUser
			,ta.GPSUpdateTimestamp
			,ta.CreationDate
			,ta.Value
			,ta.ValueDesc
			,ta.EnumDemogId
			,ta.CountryId
			,ta.AttType
		FROM #TempAttributes ta

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
			,'Belonging created successfully'
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,'10'
			,@GetDate
			,@pFileId
		FROM @pImportFeedDummy f

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
			,ERROR_MESSAGE()
			,@GetDate
			,NULL
			,NULL
			,NULL
			,'11'
			,@GetDate
			,@pFileId
			)

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId
	END CATCH
END
