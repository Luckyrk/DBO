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
				declare @p8 dbo.GridParametersTable
				--insert into @p8 values(N'BusinessId',N'0001-01',N'IsNotEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'CreationTimeStamp',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
				--insert into @p8 values(N'Points',N'100',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'DiaryDateFull',N'2006.7.4',N'IsEqualTo',NULL,NULL,NULL)
				--insert into @p8 values(N'BusinessId',N'10257901-01',N'IsEqualTo',NULL,NULL,NULL)
				exec GetImportAudit '17937f3f-ccd2-cd7a-342b-08d230023bdf',NULL,NULL,2,10,0,@p8
##########################################################################
-- version  user						date        change 
-- 1.0  Jagadeesh Boddu				  2015-07-03   Initial
-- 2.0  Jagadeesh Boddu				  2015-10-29   Changed for Performance  
##########################################################################*/
CREATE PROCEDURE GetImportAudit (
	@pImportFileId UNIQUEIDENTIFIER
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10)
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly
	)
AS
BEGIN
	DECLARE @op1 VARCHAR(50)
	DECLARE @Secondopop1 VARCHAR(50)
	DECLARE @op2 VARCHAR(50)
	DECLARE @op3 VARCHAR(50)
	DECLARE @LogicalOperator1 VARCHAR(50)
	DECLARE @Date DATETIME
	DECLARE @SecondDate DATETIME
	DECLARE @Type NVARCHAR(100)
	DECLARE @Message NVARCHAR(Max)

	SELECT @op1 = Opertor
		,@Date = ParameterValue
		,@Secondopop1 = SecondParameterOperator
		,@SecondDate = SecondParameterValue
		,@LogicalOperator1 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'AuditDate'

	SELECT @op2 = Opertor
		,@Type = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'RowType'

	SELECT @op3 = Opertor
		,@Message = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Message'

	DECLARE @DateVarchar VARCHAR(100) = CAST(@Date AS VARCHAR)
		,@SecondDateVarchar VARCHAR(100) = CAST(@SecondDate AS VARCHAR)
	DECLARE @WhereParameter VARCHAR(MAX)
		,@pOrderByParameter VARCHAR(MAX) = NULL
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

	IF (@pOrderBy IS NULL)
	BEGIN
		SET @pOrderBy = 'CreationTimeStamp'
	END

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'desc'

	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = (SELECT Count(0) FROM ImportAudit WHERE [File_Id] = @pImportFileId);

	IF (@pIsExport = 0)
	BEGIN
		SELECT count(0)
		FROM (
				select [AuditDate],[IsRowInavlid],[Message],[RowData],[RowErrors],RowType,Id,CreationTimeStamp 
			from
			(
			SELECT GPSUpdateTimestamp AS [AuditDate]
				,IsInvalid AS [IsRowInavlid]
				,(case when isnull([Message],'')<>'' then [Message] else replace(SUBSTRING(SerializedRowErrors, 1, (CHARINDEX('.|', SerializedRowErrors))),'|','') end) as [Message]
				,replace(SerializedRowData,'{null}',' ')  AS [RowData]
				,SerializedRowErrors AS [RowErrors]
				,(
					CASE 
						WHEN Error = 1
							THEN 'Error'
						ELSE 'Info'
						END
					) AS RowType
				,GUIDReference AS Id
				,CreationTimeStamp AS CreationTimeStamp
			FROM ImportAudit
			WHERE [File_Id] = @pImportFileId
			)tt
			) T
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
								AND [CreationTimeStamp] = @Date
								)
							OR (
								@op1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @Date
								)
							OR (
								@op1 = @IsLessThan
								AND [CreationTimeStamp] < @Date
								)
							OR (
								@op1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] >= @Date
								)
							OR (
								@op1 = @IsGreaterThan
								AND [CreationTimeStamp] > @Date
								)
							OR (
								@op1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @Date
								)
							OR (
								@op1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @DateVarchar + '%'
								)
							OR (
								@op1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @DateVarchar + '%'
								)
							OR (
								@op1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @DateVarchar + '%'
								)
							OR (
								@op1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @DateVarchar + ''
								)
							)
						OR (
							(
								@Secondopop1 = @IsEqualTo
								AND [CreationTimeStamp] = @SecondDate
								)
							OR (
								@Secondopop1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @SecondDate
								)
							OR (
								@Secondopop1 = @IsLessThan
								AND [CreationTimeStamp] < @SecondDate
								)
							OR (
								@Secondopop1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] <= @SecondDate
								)
							OR (
								@Secondopop1 = @IsGreaterThan
								AND [CreationTimeStamp] > @SecondDate
								)
							OR (
								@Secondopop1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @SecondDate
								)
							OR (
								@Secondopop1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @SecondDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @SecondDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @SecondDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @SecondDateVarchar + ''
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
								AND [CreationTimeStamp] = @Date
								)
							OR (
								@op1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @Date
								)
							OR (
								@op1 = @IsLessThan
								AND [CreationTimeStamp] < @Date
								)
							OR (
								@op1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] >= @Date
								)
							OR (
								@op1 = @IsGreaterThan
								AND [CreationTimeStamp] > @Date
								)
							OR (
								@op1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @Date
								)
							OR (
								@op1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @DateVarchar + '%'
								)
							OR (
								@op1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @DateVarchar + '%'
								)
							OR (
								@op1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @DateVarchar + '%'
								)
							OR (
								@op1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @DateVarchar + ''
								)
							)
						AND (
							(
								@Secondopop1 = @IsEqualTo
								AND [CreationTimeStamp] = @SecondDate
								)
							OR (
								@Secondopop1 = @IsNotEqualTo
								AND [CreationTimeStamp] <> @SecondDate
								)
							OR (
								@Secondopop1 = @IsLessThan
								AND [CreationTimeStamp] < @SecondDate
								)
							OR (
								@Secondopop1 = @IsLessThanOrEqualTo
								AND [CreationTimeStamp] <= @SecondDate
								)
							OR (
								@Secondopop1 = @IsGreaterThan
								AND [CreationTimeStamp] > @SecondDate
								)
							OR (
								@Secondopop1 = @IsGreaterThanOrEqualTo
								AND [CreationTimeStamp] >= @SecondDate
								)
							OR (
								@Secondopop1 = @Contains
								AND [CreationTimeStamp] LIKE '%' + @SecondDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @DoesNotContain
								AND [CreationTimeStamp] NOT LIKE '%' + @SecondDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @StartsWith
								AND [CreationTimeStamp] LIKE '' + @SecondDateVarchar + '%'
								)
							OR (
								@Secondopop1 = @EndsWith
								AND [CreationTimeStamp] LIKE '%' + @SecondDateVarchar + ''
								)
							)
						)
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND RowType = @Type
					)
				OR (
					@op2 = @IsNotEqualTo
					AND RowType <> @Type
					)
				OR (
					@op2 = @IsLessThan
					AND RowType < @Type
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND RowType >= @Type
					)
				OR (
					@op2 = @IsGreaterThan
					AND RowType > @Type
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND RowType >= @Type
					)
				OR (
					@op2 = @Contains
					AND RowType LIKE '%' + @Type + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND RowType NOT LIKE '%' + @Type + '%'
					)
				OR (
					@op2 = @StartsWith
					AND RowType LIKE '' + @Type + '%'
					)
				OR (
					@op2 = @EndsWith
					AND RowType LIKE '%' + @Type + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND [Message] = @Message
					)
				OR (
					@op3 = @IsNotEqualTo
					AND [Message] <> @Message
					)
				OR (
					@op3 = @IsLessThan
					AND [Message] < @Message
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND [Message] >= @Message
					)
				OR (
					@op3 = @IsGreaterThan
					AND [Message] > @Message
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND [Message] >= @Message
					)
				OR (
					@op3 = @Contains
					AND [Message] LIKE '%' + @Message + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND [Message] NOT LIKE '%' + @Message + '%'
					)
				OR (
					@op3 = @StartsWith
					AND [Message] LIKE '' + @Message + '%'
					)
				OR (
					@op3 = @EndsWith
					AND [Message] LIKE '%' + @Message + ''
					)
				)
	END

	SELECT [AuditDate],[IsRowInavlid],Replace(Replace([Message],'<',' '),'>',' ') as [Message],[RowData],[RowErrors],RowType,Id,CreationTimeStamp
	FROM (
			select [AuditDate],[IsRowInavlid],[Message],[RowData],[RowErrors],RowType,Id,CreationTimeStamp 
			from
			(
			SELECT GPSUpdateTimestamp AS [AuditDate]
				,IsInvalid AS [IsRowInavlid]
				,(case when isnull([Message],'')<>'' then [Message] else replace(SUBSTRING(SerializedRowErrors, 1, (CHARINDEX('.|', SerializedRowErrors))),'|','') end) as [Message]
				,replace(SerializedRowData,'{null}',' ')  AS [RowData]
				,SerializedRowErrors AS [RowErrors]
				,(
					CASE 
						WHEN Error = 1
							THEN 'Error'
						ELSE 'Info'
						END
					) AS RowType
				,GUIDReference AS Id
				,CreationTimeStamp AS CreationTimeStamp
			FROM ImportAudit
			WHERE [File_Id] = @pImportFileId
			)tt
		) T
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
							AND [CreationTimeStamp] = @Date
							)
						OR (
							@op1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @Date
							)
						OR (
							@op1 = @IsLessThan
							AND [CreationTimeStamp] < @Date
							)
						OR (
							@op1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] >= @Date
							)
						OR (
							@op1 = @IsGreaterThan
							AND [CreationTimeStamp] > @Date
							)
						OR (
							@op1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @Date
							)
						OR (
							@op1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @DateVarchar + '%'
							)
						OR (
							@op1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @DateVarchar + '%'
							)
						OR (
							@op1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @DateVarchar + '%'
							)
						OR (
							@op1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @DateVarchar + ''
							)
						)
					OR (
						(
							@Secondopop1 = @IsEqualTo
							AND [CreationTimeStamp] = @SecondDate
							)
						OR (
							@Secondopop1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @SecondDate
							)
						OR (
							@Secondopop1 = @IsLessThan
							AND [CreationTimeStamp] < @SecondDate
							)
						OR (
							@Secondopop1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] <= @SecondDate
							)
						OR (
							@Secondopop1 = @IsGreaterThan
							AND [CreationTimeStamp] > @SecondDate
							)
						OR (
							@Secondopop1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @SecondDate
							)
						OR (
							@Secondopop1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @SecondDate + '%'
							)
						OR (
							@Secondopop1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @SecondDate + '%'
							)
						OR (
							@Secondopop1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @SecondDate + '%'
							)
						OR (
							@Secondopop1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @SecondDate + ''
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
							AND [CreationTimeStamp] = @Date
							)
						OR (
							@op1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @Date
							)
						OR (
							@op1 = @IsLessThan
							AND [CreationTimeStamp] < @Date
							)
						OR (
							@op1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] >= @Date
							)
						OR (
							@op1 = @IsGreaterThan
							AND [CreationTimeStamp] > @Date
							)
						OR (
							@op1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @Date
							)
						OR (
							@op1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @DateVarchar + '%'
							)
						OR (
							@op1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @DateVarchar + '%'
							)
						OR (
							@op1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @DateVarchar + '%'
							)
						OR (
							@op1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @DateVarchar + ''
							)
						)
					AND (
						(
							@Secondopop1 = @IsEqualTo
							AND [CreationTimeStamp] = @SecondDate
							)
						OR (
							@Secondopop1 = @IsNotEqualTo
							AND [CreationTimeStamp] <> @SecondDate
							)
						OR (
							@Secondopop1 = @IsLessThan
							AND [CreationTimeStamp] < @SecondDate
							)
						OR (
							@Secondopop1 = @IsLessThanOrEqualTo
							AND [CreationTimeStamp] <= @SecondDate
							)
						OR (
							@Secondopop1 = @IsGreaterThan
							AND [CreationTimeStamp] > @SecondDate
							)
						OR (
							@Secondopop1 = @IsGreaterThanOrEqualTo
							AND [CreationTimeStamp] >= @SecondDate
							)
						OR (
							@Secondopop1 = @Contains
							AND [CreationTimeStamp] LIKE '%' + @SecondDate + '%'
							)
						OR (
							@Secondopop1 = @DoesNotContain
							AND [CreationTimeStamp] NOT LIKE '%' + @SecondDate + '%'
							)
						OR (
							@Secondopop1 = @StartsWith
							AND [CreationTimeStamp] LIKE '' + @SecondDate + '%'
							)
						OR (
							@Secondopop1 = @EndsWith
							AND [CreationTimeStamp] LIKE '%' + @SecondDate + ''
							)
						)
					)
				)
			)
		AND (
			(@op2 IS NULL)
			OR (
				@op2 = @IsEqualTo
				AND RowType = @Type
				)
			OR (
				@op2 = @IsNotEqualTo
				AND RowType <> @Type
				)
			OR (
				@op2 = @IsLessThan
				AND RowType < @Type
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND RowType >= @Type
				)
			OR (
				@op2 = @IsGreaterThan
				AND RowType > @Type
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND RowType >= @Type
				)
			OR (
				@op2 = @Contains
				AND RowType LIKE '%' + @Type + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND RowType NOT LIKE '%' + @Type + '%'
				)
			OR (
				@op2 = @StartsWith
				AND RowType LIKE '' + @Type + '%'
				)
			OR (
				@op2 = @EndsWith
				AND RowType LIKE '%' + @Type + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 = @IsEqualTo
				AND [Message] = @Message
				)
			OR (
				@op3 = @IsNotEqualTo
				AND [Message] <> @Message
				)
			OR (
				@op3 = @IsLessThan
				AND [Message] < @Message
				)
			OR (
				@op3 = @IsLessThanOrEqualTo
				AND [Message] >= @Message
				)
			OR (
				@op3 = @IsGreaterThan
				AND [Message] > @Message
				)
			OR (
				@op3 = @IsGreaterThanOrEqualTo
				AND [Message] >= @Message
				)
			OR (
				@op3 = @Contains
				AND [Message] LIKE '%' + @Message + '%'
				)
			OR (
				@op3 = @DoesNotContain
				AND [Message] NOT LIKE '%' + @Message + '%'
				)
			OR (
				@op3 = @StartsWith
				AND [Message] LIKE '' + @Message + '%'
				)
			OR (
				@op3 = @EndsWith
				AND [Message] LIKE '%' + @Message + ''
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'AuditDate'
				AND @pOrderType = 'ASC'
				THEN AuditDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'RowType'
				AND @pOrderType = 'DESC'
				THEN RowType
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Message'
				AND @pOrderType = 'ASC'
				THEN [Message]
			END DESC OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)

	SELECT icm.ColumnIndex, ISNULL(a.[Key], icm.Property) as [ColumnName]
	FROM ImportFile ifile
	JOIN ImportColumnMapping icm ON icm.ImportFormat_Id=ifile.ImportFormat_Id
	LEFT JOIN Attribute a ON a.GUIDReference=icm.Demographic_Id
	WHERE ifile.guidreference=@pImportFileId
	ORDER BY icm.ColumnIndex ASC

END