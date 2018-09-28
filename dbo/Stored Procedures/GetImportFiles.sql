/*##########################################################################
-- Name				: GetImportAudit
-- Date             : 2015-07-03
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
-- Sample Execution :
				set statistics time on;
				declare @p8 dbo.GridParametersTable
				--insert into @p8 values(N'BusinessId',N'0001-01',N'IsNotEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'CreationTimeStamp',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
				--insert into @p8 values(N'ImportDate',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
				--insert into @p8 values(N'Points',N'100',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'FileName',N'Indivs 2013.12.10.xls',N'IsNotEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'FileName',N'Points - CSV - RS',N'IsEqualTo',NULL,NULL,NULL)
				insert into @p8 values(N'FormatName',N'051',N'Contains',NULL,NULL,NULL)
				--insert into @p8 values(N'FormatName',N'Points - CSV - RS',N'IsNotEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'GPSUser',N'ShahR',N'IsNotEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'Status',N'Pending',N'IsEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'Status',N'Pending',N'IsNotEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'HasPendingRecords','1',N'IsNotEqualTo',NULL,NULL,NULL)
				--exec GetImportFiles '17D348D8-A08D-CE7A-CB8C-08CF81794A86',2057,'GPSUser','ASC',1,100,0,@p8
				exec GetImportFiles '17D348D8-A08D-CE7A-CB8C-08CF81794A86',2057,'FormatName','desc',1,100,0,@p8
##########################################################################
-- version  user						date        change 
-- 1.0  Jagadeesh Boddu				  2015-07-03   Initial
-- 2.0  Jagadeesh Boddu				  2015-10-29   Changed for Performance  
##########################################################################*/
CREATE PROCEDURE GetImportFiles (
	@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT = 2057
	,@pCurrentUserName VARCHAR(100)
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10)
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @op1 VARCHAR(50)
	DECLARE @Secondopop1 VARCHAR(50)
	DECLARE @LogicalOperator1 VARCHAR(50)
	DECLARE @op2 VARCHAR(50)
	DECLARE @op3 VARCHAR(50)
	DECLARE @Secondopop3 VARCHAR(50)
	DECLARE @LogicalOperator3 VARCHAR(50)
	DECLARE @op4 VARCHAR(3999)
	DECLARE @op5 VARCHAR(3999)
	DECLARE @op6 VARCHAR(3999)
	DECLARE @op7 VARCHAR(3999)
	DECLARE @CreatedDate DATETIME
	DECLARE @SecondCreatedDate DATETIME
	DECLARE @GPSUser VARCHAR(256)
	DECLARE @ImportDate DATETIME
	DECLARE @SecondImportDate DATETIME
	DECLARE @FileName NVARCHAR(Max)
	DECLARE @FormatName NVARCHAR(2000)
	DECLARE @Status NVARCHAR(2000)
	DECLARE @HasPendingRecords BIT

	SELECT @op1 = Opertor
		,@CreatedDate = CAST(ParameterValue AS DATETIME)
		,@Secondopop1 = SecondParameterOperator
		,@SecondCreatedDate = CAST(SecondParameterValue AS DATETIME)
		,@LogicalOperator1 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'CreationTimeStamp'

	SELECT @op2 = Opertor
		,@GPSUser = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'GPSUser'

	SELECT @op3 = Opertor
		,@ImportDate = CAST(ParameterValue AS DATETIME)
		,@Secondopop3 = SecondParameterOperator
		,@SecondImportDate = CAST(SecondParameterValue AS DATETIME)
		,@LogicalOperator3 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'ImportDate'

	SELECT @op4 = Opertor
		,@FileName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'FileName'

	SELECT @op5 = Opertor
		,@FormatName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'FormatName'

	SELECT @op6 = Opertor
		,@Status = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Status'

	SELECT @op7 = Opertor
		,@HasPendingRecords = CAST(ParameterValue AS BIT)
	FROM @pParametersTable
	WHERE ParameterName = 'HasPendingRecords'

	DECLARE @ImportDateVarchar VARCHAR(100) = CAST(@ImportDate AS VARCHAR)
		,@SecondImportDateVarchar VARCHAR(100) = CAST(@SecondImportDate AS VARCHAR)
	DECLARE @CreatedDateVarchar VARCHAR(100) = CAST(@CreatedDate AS VARCHAR)
		,@SecondCreatedDateVarchar VARCHAR(100) = CAST(@SecondCreatedDate AS VARCHAR)
	DECLARE @WhereParameter VARCHAR(MAX)
		,@pOrderByParameter VARCHAR(MAX) = NULL
	DECLARE @ImportFilesAsPerRoles Table(TranslationKeyName VARCHAR(200))
	DECLARE @OFFSETRows INT = 0
	DECLARE @IsLessThan VARCHAR(50) = 'IsLessThan'
		,@IsLessThanOrEqualTo VARCHAR(50) = 'IsLessThanOrEqualTo'
		,@IsEqualTo VARCHAR(50) = 'IsEqualTo'
		,@IsNotEqualTo VARCHAR(50) = 'IsNotEqualTo'
		,@IsGreaterThanOrEqualTo VARCHAR(50) = 'IsGreaterThanOrEqualTo'
		,@IsGreaterThan VARCHAR(50) = 'IsGreaterThan'
		,@StartsWith VARCHAR(50) = 'StartsWith'
		,@EndsWith VARCHAR(50) = 'EndsWith'
		,@Contains VARCHAR(50) = 'Contains'
		,@IsContainedIn VARCHAR(50) = 'IsContainedIn'
		,@DoesNotContain VARCHAR(50) = 'DoesNotContain'
	
	DECLARE @COUNTRYCONTEXTNAME VARCHAR(100)
	SELECT @COUNTRYCONTEXTNAME='Country' + CountryISO2A FROM COUNTRY WHERE CountryId=@pCountryId

	INSERT INTO @ImportFilesAsPerRoles(TranslationKeyName)
	SELECT DISTINCT T.KEYNAME AS Name
	FROM IDENTITYUSER IU
	JOIN SYSTEMUSERROLE SUR ON IU.Id = SUR.IDENTITYUSERID
		AND SUR.CountryId = @pCountryId
	JOIN AccessRights AR ON SUR.SystemRoleTypeId = AR.SystemRoleTypeId
	INNER JOIN AccessContext AC ON AC.AccessContextId = AR.AccessContextId
	INNER JOIN RestrictedAccessArea RA ON RA.RestrictedAccessAreaId = AR.RestrictedAccessAreaId
	INNER JOIN RestrictedAccessAreaSubType RST ON RA.RestrictedAccessAreaTypeId = RST.RestrictedAccessAreaTypeId
	INNER JOIN RestrictedAccessSystemArea RASA ON RASA.RestrictedAccessAreaId = RA.RestrictedAccessAreaId
		AND RA.RestrictedAccessAreaSubTypeId = RST.RestrictedAccessAreaSubTypeId
	JOIN TRANSLATIONTERM TT ON RASA.NAME = TT.VALUE
		AND TT.CULTURECODE = 2057
	JOIN TRANSLATION T ON TT.TRANSLATION_ID = T.TRANSLATIONID
	WHERE IU.USERNAME = @pCurrentUserName
		AND RST.Description = 'System - Import'
		AND AR.IsPermissionGranted = 1
		AND AC.[Description]=@COUNTRYCONTEXTNAME

	IF (@pOrderBy IS NULL)
	BEGIN
		SET @pOrderBy = 'CreationTimeStamp'
	END

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'desc'

	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 15000;

	

	IF (@pIsExport = 0)
	BEGIN
		SELECT count(0) AS TotlaRows
		FROM (
			SELECT imfile.GUIDReference AS Id
				,imfile.GPSUser
				,isnull(imftr.value, '{' + imft.KeyName + '}') AS FormatName
				,1 AS IsRetryEnabled
				,imfile.[Date] AS ImportDate
				,imfile.NAME AS [FileName]
				,IIF(count(ifprsd.Id) > 0, 1, 0) AS HasPendingRecords
				,isnull(imfilesdtr.value, '{' + imfilesdt.KeyName + '}') AS [Status]
				,IIF(imfilesd.id IS NOT NULL
					AND imfilesd.Code = 'ImportFileAlreadyUploaded', 1, 0) AS IsAlreadyUploaded
				,imfile.CreationTimeStamp
				,imfile.Country_Id
				,imft.TranslationId
				,imft.KeyName AS [Key]
				,IMF.ImportDefinitionTypeName AS [ImportDefinitionTypeName]
			FROM ImportFile imfile
			INNER JOIN importformat imf ON imf.GUIDReference = imfile.ImportFormat_Id
			INNER JOIN @ImportFilesAsPerRoles IFAPF ON imf.ImportDefinitionTypeName=IFAPF.TranslationKeyName
			LEFT OUTER JOIN StateDefinition imfilesd ON imfilesd.id = imfile.State_Id
			LEFT OUTER JOIN translation imfilesdt ON imfilesdt.TranslationId = imfilesd.Label_Id
			LEFT OUTER JOIN translationterm imfilesdtr ON imfilesdtr.Translation_Id = imfilesdt.TranslationId
				AND imfilesdtr.CultureCode = 2057
			INNER JOIN translation imft ON imft.TranslationId = imf.Description_Id
			LEFT OUTER JOIN translationterm imftr ON imftr.Translation_Id = imft.TranslationId
				AND imftr.CultureCode = @pCultureCode
			LEFT OUTER JOIN ImportFilePendingRecord ifpr ON ifpr.[File_Id] = imfile.GUIDReference
			LEFT OUTER JOIN StateDefinition ifprsd ON ifprsd.id = ifpr.State_Id
				AND ifprsd.code <> 'PendingRecordSuccess'
				AND ifprsd.code <> 'PendingRecordError'
			WHERE imfile.Country_Id = @pCountryId
			GROUP BY imfile.GUIDReference
				,imfile.CreationTimeStamp
				,imfile.GPSUser
				,isnull(imftr.value, '{' + imft.KeyName + '}')
				,imfile.[Date]
				,imfile.NAME
				,isnull(imfilesdtr.value, '{' + imfilesdt.KeyName + '}')
				,IIF(imfilesd.id IS NOT NULL
					AND imfilesd.Code = 'ImportFileAlreadyUploaded', 1, 0)
				,imfile.Country_Id
				,imft.TranslationId
				,imft.KeyName
				,IMF.ImportDefinitionTypeName
			) t
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 IS NULL
					AND @LogicalOperator1 IS NULL
					)
				OR (
					@LogicalOperator1 = 'OR'
					AND (
						(
							(
								@op1 = @IsEqualTo
								AND [CreationTimeStamp] = @CreatedDate
								)
							OR (
								@op1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @CreatedDate
								)
							OR (
								@op1 = @IsLessThan
								AND [CreationTimeStamp] < @CreatedDate
								)
							OR (
								@op1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] >= @CreatedDate
								)
							OR (
								@op1 = @IsGreaterThan
								AND [CreationTimeStamp] > @CreatedDate
								)
							OR (
								@op1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @CreatedDate
								)
							OR (
								@op1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @CreatedDateVarchar + '%'
								)
							OR (
								@op1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + ''
								)
							)
						OR (
							(
								@Secondopop1 = @IsEqualTo
								AND [CreationTimeStamp] = @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsLessThan
								AND [CreationTimeStamp] < @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] <= @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsGreaterThan
								AND [CreationTimeStamp] > @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @SecondCreatedDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @SecondCreatedDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator1 = 'AND'
					AND (
						(
							(
								@op1 = @IsEqualTo
								AND [CreationTimeStamp] = @CreatedDate
								)
							OR (
								@op1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @CreatedDate
								)
							OR (
								@op1 = @IsLessThan
								AND [CreationTimeStamp] < @CreatedDate
								)
							OR (
								@op1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] >= @CreatedDate
								)
							OR (
								@op1 = @IsGreaterThan
								AND [CreationTimeStamp] > @CreatedDate
								)
							OR (
								@op1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @CreatedDate
								)
							OR (
								@op1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @CreatedDateVarchar + '%'
								)
							OR (
								@op1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + ''
								)
							)
						AND (
							(
								@Secondopop1 = @IsEqualTo
								AND [CreationTimeStamp] = @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsLessThan
								AND [CreationTimeStamp] < @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] <= @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsGreaterThan
								AND [CreationTimeStamp] > @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @SecondCreatedDate
								)
							OR (
								@Secondopop1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @SecondCreatedDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @SecondCreatedDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + ''
								)
							)
						)
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND GPSUser = @GPSUser
					)
				OR (
					@op2 = @IsNotEqualTo
					AND GPSUser <> @GPSUser
					)
				OR (
					@op2 = @IsLessThan
					AND GPSUser < @GPSUser
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND GPSUser >= @GPSUser
					)
				OR (
					@op2 = @IsGreaterThan
					AND GPSUser > @GPSUser
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND GPSUser >= @GPSUser
					)
				OR (
					@op2 = @Contains
					AND GPSUser LIKE '%' + @GPSUser + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND GPSUser NOT LIKE '%' + @GPSUser + '%'
					)
				OR (
					@op2 = @StartsWith
					AND GPSUser LIKE '' + @GPSUser + '%'
					)
				OR (
					@op2 = @EndsWith
					AND GPSUser LIKE '%' + @GPSUser + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 IS NULL
					AND @LogicalOperator3 IS NULL
					)
				OR (
					@LogicalOperator3 = 'OR'
					AND (
						(
							(
								@op3 = @IsEqualTo
								AND [ImportDate] = @ImportDate
								)
							OR (
								@op3 = @IsNotEqualTo
								AND [ImportDate] <> @ImportDate
								)
							OR (
								@op3 = @IsLessThan
								AND [ImportDate] < @ImportDate
								)
							OR (
								@op3 = @IsLessThanOrEqualTo
								AND [ImportDate] >= @ImportDate
								)
							OR (
								@op3 = @IsGreaterThan
								AND [ImportDate] > @ImportDate
								)
							OR (
								@op3 = @IsGreaterThanOrEqualTo
								AND [ImportDate] >= @ImportDate
								)
							OR (
								@op3 = @Contains
								AND [ImportDate] LIKE '%' + @ImportDateVarchar + '%'
								)
							OR (
								@op3 = @DoesNotContain
								AND [ImportDate] NOT LIKE '%' + @ImportDateVarchar + '%'
								)
							OR (
								@op3 = @StartsWith
								AND [ImportDate] LIKE '' + @ImportDateVarchar + '%'
								)
							OR (
								@op3 = @EndsWith
								AND [ImportDate] LIKE '%' + @ImportDateVarchar + ''
								)
							)
						OR (
							(
								@Secondopop3 = @IsEqualTo
								AND [ImportDate] = @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsNotEqualTo
								AND [ImportDate] <> @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsLessThan
								AND [ImportDate] < @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsLessThanOrEqualTo
								AND [ImportDate] <= @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsGreaterThan
								AND [ImportDate] > @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsGreaterThanOrEqualTo
								AND [ImportDate] >= @SecondImportDate
								)
							OR (
								@Secondopop3 = @Contains
								AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + '%'
								)
							OR (
								@Secondopop3 = @DoesNotContain
								AND [ImportDate] NOT LIKE '%' + @SecondImportDateVarchar + '%'
								)
							OR (
								@Secondopop3 = @StartsWith
								AND [ImportDate] LIKE '' + @SecondImportDateVarchar + '%'
								)
							OR (
								@Secondopop3 = @EndsWith
								AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator3 = 'AND'
					AND (
						(
							(
								@op3 = @IsEqualTo
								AND [ImportDate] = @ImportDate
								)
							OR (
								@op3 = @IsNotEqualTo
								AND [ImportDate] <> @ImportDate
								)
							OR (
								@op3 = @IsLessThan
								AND [ImportDate] < @ImportDate
								)
							OR (
								@op3 = @IsLessThanOrEqualTo
								AND [ImportDate] >= @ImportDate
								)
							OR (
								@op3 = @IsGreaterThan
								AND [ImportDate] > @ImportDate
								)
							OR (
								@op3 = @IsGreaterThanOrEqualTo
								AND [ImportDate] >= @ImportDate
								)
							OR (
								@op3 = @Contains
								AND [ImportDate] LIKE '%' + @ImportDateVarchar + '%'
								)
							OR (
								@op3 = @DoesNotContain
								AND [ImportDate] NOT LIKE '%' + @ImportDateVarchar + '%'
								)
							OR (
								@op3 = @StartsWith
								AND [ImportDate] LIKE '' + @ImportDateVarchar + '%'
								)
							OR (
								@op3 = @EndsWith
								AND [ImportDate] LIKE '%' + @ImportDateVarchar + ''
								)
							)
						AND (
							(
								@Secondopop3 = @IsEqualTo
								AND [ImportDate] = @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsNotEqualTo
								AND [ImportDate] <> @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsLessThan
								AND [ImportDate] < @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsLessThanOrEqualTo
								AND [ImportDate] <= @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsGreaterThan
								AND [ImportDate] > @SecondImportDate
								)
							OR (
								@Secondopop3 = @IsGreaterThanOrEqualTo
								AND [ImportDate] >= @SecondImportDate
								)
							OR (
								@Secondopop3 = @Contains
								AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + '%'
								)
							OR (
								@Secondopop3 = @DoesNotContain
								AND [ImportDate] NOT LIKE '%' + @SecondImportDateVarchar + '%'
								)
							OR (
								@Secondopop3 = @StartsWith
								AND [ImportDate] LIKE '' + @SecondImportDateVarchar + '%'
								)
							OR (
								@Secondopop3 = @EndsWith
								AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + ''
								)
							)
						)
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND [FileName] = @FileName
					)
				OR (
					@op4 = @IsNotEqualTo
					AND [FileName] <> @FileName
					)
				OR (
					@op4 = @IsLessThan
					AND [FileName] < @FileName
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND [FileName] >= @FileName
					)
				OR (
					@op4 = @IsGreaterThan
					AND [FileName] > @FileName
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND [FileName] >= @FileName
					)
				OR (
					@op4 = @Contains
					AND [FileName] LIKE '%' + @FileName + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND [FileName] NOT LIKE '%' + @FileName + '%'
					)
				OR (
					@op4 = @StartsWith
					AND [FileName] LIKE '' + @FileName + '%'
					)
				OR (
					@op4 = @EndsWith
					AND [FileName] LIKE '%' + @FileName + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND FormatName = @FormatName
					)
				OR (
					@op5 = @IsNotEqualTo
					AND FormatName <> @FormatName
					)
				OR (
					@op5 = @IsLessThan
					AND FormatName < @FormatName
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND FormatName >= @FormatName
					)
				OR (
					@op5 = @IsGreaterThan
					AND FormatName > @FormatName
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND FormatName >= @FormatName
					)
				OR (
					@op5 = @Contains
					AND FormatName LIKE '%' + @FormatName + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND FormatName NOT LIKE '%' + @FormatName + '%'
					)
				OR (
					@op5 = @StartsWith
					AND FormatName LIKE '' + @FormatName + '%'
					)
				OR (
					@op5 = @EndsWith
					AND FormatName LIKE '%' + @FormatName + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND [Status] = @Status
					)
				OR (
					@op6 = @IsNotEqualTo
					AND [Status] <> @Status
					)
				OR (
					@op6 = @IsLessThan
					AND [Status] < @Status
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND [Status] >= @Status
					)
				OR (
					@op6 = @IsGreaterThan
					AND [Status] > @Status
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND [Status] >= @Status
					)
				OR (
					@op6 = @Contains
					AND [Status] LIKE '%' + @Status + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND [Status] NOT LIKE '%' + @Status + '%'
					)
				OR (
					@op6 = @StartsWith
					AND [Status] LIKE '' + @Status + '%'
					)
				OR (
					@op6 = @EndsWith
					AND [Status] LIKE '%' + @Status + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND HasPendingRecords = @HasPendingRecords
					)
				OR (
					@op7 = @IsNotEqualTo
					AND HasPendingRecords <> @HasPendingRecords
					)
				OR (
					@op7 = @IsLessThan
					AND HasPendingRecords < @HasPendingRecords
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND HasPendingRecords >= @HasPendingRecords
					)
				OR (
					@op7 = @IsGreaterThan
					AND HasPendingRecords > @HasPendingRecords
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND HasPendingRecords >= @HasPendingRecords
					)
				)
	END

	SELECT Id
		,GPSUser
		,FormatName
		,IsRetryEnabled
		,ImportDate
		,isnull([FileName], 50) AS [FileName]
		,HasPendingRecords
		,[Status]
		,IsAlreadyUploaded
		,CreationTimeStamp
		,Country_Id
		,TranslationId AS Id
		,[Key]
		,ImportDefinitionTypeName
	FROM (
		SELECT imfile.GUIDReference AS Id
			,imfile.GPSUser
			,isnull(imftr.value, '{' + imft.KeyName + '}') AS FormatName
			,1 AS IsRetryEnabled
			,imfile.[Date] AS ImportDate
			,imfile.NAME AS [FileName]
			,IIF(count(ifprsd.Id) > 0, 1, 0) AS HasPendingRecords
			,isnull(imfilesdtr.value, '{' + imfilesdt.KeyName + '}') AS [Status]
			,IIF(imfilesd.id IS NOT NULL
				AND imfilesd.Code = 'ImportFileAlreadyUploaded', 1, 0) AS IsAlreadyUploaded
			,imfile.CreationTimeStamp
			,imfile.Country_Id
			,imft.TranslationId
			,imft.KeyName AS [Key]
			,IMF.ImportDefinitionTypeName AS [ImportDefinitionTypeName]
		FROM ImportFile imfile
		INNER JOIN importformat imf ON imf.GUIDReference = imfile.ImportFormat_Id
		INNER JOIN @ImportFilesAsPerRoles IFAPF ON imf.ImportDefinitionTypeName=IFAPF.TranslationKeyName
		LEFT OUTER JOIN StateDefinition imfilesd ON imfilesd.id = imfile.State_Id
		LEFT OUTER JOIN translation imfilesdt ON imfilesdt.TranslationId = imfilesd.Label_Id
		LEFT OUTER JOIN translationterm imfilesdtr ON imfilesdtr.Translation_Id = imfilesdt.TranslationId
			AND imfilesdtr.CultureCode = 2057
		INNER JOIN translation imft ON imft.TranslationId = imf.Description_Id
		LEFT OUTER JOIN translationterm imftr ON imftr.Translation_Id = imft.TranslationId
			AND imftr.CultureCode = @pCultureCode
		LEFT OUTER JOIN ImportFilePendingRecord ifpr ON ifpr.[File_Id] = imfile.GUIDReference
		LEFT OUTER JOIN StateDefinition ifprsd ON ifprsd.id = ifpr.State_Id
			AND ifprsd.code <> 'PendingRecordSuccess'
			AND ifprsd.code <> 'PendingRecordError'
		WHERE imfile.Country_Id = @pCountryId
		GROUP BY imfile.GUIDReference
			,imfile.CreationTimeStamp
			,imfile.GPSUser
			,isnull(imftr.value, '{' + imft.KeyName + '}')
			,imfile.[Date]
			,imfile.NAME
			,isnull(imfilesdtr.value, '{' + imfilesdt.KeyName + '}')
			,IIF(imfilesd.id IS NOT NULL
				AND imfilesd.Code = 'ImportFileAlreadyUploaded', 1, 0)
			,imfile.Country_Id
			,imft.TranslationId
			,imft.KeyName
			,IMF.ImportDefinitionTypeName
		) t
	WHERE (
			(@op1 IS NULL)
			OR (
				@op1 IS NULL
				AND @LogicalOperator1 IS NULL
				)
			OR (
				@LogicalOperator1 = 'OR'
				AND (
					(
						(
							@op1 = @IsEqualTo
							AND [CreationTimeStamp] = @CreatedDate
							)
						OR (
							@op1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @CreatedDate
							)
						OR (
							@op1 = @IsLessThan
							AND [CreationTimeStamp] < @CreatedDate
							)
						OR (
							@op1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] >= @CreatedDate
							)
						OR (
							@op1 = @IsGreaterThan
							AND [CreationTimeStamp] > @CreatedDate
							)
						OR (
							@op1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @CreatedDate
							)
						OR (
							@op1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @CreatedDateVarchar + '%'
							)
						OR (
							@op1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + ''
							)
						)
					OR (
						(
							@Secondopop1 = @IsEqualTo
							AND [CreationTimeStamp] = @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsLessThan
							AND [CreationTimeStamp] < @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] <= @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsGreaterThan
							AND [CreationTimeStamp] > @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + '%'
							)
						OR (
							@Secondopop1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @SecondCreatedDateVarchar + '%'
							)
						OR (
							@Secondopop1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @SecondCreatedDateVarchar + '%'
							)
						OR (
							@Secondopop1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator1 = 'AND'
				AND (
					(
						(
							@op1 = @IsEqualTo
							AND [CreationTimeStamp] = @CreatedDate
							)
						OR (
							@op1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @CreatedDate
							)
						OR (
							@op1 = @IsLessThan
							AND [CreationTimeStamp] < @CreatedDate
							)
						OR (
							@op1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] >= @CreatedDate
							)
						OR (
							@op1 = @IsGreaterThan
							AND [CreationTimeStamp] > @CreatedDate
							)
						OR (
							@op1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @CreatedDate
							)
						OR (
							@op1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @CreatedDateVarchar + '%'
							)
						OR (
							@op1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @CreatedDateVarchar + ''
							)
						)
					AND (
						(
							@Secondopop1 = @IsEqualTo
							AND [CreationTimeStamp] = @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsLessThan
							AND [CreationTimeStamp] < @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] <= @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsGreaterThan
							AND [CreationTimeStamp] > @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @SecondCreatedDate
							)
						OR (
							@Secondopop1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + '%'
							)
						OR (
							@Secondopop1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @SecondCreatedDateVarchar + '%'
							)
						OR (
							@Secondopop1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @SecondCreatedDateVarchar + '%'
							)
						OR (
							@Secondopop1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @SecondCreatedDateVarchar + ''
							)
						)
					)
				)
			)
		AND (
			(@op2 IS NULL)
			OR (
				@op2 = @IsEqualTo
				AND GPSUser = @GPSUser
				)
			OR (
				@op2 = @IsNotEqualTo
				AND GPSUser <> @GPSUser
				)
			OR (
				@op2 = @IsLessThan
				AND GPSUser < @GPSUser
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND GPSUser >= @GPSUser
				)
			OR (
				@op2 = @IsGreaterThan
				AND GPSUser > @GPSUser
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND GPSUser >= @GPSUser
				)
			OR (
				@op2 = @Contains
				AND GPSUser LIKE '%' + @GPSUser + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND GPSUser NOT LIKE '%' + @GPSUser + '%'
				)
			OR (
				@op2 = @StartsWith
				AND GPSUser LIKE '' + @GPSUser + '%'
				)
			OR (
				@op2 = @EndsWith
				AND GPSUser LIKE '%' + @GPSUser + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 IS NULL
				AND @LogicalOperator3 IS NULL
				)
			OR (
				@LogicalOperator3 = 'OR'
				AND (
					(
						(
							@op3 = @IsEqualTo
							AND [ImportDate] = @ImportDate
							)
						OR (
							@op3 = @IsNotEqualTo
							AND [ImportDate] <> @ImportDate
							)
						OR (
							@op3 = @IsLessThan
							AND [ImportDate] < @ImportDate
							)
						OR (
							@op3 = @IsLessThanOrEqualTo
							AND [ImportDate] >= @ImportDate
							)
						OR (
							@op3 = @IsGreaterThan
							AND [ImportDate] > @ImportDate
							)
						OR (
							@op3 = @IsGreaterThanOrEqualTo
							AND [ImportDate] >= @ImportDate
							)
						OR (
							@op3 = @Contains
							AND [ImportDate] LIKE '%' + @ImportDateVarchar + '%'
							)
						OR (
							@op3 = @DoesNotContain
							AND [ImportDate] NOT LIKE '%' + @ImportDateVarchar + '%'
							)
						OR (
							@op3 = @StartsWith
							AND [ImportDate] LIKE '' + @ImportDateVarchar + '%'
							)
						OR (
							@op3 = @EndsWith
							AND [ImportDate] LIKE '%' + @ImportDateVarchar + ''
							)
						)
					OR (
						(
							@Secondopop3 = @IsEqualTo
							AND [ImportDate] = @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsNotEqualTo
							AND [ImportDate] <> @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsLessThan
							AND [ImportDate] < @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsLessThanOrEqualTo
							AND [ImportDate] <= @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsGreaterThan
							AND [ImportDate] > @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsGreaterThanOrEqualTo
							AND [ImportDate] >= @SecondImportDate
							)
						OR (
							@Secondopop3 = @Contains
							AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + '%'
							)
						OR (
							@Secondopop3 = @DoesNotContain
							AND [ImportDate] NOT LIKE '%' + @SecondImportDateVarchar + '%'
							)
						OR (
							@Secondopop3 = @StartsWith
							AND [ImportDate] LIKE '' + @SecondImportDateVarchar + '%'
							)
						OR (
							@Secondopop3 = @EndsWith
							AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator3 = 'AND'
				AND (
					(
						(
							@op3 = @IsEqualTo
							AND [ImportDate] = @ImportDate
							)
						OR (
							@op3 = @IsNotEqualTo
							AND [ImportDate] <> @ImportDate
							)
						OR (
							@op3 = @IsLessThan
							AND [ImportDate] < @ImportDate
							)
						OR (
							@op3 = @IsLessThanOrEqualTo
							AND [ImportDate] >= @ImportDate
							)
						OR (
							@op3 = @IsGreaterThan
							AND [ImportDate] > @ImportDate
							)
						OR (
							@op3 = @IsGreaterThanOrEqualTo
							AND [ImportDate] >= @ImportDate
							)
						OR (
							@op3 = @Contains
							AND [ImportDate] LIKE '%' + @ImportDateVarchar + '%'
							)
						OR (
							@op3 = @DoesNotContain
							AND [ImportDate] NOT LIKE '%' + @ImportDateVarchar + '%'
							)
						OR (
							@op3 = @StartsWith
							AND [ImportDate] LIKE '' + @ImportDateVarchar + '%'
							)
						OR (
							@op3 = @EndsWith
							AND [ImportDate] LIKE '%' + @ImportDateVarchar + ''
							)
						)
					AND (
						(
							@Secondopop3 = @IsEqualTo
							AND [ImportDate] = @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsNotEqualTo
							AND [ImportDate] <> @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsLessThan
							AND [ImportDate] < @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsLessThanOrEqualTo
							AND [ImportDate] <= @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsGreaterThan
							AND [ImportDate] > @SecondImportDate
							)
						OR (
							@Secondopop3 = @IsGreaterThanOrEqualTo
							AND [ImportDate] >= @SecondImportDate
							)
						OR (
							@Secondopop3 = @Contains
							AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + '%'
							)
						OR (
							@Secondopop3 = @DoesNotContain
							AND [ImportDate] NOT LIKE '%' + @SecondImportDateVarchar + '%'
							)
						OR (
							@Secondopop3 = @StartsWith
							AND [ImportDate] LIKE '' + @SecondImportDateVarchar + '%'
							)
						OR (
							@Secondopop3 = @EndsWith
							AND [ImportDate] LIKE '%' + @SecondImportDateVarchar + ''
							)
						)
					)
				)
			)
		AND (
			(@op4 IS NULL)
			OR (
				@op4 = @IsEqualTo
				AND [FileName] = @FileName
				)
			OR (
				@op4 = @IsNotEqualTo
				AND [FileName] <> @FileName
				)
			OR (
				@op4 = @IsLessThan
				AND [FileName] < @FileName
				)
			OR (
				@op4 = @IsLessThanOrEqualTo
				AND [FileName] >= @FileName
				)
			OR (
				@op4 = @IsGreaterThan
				AND [FileName] > @FileName
				)
			OR (
				@op4 = @IsGreaterThanOrEqualTo
				AND [FileName] >= @FileName
				)
			OR (
				@op4 = @Contains
				AND [FileName] LIKE '%' + @FileName + '%'
				)
			OR (
				@op4 = @DoesNotContain
				AND [FileName] NOT LIKE '%' + @FileName + '%'
				)
			OR (
				@op4 = @StartsWith
				AND [FileName] LIKE '' + @FileName + '%'
				)
			OR (
				@op4 = @EndsWith
				AND [FileName] LIKE '%' + @FileName + ''
				)
			)
		AND (
			(@op5 IS NULL)
			OR (
				@op5 = @IsEqualTo
				AND FormatName = @FormatName
				)
			OR (
				@op5 = @IsNotEqualTo
				AND FormatName <> @FormatName
				)
			OR (
				@op5 = @IsLessThan
				AND FormatName < @FormatName
				)
			OR (
				@op5 = @IsLessThanOrEqualTo
				AND FormatName >= @FormatName
				)
			OR (
				@op5 = @IsGreaterThan
				AND FormatName > @FormatName
				)
			OR (
				@op5 = @IsGreaterThanOrEqualTo
				AND FormatName >= @FormatName
				)
			OR (
				@op5 = @Contains
				AND FormatName LIKE '%' + @FormatName + '%'
				)
			OR (
				@op5 = @DoesNotContain
				AND FormatName NOT LIKE '%' + @FormatName + '%'
				)
			OR (
				@op5 = @StartsWith
				AND FormatName LIKE '' + @FormatName + '%'
				)
			OR (
				@op5 = @EndsWith
				AND FormatName LIKE '%' + @FormatName + ''
				)
			)
		AND (
			(@op6 IS NULL)
			OR (
				@op6 = @IsEqualTo
				AND [Status] = @Status
				)
			OR (
				@op6 = @IsNotEqualTo
				AND [Status] <> @Status
				)
			OR (
				@op6 = @IsLessThan
				AND [Status] < @Status
				)
			OR (
				@op6 = @IsLessThanOrEqualTo
				AND [Status] >= @Status
				)
			OR (
				@op6 = @IsGreaterThan
				AND [Status] > @Status
				)
			OR (
				@op6 = @IsGreaterThanOrEqualTo
				AND [Status] >= @Status
				)
			OR (
				@op6 = @Contains
				AND [Status] LIKE '%' + @Status + '%'
				)
			OR (
				@op6 = @DoesNotContain
				AND [Status] NOT LIKE '%' + @Status + '%'
				)
			OR (
				@op6 = @StartsWith
				AND [Status] LIKE '' + @Status + '%'
				)
			OR (
				@op6 = @EndsWith
				AND [Status] LIKE '%' + @Status + ''
				)
			)
		AND (
			(@op7 IS NULL)
			OR (
				@op7 = @IsEqualTo
				AND HasPendingRecords = @HasPendingRecords
				)
			OR (
				@op7 = @IsNotEqualTo
				AND HasPendingRecords <> @HasPendingRecords
				)
			OR (
				@op7 = @IsLessThan
				AND HasPendingRecords < @HasPendingRecords
				)
			OR (
				@op7 = @IsLessThanOrEqualTo
				AND HasPendingRecords >= @HasPendingRecords
				)
			OR (
				@op7 = @IsGreaterThan
				AND HasPendingRecords > @HasPendingRecords
				)
			OR (
				@op7 = @IsGreaterThanOrEqualTo
				AND HasPendingRecords >= @HasPendingRecords
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'CreationTimeStamp'
				AND @pOrderType = 'ASC'
				THEN CreationTimeStamp
			END ASC
		,CASE 
			WHEN @pOrderBy = 'CreationTimeStamp'
				AND @pOrderType = 'DESC'
				THEN CreationTimeStamp
			END DESC
		,CASE 
			WHEN @pOrderBy = 'GPSUser'
				AND @pOrderType = 'ASC'
				THEN GPSUser
			END ASC
		,CASE 
			WHEN @pOrderBy = 'GPSUser'
				AND @pOrderType = 'DESC'
				THEN GPSUser
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ImportDate'
				AND @pOrderType = 'ASC'
				THEN ImportDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ImportDate'
				AND @pOrderType = 'DESC'
				THEN ImportDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'FileName'
				AND @pOrderType = 'ASC'
				THEN [FileName]
			END ASC
		,CASE 
			WHEN @pOrderBy = 'FileName'
				AND @pOrderType = 'DESC'
				THEN [FileName]
			END DESC
		,CASE 
			WHEN @pOrderBy = 'FormatName'
				AND @pOrderType = 'ASC'
				THEN FormatName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'FormatName'
				AND @pOrderType = 'DESC'
				THEN FormatName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Status'
				AND @pOrderType = 'ASC'
				THEN [Status]
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Status'
				AND @pOrderType = 'DESC'
				THEN [Status]
			END DESC
		,CASE 
			WHEN @pOrderBy = 'HasPendingRecords'
				AND @pOrderType = 'ASC'
				THEN HasPendingRecords
			END ASC
		,CASE 
			WHEN @pOrderBy = 'HasPendingRecords'
				AND @pOrderType = 'DESC'
				THEN HasPendingRecords
			END DESC OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)
END
