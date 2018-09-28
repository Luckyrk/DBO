/*##########################################################################
-- Name      	: IncentiveTransactionsUpdateImport
-- Date             : 2016-02-23
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
-- Sample Execution :
  			
				DECLARE @pFileId UNIQUEIDENTIFIER='077C895E-1A4A-CB05-222E-08D3385CB8BE'
				delete from ImportAudit where [File_Id]=@pFileId
				declare @pColumn dbo.ColumnTableType
				insert into @pColumn values(1,N'BusinessId',1)
				insert into @pColumn values(2,N'IncentiveCode',0)
				insert into @pColumn values(3,N'Points',0)
				insert into @pColumn values(4,N'Comments',0)
				declare @pImportFeed dbo.IncentiveTransactionsImportFeedUpdate
				insert into @pImportFeed values(1,'783153-00',NULL,'90',NULL,'GPS_Compensation_2015-02-08',1800,NULL,NULL,NULL,'783153-00|1101|14|GPS_Compensation_2015-02-08')
				declare @AliasImportFeed dbo.NamedAliasImportFeed
				--insert into @AliasImportFeed values(1,N'NPAN(Household Panel)',N'75432108')
				DECLARE @pCountryId UNIQUEIDENTIFIER='70387977-88F8-40C4-BCD0-1173F1AAFFC4'
				DECLARE @pUser NVARCHAR(MAX)=N'TestUserUK1'
				DECLARE @pCultureCode INT=2057
		exec [IncentiveTransactionsUpdateImport] @pColumn,@pImportFeed,@AliasImportFeed,@pCountryId,@pUser,@pFileId,@pCultureCode
		select * from ImportAudit where [File_Id]=@pFileId
		delete from ImportAudit where [File_Id]=@pFileId
##########################################################################
-- version  user						date        change 
-- 1.0  Jagadeesh Boddu				  2016-02-23   Initial
##########################################################################*/

