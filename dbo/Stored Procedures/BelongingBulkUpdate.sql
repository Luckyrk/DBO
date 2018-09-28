CREATE PROCEDURE [dbo].[BelongingBulkUpdate] (
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

	DECLARE @COLUMNNUMBER INT=0
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
			,@pUser
			,@GetDate
			,@pFileId
			,'Time zone is not configured for the Country'
			);

		PRINT 'Time zone is not configured for the Country'

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
			,@pUser
			,@GetDate
			,@pFileId
			,'File already is processed'
			);

		PRINT 'File already is processed'

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END
	
	DECLARE @Error BIT = 0;
	DECLARE @importDataCount BIGINT = (
			SELECT COUNT(*)
			FROM @pImportFeed
			);
	DECLARE @maxColumnCount INT = (
			SELECT MAX(Rownumber)
			FROM @pColumn
			);
	DECLARE @repeatedSeparator NVARCHAR(MAX) = REPLICATE('|', @maxColumnCount);

	IF OBJECT_ID('tempdb..#TempFeed') IS NOT NULL
		DROP TABLE #TempFeed
	
	SELECT f.[Rownumber]
		,sd.Id AS StateId
		,bt.Id AS BelongingTypeId
		,i.GUIDReference AS IndividualGuid
		,c.GUIDReference AS GroupGuid
		,ISNULL(i.GUIDReference, c.GUIDReference) AS CandidateGuid
		,f.FullRow
		,b.GUIDReference AS RespondentId
	INTO #TempFeed
	FROM @pImportFeed f
	LEFT JOIN (
		SELECT bt.*
			,ttbt.Value AS TranslationValue
		FROM BelongingType bt 
		JOIN translationterm ttbt ON ttbt.translation_id = bt.translation_id
		WHERE bt.Country_id = @pCountryId
			AND ttbt.CultureCode = @pCultureCode
	) AS bt ON bt.TranslationValue LIKE f.BelongingTypeName
	LEFT JOIN Individual i ON i.IndividualId LIKE f.IndividualBusinessId
		AND i.CountryId = @pCountryId
	LEFT JOIN Collective c ON c.Sequence = CAST(f.GroupBusinessId AS INT)
		AND c.CountryId = @pCountryId
	LEFT JOIN Belonging b ON b.TypeId = bt.Id
		AND b.CandidateId IN (
			i.GUIDReference
			,c.GUIDReference
			)
		AND b.BelongingCode = f.BelongingCode
	LEFT JOIN (
		SELECT sd.*
			,ttsd.Value AS TranslationValue
		FROM StateDefinition sd 
		JOIN translationterm ttsd ON sd.Label_Id = ttsd.translation_id
		WHERE sd.Country_id = @pCountryId
			AND sd.Code LIKE 'Belonging%'
	) AS sd ON IIF(f.BelongingStateCode IS NULL, IIF(sd.Id = b.State_id, 1, 0), IIF(sd.TranslationValue LIKE f.BelongingStateCode, 1, 0)) = 1	
	
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
	JOIN @pDemographicData d ON d.Rownumber = tf.Rownumber
	LEFT JOIN Attribute a ON a.[Key] = d.DemographicName
		AND a.Country_Id = @pCountryId
	JOIN @pColumn CP ON A.[KEY]=CP.COLUMNNAME
	LEFT JOIN EnumDefinition ed ON ed.Demographic_Id = a.GUIDReference
		AND a.[Type] LIKE 'Enum'
		AND ed.Value LIKE d.DemographicValue
	
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
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER,0)
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
			,'Target Group or Individual does not exist at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER,0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed f
		JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
		WHERE tf.CandidateGuid IS NULL;

		PRINT 'Target Group or Individual does not exist';

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
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER,0)
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
			,TEMP.*
		FROM (
			SELECT 1 AS Error
				,0 AS IsInvalid
				,'Belonging not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER,0)) AS [Message]
				,@GetDate AS [Date]
				,f.[FullRow]
				,@repeatedSeparator AS SerializedRowErrors
				,@GetDate AS CreationTimeStamp
				,@pUser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@pFileId AS [File_Id]
			FROM @pImportFeed f
			JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
			WHERE tf.BelongingTypeId IS NULL
			) TEMP;

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		SET @Error = 1;
	END
	
	--VALIDATE IF BELONGING EXIST FOR THE INDIVIDUAL OR GROUP
	IF EXISTS (
			SELECT 1
			FROM #TempFeed
			WHERE RespondentId IS NULL
			)
	BEGIN
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER,0)
		FROM @pColumn
		WHERE ColumnName LIKE 'BelongingCode'
		
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
			,a.*
		FROM (
			SELECT DISTINCT 1 AS Err
				,0 AS IsInvalid
				,'Belonging not found in the individual or group at Row ' + CONVERT(VARCHAR, f.Rownumber) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER,0)) AS [Message]
				,@GetDate AS [Date]
				,f.[FullRow]
				,@repeatedSeparator AS SerializedRowData
				,@GetDate AS CreationTimeStamp
				,@pUser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@pFileId AS [File_Id]
		FROM @pImportFeed f
		JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
			WHERE tf.RespondentId IS NULL
			) a;

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
		SELECT @COLUMNNUMBER = ISNULL(ROWNUMBER,0)
		FROM @pColumn
		WHERE ColumnName LIKE '	BelongingStateCode'

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
			,TEMP.*
		FROM (
			SELECT 1 AS Error
				,0 AS IsInvalid
				,'Belonging State not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(@COLUMNNUMBER,0)) AS [Message]
				,@GetDate AS [Date]
				,f.[FullRow]
				,@repeatedSeparator AS SerializedRowErrors
				,@GetDate AS CreationTimeStamp
				,@pUser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@pFileId AS [File_Id]
			FROM @pImportFeed f
			JOIN #TempFeed tf ON tf.Rownumber = f.Rownumber
			WHERE tf.StateId IS NULL
			) TEMP;

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
			,'Attribute not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber,0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed f
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
			,'Enum Attribute Value not found at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber,0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed f
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
			,'Boolean Attribute Value is not correct. Try 0 and 1 at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber,0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed f
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
			,'Int Attribute Value is not correct at Row ' + CONVERT(VARCHAR, f.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, ISNULL(tf.ColumnNumber,0))
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed f
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

	IF (@Error = 1)
	BEGIN
		RETURN;
	END

	--OK. No errors
	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE b
		SET State_id = tf.StateId
		FROM Belonging b
		JOIN #TempFeed tf ON tf.RespondentId = b.GUIDReference

		DELETE av
		FROM AttributeValue av
		JOIN #TempAttributes ta ON ta.AttributeId = av.DemographicId
			AND ta.RespondentId = av.RespondentId

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
		LEFT JOIN AttributeValue av ON av.RespondentId = ta.RespondentId
			AND av.DemographicId = ta.AttributeId
		WHERE av.GUIDReference IS NULL

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
			,'Belonging updated successfully'
			,@GetDate
			,f.[FullRow]
			,@repeatedSeparator
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pImportFeed f
		
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