CREATE PROCEDURE [dbo].[IncentiveTransactionsUpdateImport] (
	@pColumn ColumnTableType READONLY
	,@pImportFeed IncentiveTransactionsImportFeedUpdate READONLY
	,@AliasImportFeed NamedAliasImportFeed READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pUser NVARCHAR(200)
	,@pFileId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

	DECLARE @GetDate DATETIME
	DECLARE @COLUMNNUMBER INT=0
	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pCountryId)
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

	DECLARE @REPETSEPARATOER NVARCHAR(max)

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

	DECLARE @GpsUser NVARCHAR(50) = @pUser
	DECLARE @Configuration_Id UNIQUEIDENTIFIER
	DECLARE @GroupBusinessIdDigits INT
	DECLARE @IndividualBusinessIdDigits INT
	DECLARE @IsPointsLimitEnable BIT
	DECLARE @Points BIGINT
	DECLARE @ImportFormat_Id UNIQUEIDENTIFIER

	SET @IsPointsLimitEnable = (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsPointsLimitEnable', 0)
			)

	SELECT @Points = ISNULL(Points, 2147483647)
	FROM IdentityUser iu
	INNER JOIN SystemUserRole sur ON iu.Id = sur.IdentityUserId
	INNER JOIN SystemRoleType srt ON srt.SystemRoleTypeId = sur.SystemRoleTypeId
	LEFT OUTER JOIN UserPointsRoleMapping upr ON upr.SystemRoleTypeId = srt.SystemRoleTypeId
		AND upr.CountryId = @pCountryId
	WHERE iu.UserName = @GpsUser
		AND iu.Country_Id = @pCountryId

	SELECT @ImportFormat_Id = ImportFormat_Id
	FROM importfile
	WHERE GUIDReference = @pFileId

	SELECT @Configuration_Id = Configuration_Id
	FROM Country
	WHERE @pCountryId = CountryId

	SELECT @GroupBusinessIdDigits = GroupBusinessIdDigits
		,@IndividualBusinessIdDigits = IndividualBusinessIdDigits
	FROM CountryConfiguration
	WHERE Id = @Configuration_Id

	IF EXISTS (
			SELECT 1
			FROM [ImportColumnMapping]
			WHERE importformat_id = @ImportFormat_Id
				AND IsGroupAlias = 1
			)
	BEGIN
		SET @Error = 1

		INSERT INTO ImportAudit
		VALUES (
			NEWID()
			,1
			,1
			,'Points Import process - group aliases not supported'
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
			)

		EXEC InsertImportFile 'ImportFileError'
			,@pUser
			,@pFileId
			,@pCountryId
	END

	IF EXISTS (
			SELECT 1
			FROM [ImportColumnMapping]
			WHERE importformat_id = @ImportFormat_Id
				AND IsRefererAlias = 1
			)
	BEGIN
		SET @Error = 1

		INSERT INTO ImportAudit
		VALUES (
			NEWID()
			,1
			,1
			,'Points Import process - alias id not supported'
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
			)

		EXEC InsertImportFile 'ImportFileError'
			,@pUser
			,@pFileId
			,@pCountryId
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

			/*BusinessId & Format*/
			IF (@columnName = 'BusinessId')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE CHARINDEX('-', BusinessId) = 0
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
						,'Invalid BusinessId Format ' + BusinessId + ' at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,MT.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed MT
					WHERE CHARINDEX('-', BusinessId) = 0
				END
				ELSE
				BEGIN
					IF EXISTS (
							SELECT 1
							FROM @pImportFeed
							WHERE LEN(SUBSTRING(BusinessId, 1, (CHARINDEX('-', BusinessId) - 1))) <> @GroupBusinessIdDigits
								OR LEN(SUBSTRING(BusinessId, (CHARINDEX('-', BusinessId) + 1), LEN(BusinessId))) <> @IndividualBusinessIdDigits
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
							,'Invalid BusinessId Format ' + BusinessId + ' at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
							,@GetDate
							,MT.[FullRow]
							,@REPETSEPARATOER
							,@GetDate
							,@pUser
							,@GetDate
							,@pFileId
						FROM @pImportFeed MT
						WHERE LEN(SUBSTRING(BusinessId, 1, (CHARINDEX('-', BusinessId) - 1))) <> @GroupBusinessIdDigits
							OR LEN(SUBSTRING(BusinessId, (CHARINDEX('-', BusinessId) + 1), LEN(BusinessId))) <> @IndividualBusinessIdDigits
					END

					IF EXISTS (
							SELECT 1
							FROM @pImportFeed MT
							LEFT OUTER JOIN Individual I ON MT.BusinessId = I.IndividualId COLLATE SQL_Latin1_General_CP1_CI_AI
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
							,'BusinessId does not exits at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
							,@GetDate
							,MT.[FullRow]
							,@REPETSEPARATOER
							,@GetDate
							,@pUser
							,@GetDate
							,@pFileId
						FROM @pImportFeed MT
						LEFT OUTER JOIN Individual I ON MT.BusinessId = I.IndividualId
							AND I.CountryId = @pCountryId
						WHERE I.IndividualId IS NULL
					END
				END
			END

			/*GroupId & Format, those who are not having BusinessId*/
			IF (@columnName = 'GroupId')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed MT
						WHERE ISNULL(MT.BusinessId, '') = ''
							AND NOT EXISTS (
								SELECT 1
								FROM @AliasImportFeed al
								INNER JOIN NamedAliasContext nac ON al.NamedAliasKey = nac.NAME
									AND Country_Id = @pCountryId
								INNER JOIN [ImportColumnMapping] icm ON icm.importformat_id = @ImportFormat_Id
									AND icm.Alias_Id = nac.NamedAliasContextId
									AND icm.IsIdentifier = 1
								WHERE al.Rownumber = MT.Rownumber
								)
							AND NOT EXISTS (
								SELECT 1
								FROM Collective
								WHERE CountryId = @pCountryId
									AND Sequence = CAST(MT.GroupId AS INT)
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
						,'Grroup Id does not exsits at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,MT.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed MT
					WHERE ISNULL(MT.BusinessId, '') = ''
						AND NOT EXISTS (
							SELECT 1
							FROM @AliasImportFeed al
							INNER JOIN NamedAliasContext nac ON al.NamedAliasKey = nac.NAME
								AND Country_Id = @pCountryId
							INNER JOIN [ImportColumnMapping] icm ON icm.importformat_id = @ImportFormat_Id
								AND icm.Alias_Id = nac.NamedAliasContextId
								AND icm.IsIdentifier = 1
							WHERE al.Rownumber = MT.Rownumber
							)
						AND NOT EXISTS (
							SELECT 1
							FROM Collective
							WHERE CountryId = @pCountryId
								AND Sequence = CAST(MT.GroupId AS INT)
							)
				END
			END

			/* IncentiveCode Validation */
			--IF (@columnName = 'IncentiveCode')
			--BEGIN
			--	IF EXISTS (
			--			SELECT 1
			--			FROM @pImportFeed mt
			--			LEFT JOIN (
			--				SELECT ip.*
			--				FROM IncentivePoint ip
			--				INNER JOIN Respondent R ON ip.GUIDReference = R.GUIDReference
			--					AND R.CountryID = @pCountryId
			--					AND ip.[Type] = 'Incentive'
			--				) ip ON ip.Code = mt.IncentiveCode
			--			WHERE ip.Code IS NULL
			--			)
			--	BEGIN
			--		SET @Error = 1

			--		INSERT INTO ImportAudit (
			--			GUIDReference
			--			,Error
			--			,IsInvalid
			--			,[Message]
			--			,[Date]
			--			,SerializedRowData
			--			,SerializedRowErrors
			--			,CreationTimeStamp
			--			,GPSUser
			--			,GPSUpdateTimestamp
			--			,[File_Id]
			--			)
			--		SELECT NEWID()
			--			,1
			--			,0
			--			,'Invalid Incentive code at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
			--			,@GetDate
			--			,MT.[FullRow]
			--			,@REPETSEPARATOER
			--			,@GetDate
			--			,@pUser
			--			,@GetDate
			--			,@pFileId
			--		FROM @pImportFeed mt
			--		LEFT JOIN IncentivePoint ip ON ip.Code = mt.IncentiveCode
			--			AND ip.[Type] = 'Incentive'
			--		LEFT JOIN Respondent R ON ip.GUIDReference = R.GUIDReference
			--			AND R.CountryID = @pCountryId
			--		WHERE ip.Code IS NULL
			--			OR R.GuidReference IS NULL
			--	END
			--END

			/*PanelNameOrPanelCode*/
			IF (@columnName = 'PanelNameOrPanelCode')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed MT
						WHERE NOT EXISTS (
								SELECT 1
								FROM Panel P
								WHERE MT.PanelNameOrPanelCode = P.NAME
									OR MT.PanelNameOrPanelCode = CAST(P.PanelCode AS NVARCHAR(50))
									AND Country_Id = @pCountryId
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
						,'Invalid Panel code at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,MT.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed MT
					WHERE NOT EXISTS (
							SELECT 1
							FROM Panel P
							WHERE MT.PanelNameOrPanelCode = P.NAME
								OR MT.PanelNameOrPanelCode = CAST(P.PanelCode AS NVARCHAR(50))
								AND Country_Id = @pCountryId
							)
				END
			END

			/*Points Validation*/
			IF (@columnName = 'Points')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed
						WHERE @Points < Points
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
						,'Points are execeded the limit for :' + BusinessId + ' at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,MT.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed MT
					WHERE @Points < Points
				END
			END

			/*IncentiveCode Validation*/
			IF (@columnName = 'IncentiveCode')
			BEGIN
				IF EXISTS (
						SELECT mt.BusinessId
						FROM @pImportFeed mt
						LEFT JOIN IncentivePoint ip ON ip.Code = mt.IncentiveCode
							AND ip.[Type] = 'Incentive'
						LEFT JOIN Respondent R ON ip.GUIDReference = R.GUIDReference
							AND R.CountryID = @pCountryId
						WHERE ip.Code IS NULL
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
						,'Invalid Incentive code for :' + mt.BusinessId + ' at Row ' + CONVERT(VARCHAR, MT.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,MT.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed mt
					LEFT JOIN IncentivePoint ip ON ip.Code = mt.IncentiveCode
						AND ip.[Type] = 'Incentive'
					LEFT JOIN Respondent R ON ip.GUIDReference = R.GUIDReference
						AND R.CountryID = @pCountryId
					WHERE ip.Code IS NULL
				END

				IF EXISTS (
						SELECT ip.Code
						FROM @pImportFeed mt
						INNER JOIN IncentivePoint ip ON ip.Code = mt.IncentiveCode
							AND ip.[Type] = 'Incentive'
						INNER JOIN Respondent R ON ip.GUIDReference = R.GUIDReference
							AND R.CountryID = @pCountryId
						WHERE (
								ip.ValidFrom IS NOT NULL
								AND ip.ValidFrom >= @GetDate
								)
							OR (
								ip.ValidTo IS NOT NULL
								AND ip.ValidTo <= @GetDate
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
						,'Incentive code validity expired for :' + mt.BusinessId
						,@GetDate
						,MT.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed mt
					INNER JOIN IncentivePoint ip ON ip.Code = mt.IncentiveCode
						AND ip.[Type] = 'Incentive'
					INNER JOIN Respondent R ON ip.GUIDReference = R.GUIDReference
						AND R.CountryID = @pCountryId
					WHERE (
							ip.ValidFrom IS NOT NULL
							AND ip.ValidFrom >= @GetDate
							)
						OR (
							ip.ValidTo IS NOT NULL
							AND ip.ValidTo <= @GetDate
							)
				END
			END

			/*TransactionSource*/
			IF (@columnName = 'TransactionSource')
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM @pImportFeed F
						LEFT OUTER JOIN TransactionSource TS ON TS.Code = F.TransactionSource
							AND TS.Country_Id = @pCountryId
						WHERE TS.Code IS NULL
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
						,'Invalid TransactionSource code at Row ' + CONVERT(VARCHAR, F.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @columnsincrement)
						,@GetDate
						,F.[FullRow]
						,@REPETSEPARATOER
						,@GetDate
						,@pUser
						,@GetDate
						,@pFileId
					FROM @pImportFeed F
					LEFT OUTER JOIN TransactionSource TS ON TS.Code = F.TransactionSource
						AND TS.Country_Id = @pCountryId
					WHERE TS.Code IS NULL
				END
			END

			SET @columnsincrement = @columnsincrement + 1
		END
	END

	/* Alias validation , if there is no Buissness Id AND */
	IF EXISTS (
			SELECT 1
			FROM @AliasImportFeed al
			INNER JOIN @pImportFeed MT ON MT.Rownumber = al.Rownumber
			INNER JOIN NamedAliasContext nac ON al.NamedAliasKey = nac.NAME
				AND Country_Id = @pCountryId
			INNER JOIN [ImportColumnMapping] icm ON icm.importformat_id = @ImportFormat_Id
				AND icm.Alias_Id = nac.NamedAliasContextId
				AND icm.IsIdentifier = 1
			LEFT OUTER JOIN NamedAlias na ON na.AliasContext_Id = nac.NamedAliasContextId
				AND al.NamedAliasValue = na.[Key]
			WHERE na.AliasContext_Id IS NULL
				AND ISNULL(MT.BusinessId, '') = ''
			)
		--AND ISNULL(MT.GroupId, '') = '')
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
			,'Invalid Panel code'
			,@GetDate
			,MT.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @AliasImportFeed al
		INNER JOIN @pImportFeed MT ON MT.Rownumber = al.Rownumber
		INNER JOIN NamedAliasContext nac ON al.NamedAliasKey = nac.NAME
			AND Country_Id = @pCountryId
		INNER JOIN [ImportColumnMapping] icm ON icm.importformat_id = @ImportFormat_Id
			AND icm.Alias_Id = nac.NamedAliasContextId
			AND icm.IsIdentifier = 1
		LEFT OUTER JOIN NamedAlias na ON na.AliasContext_Id = nac.NamedAliasContextId
			AND al.NamedAliasValue = na.[Key]
		WHERE na.AliasContext_Id IS NULL
			AND ISNULL(MT.BusinessId, '') = ''
			--AND ISNULL(MT.GroupId, '') = ''
	END

	IF OBJECT_ID('tempdb..#FinalProcessingTable') IS NOT NULL
		DROP TABLE #FinalProcessingTable

	CREATE TABLE #FinalProcessingTable (
		BusinessId NVARCHAR(max)
		,IncentiveCode NVARCHAR(max)
		,Points BIGINT
		,Comments NVARCHAR(max)
		,IndividualGUID UNIQUEIDENTIFIER
		,IncentiveGUID UNIQUEIDENTIFIER
		,IncentiveAccountId UNIQUEIDENTIFIER
		,IncentiveType NVARCHAR(max)
		,IncentiveInfoGuid UNIQUEIDENTIFIER
		,PanelGUID UNIQUEIDENTIFIER
		,GroupId UNIQUEIDENTIFIER
		,[TransactionDate] DATETIME NULL
		,[SynchronisationDate] DATETIME NULL
		,[TransactionSource] NVARCHAR(max) NULL
		,GpsUser NVARCHAR(max)
		,PanelistGUID UNIQUEIDENTIFIER NULL
		,[Rownumber] INT NULL
		,[FullRow] NVARCHAR(max) NULL
		,PanelistIncentiveLevel_Id UNIQUEIDENTIFIER NULL
		,IncentiveLevelValue UNIQUEIDENTIFIER NULL
		,PanelistIncentiveLevel_Id_IsDefault BIT NULL
		,IncentiveLevelValueCanOverride BIT NULL
		,TransactionSourceId UNIQUEIDENTIFIER NULL
		,Depositor_Id UNIQUEIDENTIFIER NULL
		)

	/* BusinessId is not null && IncentiveCode is not null */
	INSERT INTO #FinalProcessingTable (
		BusinessId
		,IncentiveCode
		,Points
		,Comments
		,IndividualGUID
		,IncentiveGUID
		,IncentiveAccountId
		,IncentiveType
		,IncentiveInfoGuid
		,PanelGUID
		,GroupId
		,[TransactionDate]
		,[SynchronisationDate]
		,[TransactionSource]
		,GpsUser
		,[Rownumber]
		,[FullRow]
		,Depositor_Id
		)
	SELECT DISTINCT BusinessId
		,IncentiveCode
		,isnull(Points, ip.Value)
		,Comments
		,I.GUIDReference AS IndividualGUID
		,IP.GUIDReference AS IncentiveGUID
		,(
			CASE 
				WHEN Inc.[Type] = 'OwnAccount'
					THEN Inc.IncentiveAccountId
				ELSE Inc.Beneficiary_Id
				END
			)
		,Inc.[Type]
		,NEWID() AS IncentiveInfoGuid
		,P.GUIDReference
		,NULL
		,ISNULL(MT.[TransactionDate], @GetDate)
		,MT.[SynchronisationDate]
		,MT.[TransactionSource]
		,@GpsUser
		,MT.[Rownumber]
		,MT.[FullRow]
		,Inc.IncentiveAccountId
	FROM @pImportFeed MT
	INNER JOIN Individual I ON MT.BusinessId = I.IndividualId COLLATE SQL_Latin1_General_CP1_CI_AI
	INNER JOIN IncentivePoint ip ON ip.Code = MT.IncentiveCode
		AND ip.[Type] = 'Incentive'
	INNER JOIN Respondent R ON R.GUIDReference = ip.GUIDReference
		AND R.CountryID = @pCountryId
	INNER JOIN IncentiveAccount Inc ON Inc.IncentiveAccountId = I.GUIDReference
	LEFT OUTER JOIN Panel P ON (
			MT.PanelNameOrPanelCode = P.NAME
			OR MT.PanelNameOrPanelCode = CAST(P.PanelCode AS NVARCHAR(50))
			)
		AND P.Country_Id = @pCountryId
	WHERE I.CountryId = @pCountryId
		AND MT.IncentiveCode IS NOT NULL
		AND MT.BusinessId IS NOT NULL --AND ISNULL(MT.GroupId, '') = ''

	/* BusinessId is null, group id is not null && IncentiveCode is not null */
	IF OBJECT_ID('tempdb..#TblCM') IS NOT NULL
		DROP TABLE #TblCM

	CREATE TABLE #TblCM (
		Rownumber INT
		,GroupId INT
		,GROUPGUID UNIQUEIDENTIFIER
		,IndividualGUID UNIQUEIDENTIFIER
		)

	INSERT INTO #TblCM (
		Rownumber
		,GroupId
		,GROUPGUID
		,IndividualGUID
		)
	SELECT Rownumber
		,GroupId
		,Group_Id
		,Individual_Id
	FROM (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY CM.Group_Id ORDER BY CM.CreationTimeStamp DESC
				) AS Id
			,MT.Rownumber
			,MT.GroupId
			,CM.Group_Id
			,CM.Individual_Id
		FROM @pImportFeed MT
		INNER JOIN Collective C ON C.Sequence = MT.GroupId
			AND C.CountryId = @pCountryId
		INNER JOIN CollectiveMembership CM ON CM.Group_Id = C.GUIDReference
			AND C.CountryId = @pCountryId
		INNER JOIN StateDefinition sd ON sd.Id = CM.State_Id
			AND sd.InactiveBehavior = 0
		WHERE C.CountryId = @pCountryId
			AND MT.IncentiveCode IS NOT NULL
			AND ISNULL(MT.BusinessId, '') = ''
			AND MT.GroupId IS NOT NULL
		) T
	WHERE T.Id = 1

	INSERT INTO #FinalProcessingTable (
		BusinessId
		,IncentiveCode
		,Points
		,Comments
		,IndividualGUID
		,IncentiveGUID
		,IncentiveAccountId
		,IncentiveType
		,IncentiveInfoGuid
		,PanelGUID
		,GroupId
		,[TransactionDate]
		,[SynchronisationDate]
		,[TransactionSource]
		,GpsUser
		,[Rownumber]
		,[FullRow]
		,Depositor_Id
		)
	SELECT DISTINCT BusinessId
		,IncentiveCode
		,isnull(Points, ip.Value)
		,Comments
		,tc.IndividualGUID AS IndividualGUID
		,IP.GUIDReference AS IncentiveGUID
		,(
			CASE 
				WHEN Inc.[Type] = 'OwnAccount'
					THEN Inc.IncentiveAccountId
				ELSE Inc.Beneficiary_Id
				END
			)
		,Inc.[Type]
		,NEWID() AS IncentiveInfoGuid
		,P.GUIDReference
		,NULL
		,ISNULL(MT.[TransactionDate], @GetDate)
		,MT.[SynchronisationDate]
		,MT.[TransactionSource]
		,@GpsUser
		,MT.[Rownumber]
		,MT.[FullRow]
		,Inc.IncentiveAccountId
	FROM @pImportFeed MT
	INNER JOIN #TblCM tc ON MT.Rownumber = tc.Rownumber
	INNER JOIN IncentivePoint ip ON ip.Code = MT.IncentiveCode
		AND ip.[Type] = 'Incentive'
	INNER JOIN Respondent R ON R.GUIDReference = ip.GUIDReference
		AND R.CountryID = @pCountryId
	INNER JOIN IncentiveAccount Inc ON Inc.IncentiveAccountId = tc.IndividualGUID
	LEFT OUTER JOIN Panel P ON (
			MT.PanelNameOrPanelCode = P.NAME
			OR MT.PanelNameOrPanelCode = P.PanelCode
			)
		AND P.Country_Id = @pCountryId
	WHERE MT.IncentiveCode IS NOT NULL
		AND ISNULL(MT.BusinessId, '') = ''
		AND MT.GroupId IS NOT NULL

	/* BusinessId is null,groupid is null && IncentiveCode is not null */
	INSERT INTO #FinalProcessingTable (
		BusinessId
		,IncentiveCode
		,Points
		,Comments
		,IndividualGUID
		,IncentiveGUID
		,IncentiveAccountId
		,IncentiveType
		,IncentiveInfoGuid
		,PanelGUID
		,GroupId
		,[TransactionDate]
		,[SynchronisationDate]
		,[TransactionSource]
		,GpsUser
		,[Rownumber]
		,[FullRow]
		,Depositor_Id
		)
	SELECT DISTINCT BusinessId
		,IncentiveCode
		,isnull(Points, ip.Value)
		,Comments
		,I.GUIDReference AS IndividualGUID
		,IP.GUIDReference AS IncentiveGUID
		,(
			CASE 
				WHEN Inc.[Type] = 'OwnAccount'
					THEN Inc.IncentiveAccountId
				ELSE Inc.Beneficiary_Id
				END
			)
		,Inc.[Type]
		,NEWID() AS IncentiveInfoGuid
		,P.GUIDReference
		,NULL
		,ISNULL(MT.[TransactionDate], @GetDate)
		,MT.[SynchronisationDate]
		,MT.[TransactionSource]
		,@GpsUser
		,MT.[Rownumber]
		,MT.[FullRow]
		,Inc.IncentiveAccountId
	FROM @pImportFeed MT
	INNER JOIN @AliasImportFeed al ON MT.Rownumber = al.Rownumber
	INNER JOIN NamedAliasContext nac ON al.NamedAliasKey = nac.NAME
		AND Country_Id = @pCountryId
	INNER JOIN [ImportColumnMapping] icm ON icm.importformat_id = @ImportFormat_Id
		AND icm.Alias_Id = nac.NamedAliasContextId
		AND icm.IsIdentifier = 1
	INNER JOIN NamedAlias na ON na.AliasContext_Id = nac.NamedAliasContextId
		AND al.NamedAliasValue = na.[Key]
	INNER JOIN Individual I ON na.Candidate_Id = I.GUIDReference --COLLATE SQL_Latin1_General_CP1_CI_AI
	INNER JOIN IncentivePoint ip ON ip.Code = MT.IncentiveCode
		AND ip.[Type] = 'Incentive'
	INNER JOIN Respondent R ON R.GUIDReference = ip.GUIDReference
		AND R.CountryID = @pCountryId
	INNER JOIN IncentiveAccount Inc ON Inc.IncentiveAccountId = I.GUIDReference
	LEFT OUTER JOIN Panel P ON (
			MT.PanelNameOrPanelCode = P.NAME
			OR MT.PanelNameOrPanelCode = P.PanelCode
			)
		AND P.Country_Id = @pCountryId
	WHERE I.CountryId = @pCountryId
		AND MT.IncentiveCode IS NOT NULL
		AND MT.BusinessId IS NULL --AND ISNULL(MT.GroupId, '') = ''

	UPDATE FP
	SET FP.TransactionSourceId = TS.TransactionSourceId
	FROM #FinalProcessingTable FP
	INNER JOIN TransactionSource TS ON TS.Code = [TransactionSource] COLLATE SQL_Latin1_General_CP1_CI_AI

	UPDATE FPT
	SET FPT.PanelistGUID = pl.GUIDReference
		,FPT.PanelistIncentiveLevel_Id = pl.IncentiveLevel_Id
	FROM #FinalProcessingTable FPT
	INNER JOIN Panelist pl ON FPT.PanelGUID = pl.Panel_Id
		AND pl.PanelMember_Id = FPT.IndividualGUID
		AND pl.Country_Id = @pCountryId
	WHERE PanelGUID IS NOT NULL
		AND pl.GUIDReference IS NOT NULL

	UPDATE FPT
	SET FPT.PanelistGUID = pl.GUIDReference
		,FPT.PanelistIncentiveLevel_Id = pl.IncentiveLevel_Id
	FROM #FinalProcessingTable FPT
	INNER JOIN CollectiveMembership cmp ON cmp.Individual_Id = FPT.IndividualGUID
		AND cmp.Country_Id = @pCountryId
	INNER JOIN StateDefinition sd ON sd.Id = cmp.State_Id
		AND sd.InactiveBehavior = 0
	INNER JOIN Panelist pl ON FPT.PanelGUID = pl.Panel_Id
		AND pl.PanelMember_Id = cmp.Group_Id
		AND pl.Country_Id = @pCountryId
	WHERE PanelGUID IS NOT NULL
		AND FPT.PanelistGUID IS NULL

	IF OBJECT_ID('tempdb..#TempPl') IS NOT NULL
		DROP TABLE #TempPl

	SELECT ROWID
		,IncentiveLevelValue
		,IncentiveLevelValueCanOverride
		,PanelistIncentiveLevel_Id_IsDefault
		,Points
		,IncentiveGUID
		,[Rownumber]
	INTO #TempPl
	FROM (
		SELECT (
				ROW_NUMBER() OVER (
					PARTITION BY ILV.LevelValue ORDER BY ILV.LevelValue DESC
					)
				) AS ROWID
			,ILV.GUIDReference AS IncentiveLevelValue
			,ILV.CanOverride AS IncentiveLevelValueCanOverride
			,IL.IsDefault AS PanelistIncentiveLevel_Id_IsDefault
			,IIF(ILV.GUIDReference IS NOT NULL, IIF(IL.IsDefault = 1, IP.Value, ILV.LevelValue), FP.Points) AS Points
			,IIF(FP.IncentiveGUID IS NULL, IIF(ILV.GUIDReference IS NOT NULL, ILV.Incentive_Id, NULL), FP.IncentiveGUID) AS IncentiveGUID
			,FP.[Rownumber]
		FROM #FinalProcessingTable FP
		INNER JOIN IncentiveLevelValue ILV ON ILV.GUIDReference = FP.PanelistIncentiveLevel_Id
			AND ILV.Incentive_Id = FP.IncentiveGUID
			AND ILV.Country_Id = @pCountryId
		LEFT OUTER JOIN IncentiveLevel IL ON IL.GUIDReference = ILV.IncentiveLevel_Id
			AND IL.Country_Id = @pCountryId
		LEFT OUTER JOIN IncentivePoint IP ON IP.GUIDReference = ILV.Incentive_Id
			AND ip.[Type] = 'Incentive'
		) T
	WHERE T.ROWID = 1

	UPDATE FP
	SET FP.IncentiveLevelValue = tpl.IncentiveLevelValue
		,FP.IncentiveLevelValueCanOverride = tpl.IncentiveLevelValueCanOverride
		,FP.PanelistIncentiveLevel_Id_IsDefault = tpl.PanelistIncentiveLevel_Id_IsDefault
		,Points = tpl.Points
		,IncentiveGUID = tpl.IncentiveGUID
	FROM #FinalProcessingTable FP
	INNER JOIN #TempPl tpl ON FP.[Rownumber] = tpl.[Rownumber]

	/* CanApplyOperation Validation */
	IF EXISTS (
			SELECT 1
			FROM #FinalProcessingTable FP
			INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
				AND ip.[Type] = 'Incentive'
			WHERE FP.PanelGUID IS NOT NULL
				AND FP.PanelistGUID IS NOT NULL
				AND (
					FP.PanelistIncentiveLevel_Id_IsDefault = 1
					OR FP.IncentiveLevelValue IS NULL
					)
				AND (
					IP.HasUpdateableValue = 0
					AND FP.Points <> IP.Value
					)
				AND IncentiveType = 'OwnAccount'
			)
	BEGIN
		SET @Error = 1

		SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'Points'

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
			,'Points override can''t be applied at Row ' + CONVERT(VARCHAR, FP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,FP.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM #FinalProcessingTable FP
		INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
			AND ip.[Type] = 'Incentive'
		WHERE FP.PanelGUID IS NOT NULL
			AND FP.PanelistGUID IS NOT NULL
			AND (
				PanelistIncentiveLevel_Id_IsDefault = 1
				OR IncentiveLevelValue IS NULL
				)
			AND (
				IP.HasUpdateableValue = 0
				AND FP.Points <> IP.Value
				)
			AND IncentiveType = 'OwnAccount'
	END

	IF EXISTS (
			SELECT 1
			FROM #FinalProcessingTable FP
			INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
				AND ip.[Type] = 'Incentive'
			WHERE FP.PanelGUID IS NOT NULL
				AND FP.PanelistGUID IS NOT NULL
				AND (
					FP.PanelistIncentiveLevel_Id_IsDefault = 0
					OR FP.IncentiveLevelValue IS NOT NULL
					)
				AND (
					FP.IncentiveLevelValueCanOverride = 0
					AND FP.Points <> IP.Value
					)
				AND IncentiveType = 'OwnAccount'
			)
	BEGIN
		SET @Error = 1

		
		SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'Points'

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
			,'Points override can''t be applied in the incentive level  at Row ' + CONVERT(VARCHAR, FP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,FP.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM #FinalProcessingTable FP
		INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
			AND ip.[Type] = 'Incentive'
		WHERE FP.PanelGUID IS NOT NULL
			AND FP.PanelistGUID IS NOT NULL
			AND (
				FP.PanelistIncentiveLevel_Id_IsDefault = 0
				OR FP.IncentiveLevelValue IS NOT NULL
				)
			AND (
				FP.IncentiveLevelValueCanOverride = 0
				AND FP.Points <> IP.Value
				)
			AND IncentiveType = 'OwnAccount'
	END

	IF EXISTS (
			SELECT 1
			FROM #FinalProcessingTable FP
			INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
				AND ip.[Type] = 'Incentive'
			WHERE (
					FP.PanelGUID IS NULL
					OR FP.PanelistGUID IS NULL
					)
				AND IP.HasUpdateableValue = 0
				AND FP.Points <> IP.Value
			)
	BEGIN
		SET @Error = 1

		
		SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'Points'

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
			,'Points override can''t be applied  at Row ' + CONVERT(VARCHAR, FP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,FP.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM #FinalProcessingTable FP
		INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
			AND ip.[Type] = 'Incentive'
		WHERE (
				FP.PanelGUID IS NULL
				OR FP.PanelistGUID IS NULL
				)
			AND IP.HasUpdateableValue = 0
			AND FP.Points <> IP.Value
	END

	IF EXISTS (
			SELECT 1
			FROM #FinalProcessingTable FP
			INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
				AND ip.[Type] = 'Incentive'
			WHERE IncentiveType = 'OwnAccount'
				AND (
					FP.Points < ISNULL(IP.Minimum, - 2147483647)
					OR FP.Points > ISNULL(IP.Maximum, 2147483647)
					)
			)
	BEGIN
		SET @Error = 1
		SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'Points'
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
			,'Points are not in range Minimum to Maximum at Row ' + CONVERT(VARCHAR, FP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,FP.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM #FinalProcessingTable FP
		INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
			AND ip.[Type] = 'Incentive'
		WHERE IncentiveType = 'OwnAccount'
			AND (
				FP.Points < ISNULL(IP.Minimum, - 2147483647)
				OR FP.Points > ISNULL(IP.Maximum, 2147483647)
				)
	END

	IF EXISTS (
			SELECT 1
			FROM #FinalProcessingTable FP
			INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
				AND ip.[Type] = 'Incentive'
			WHERE IncentiveType = 'OwnAccount'
				AND (
					(
						IP.ValidFrom IS NOT NULL
						AND IP.ValidFrom >= FP.[TransactionDate]
						)
					OR (
						IP.ValidTo IS NOT NULL
						AND IP.ValidTo <= FP.[TransactionDate]
						)
					)
			)
	BEGIN
		SET @Error = 1
		SELECT @ColumnNumber = RowNumber
			FROM @pColumn
			WHERE [ColumnName] = 'TransactionDate'
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
			,'Invalid TransactionDate (not in Range) at Row ' + CONVERT(VARCHAR, FP.Rownumber+1) + ' and column ' + CONVERT(VARCHAR, @ColumnNumber)
			,@GetDate
			,FP.[FullRow]
			,@REPETSEPARATOER
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM #FinalProcessingTable FP
		INNER JOIN IncentivePoint IP ON GUIDReference = FP.IncentiveGUID
			AND ip.[Type] = 'Incentive'
		WHERE IncentiveType = 'OwnAccount'
			AND (
				(
					IP.ValidFrom IS NOT NULL
					AND IP.ValidFrom >= FP.[TransactionDate]
					)
				OR (
					IP.ValidTo IS NOT NULL
					AND IP.ValidTo <= FP.[TransactionDate]
					)
				)
	END

	IF (@Error > 0)
	BEGIN
		EXEC InsertImportFile 'ImportFileError'
			,@pUser
			,@pFileId
			,@pCountryId
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION

		BEGIN TRY
			INSERT INTO [dbo].[IncentiveAccountTransactionInfo] (
				IncentiveAccountTransactionInfoId
				,Ammount
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,GiftPrice
				,Discriminator
				,Point_Id
				,RewardDeliveryType_Id
				,Country_Id
				)
			SELECT IncentiveInfoGuid
				,Points
				,GpsUser
				,@GetDate
				,@GetDate
				,NULL
				,'TransactionInfo'
				,IncentiveGUID
				,NULL
				,@pCountryId
			FROM #FinalProcessingTable

			IF OBJECT_ID('tempdb..#AccountPointsTable') IS NOT NULL
				DROP TABLE #AccountPointsTable

			CREATE TABLE #AccountPointsTable (
				Account_Id UNIQUEIDENTIFIER
				,Ponts BIGINT
				)

			INSERT INTO #AccountPointsTable (
				Account_Id
				,Ponts
				)
			SELECT Account_Id
				,ISNULL([Credit], 0) - ISNULL([Debit], 0)
			FROM (
				SELECT IAT.Account_Id
					,[Type]
					,SUM(Points) AS Points
				FROM #FinalProcessingTable FPT
				INNER JOIN [dbo].[IncentiveAccountTransaction] IAT ON IAT.Account_Id = FPT.IncentiveAccountId
				GROUP BY IAT.Account_Id
					,[Type]
				) AS SourceTable
			PIVOT(AVG(Points) FOR [Type] IN (
						[Credit]
						,[Debit]
						)) AS PivotTable;

			DECLARE @BatchId BIGINT = (
					SELECT ISNULL(MAX(BatchId), 0) + 1
					FROM [IncentiveAccountTransaction]
					)

			INSERT INTO [dbo].[IncentiveAccountTransaction] (
				IncentiveAccountTransactionId
				,CreationDate
				,SynchronisationDate
				,TransactionDate
				,Comments
				,Balance
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,PackageId
				,TransactionInfo_Id
				,TransactionSource_Id
				,Depositor_Id
				,Panel_Id
				,DeliveryAddress_Id
				,Account_Id
				,[Type]
				,Country_Id
				,GiftPrice
				,CostPrice
				,ProviderExtractionDate
				,BatchId
				,TransactionId
				)
			SELECT NEWID() AS IncentiveAccountTransactionId
				,@GetDate AS CreationDate
				,FPT.SynchronisationDate AS SynchronisationDate
				,FPT.TransactionDate AS TransactionDate
				,FPT.Comments AS Comments
				,(ISNULL(APT.Ponts, 0) + ISNULL(FPT.Points, 0)) AS Balance
				,FPT.GPSUser AS GPSUser
				,@GetDate AS GPSUpdateTimestamp
				,@GetDate AS CreationTimeStamp
				,NULL AS PackageId
				,FPT.IncentiveInfoGuid AS TransactionInfo_Id
				,FPT.TransactionSourceId AS TransactionSource_Id
				,FPT.Depositor_Id AS Depositor_Id
				,FPT.PanelGUID AS Panel_Id
				,NULL AS DeliveryAddress_Id
				,FPT.IncentiveAccountId AS Account_Id
				,'Credit' AS [Type]
				,@pCountryId
				,NULL
				,NULL
				,NULL
				,@BatchId
				,ROW_NUMBER() OVER (
					ORDER BY TransactionDate
					)
			FROM #FinalProcessingTable FPT
			LEFT OUTER JOIN #AccountPointsTable APT ON APT.Account_Id = FPT.IncentiveAccountId

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
				,'IncentiveTransactions Imported  successfully'
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pImportFeed Feed

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SELECT ERROR_MESSAGE()
				,ERROR_LINE()

			ROLLBACK TRANSACTION

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
END
