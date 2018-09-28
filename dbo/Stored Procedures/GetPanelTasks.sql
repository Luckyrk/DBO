CREATE PROCEDURE [dbo].[GetPanelTasks] @pPanelId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10) -- ASC OR DESC
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable READONLY
AS
BEGIN
	DECLARE @op1 VARCHAR(50)
		,@op2 VARCHAR(50)
		,@op3 VARCHAR(50)
		,@op4 VARCHAR(50)
		,@op5 VARCHAR(50)
		,@op6 VARCHAR(50)
	DECLARE @LogicalOperator4 VARCHAR(5)
		,@Secondop4 VARCHAR(50)
		,@SecondActiveFrom DATE
	DECLARE @LogicalOperator5 VARCHAR(5)
		,@Secondop5 VARCHAR(50)
		,@SecondActiveTo DATE
	DECLARE @Code VARCHAR(500)
		,@Name VARCHAR(500)
		,@TaskType VARCHAR(500)
		,@ActiveFrom VARCHAR(500)
		,@ActiveTo VARCHAR(50)
		,@Mandatory VARCHAR(50)

	SELECT @op1 = Opertor
		,@Code = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Code'

	SELECT @op2 = Opertor
		,@Name = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Name'

	SELECT @op3 = Opertor
		,@TaskType = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'TaskType'

	SELECT @op4 = Opertor
		,@ActiveFrom = CAST(ParameterValue AS DATE)
		,@Secondop4 = SecondParameterOperator
		,@SecondActiveFrom = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator4 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'ActiveFrom'

	SELECT @op5 = Opertor
		,@ActiveTo = CAST(ParameterValue AS DATE)
		,@Secondop5 = SecondParameterOperator
		,@SecondActiveTo = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator5 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'ActiveTo'

	SELECT @op6 = Opertor
		,@Mandatory = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Mandatory'

	DECLARE @ActiveFromVarchar VARCHAR(100) = CAST(@ActiveFrom AS VARCHAR)
		,@SecondActiveFromVarchar VARCHAR(100) = CAST(@SecondActiveFrom AS VARCHAR)
	DECLARE @ActiveToVarchar VARCHAR(100) = CAST(@ActiveTo AS VARCHAR)
		,@SecondActiveToVarchar VARCHAR(100) = CAST(@SecondActiveTo AS VARCHAR)

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'Name'

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'DESC'

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

	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 15000

	IF (@pIsExport = 0)
	BEGIN
		SELECT COUNT(0)
		FROM (
			SELECT SPT.SurveyParticipationTaskId AS [Id]
				,SPT.CODE AS [Code]
				,SPT.NAME AS [Name]
				,TT.VALUE AS [TaskType]
				,PSPT.ActiveFrom
				,PSPT.ActiveTo
				,PSPT.Mandatory
				,SPT.PanelTaskType_Id
			FROM SurveyParticipationTask SPT
			JOIN PanelSurveyParticipationTask PSPT ON SPT.SurveyParticipationTaskId = PSPT.Task_Id
			LEFT JOIN PANELTASKTYPE PTT ON SPT.PANELTASKTYPE_ID = PTT.GUIDREFERENCE
			LEFT JOIN TRANSLATION T ON T.TRANSLATIONID = PTT.[DESCRIPTION_Id]
			LEFT JOIN TRANSLATIONTERM TT ON T.TRANSLATIONID = TT.TRANSLATION_ID
				AND TT.CULTURECODE = @pCultureCode
			WHERE PSPT.PANEL_ID = @pPanelId
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Code = @Code
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Code <> @Code
					)
				OR (
					@op1 = @IsLessThan
					AND Code < @Code
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Code <= @Code
					)
				OR (
					@op1 = @IsGreaterThan
					AND Code > @Code
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Code >= @Code
					)
				OR (
					@op1 = @Contains
					AND Code LIKE '%' + @Code + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Code NOT LIKE '%' + @Code + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Code LIKE '' + @Code + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Code LIKE '%' + @Code + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND NAME = @Name
					)
				OR (
					@op2 = @IsNotEqualTo
					AND NAME <> @Name
					)
				OR (
					@op2 = @IsLessThan
					AND NAME < @Name
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND NAME <= @Name
					)
				OR (
					@op2 = @IsGreaterThan
					AND NAME > @Name
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND NAME >= @Name
					)
				OR (
					@op2 = @Contains
					AND NAME LIKE '%' + @Name + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND NAME NOT LIKE '%' + @Name + '%'
					)
				OR (
					@op2 = @StartsWith
					AND NAME LIKE '' + @Name + '%'
					)
				OR (
					@op2 = @EndsWith
					AND NAME LIKE '%' + @Name + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND TaskType = @TaskType
					)
				OR (
					@op3 = @IsNotEqualTo
					AND TaskType <> @TaskType
					)
				OR (
					@op3 = @IsLessThan
					AND TaskType < @TaskType
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND TaskType <= @TaskType
					)
				OR (
					@op3 = @IsGreaterThan
					AND TaskType > @TaskType
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND TaskType >= @TaskType
					)
				OR (
					@op3 = @Contains
					AND TaskType LIKE '%' + @TaskType + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND TaskType NOT LIKE '%' + @TaskType + '%'
					)
				OR (
					@op3 = @StartsWith
					AND TaskType LIKE '' + @TaskType + '%'
					)
				OR (
					@op3 = @EndsWith
					AND TaskType LIKE '%' + @TaskType + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 IS NULL
					AND @LogicalOperator4 IS NULL
					)
				OR (
					@LogicalOperator4 = 'OR'
					AND (
						(
							(
								@op4 = @IsEqualTo
								AND ActiveFrom = @ActiveFrom
								)
							OR (
								@op4 = @IsNotEqualTo
								AND ActiveFrom <> @ActiveFrom
								)
							OR (
								@op4 = @IsLessThan
								AND ActiveFrom < @ActiveFrom
								)
							OR (
								@op4 = @IsLessThanOrEqualTo
								AND ActiveFrom <= @ActiveFrom
								)
							OR (
								@op4 = @IsGreaterThan
								AND ActiveFrom > @ActiveFrom
								)
							OR (
								@op4 = @IsGreaterThanOrEqualTo
								AND ActiveFrom >= @ActiveFrom
								)
							OR (
								@op4 = @Contains
								AND ActiveFrom LIKE '%' + @ActiveFromVarchar + '%'
								)
							OR (
								@op4 = @DoesNotContain
								AND ActiveFrom NOT LIKE '%' + @ActiveFromVarchar + '%'
								)
							OR (
								@op4 = @StartsWith
								AND ActiveFrom LIKE '' + @ActiveFromVarchar + '%'
								)
							OR (
								@op4 = @EndsWith
								AND ActiveFrom LIKE '%' + @ActiveFromVarchar + ''
								)
							)
						OR (
							(
								@Secondop4 = @IsEqualTo
								AND ActiveFrom = @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsNotEqualTo
								AND ActiveFrom <> @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsLessThan
								AND ActiveFrom < @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsLessThanOrEqualTo
								AND ActiveFrom <= @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsGreaterThan
								AND ActiveFrom > @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsGreaterThanOrEqualTo
								AND ActiveFrom >= @SecondActiveFrom
								)
							OR (
								@Secondop4 = @Contains
								AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + '%'
								)
							OR (
								@Secondop4 = @DoesNotContain
								AND ActiveFrom NOT LIKE '%' + @SecondActiveFromVarchar + '%'
								)
							OR (
								@Secondop4 = @StartsWith
								AND ActiveFrom LIKE '' + @SecondActiveFromVarchar + '%'
								)
							OR (
								@Secondop4 = @EndsWith
								AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator4 = 'AND'
					AND (
						(
							(
								@op4 = @IsEqualTo
								AND ActiveFrom = @ActiveFrom
								)
							OR (
								@op4 = @IsNotEqualTo
								AND ActiveFrom <> @ActiveFrom
								)
							OR (
								@op4 = @IsLessThan
								AND ActiveFrom < @ActiveFrom
								)
							OR (
								@op4 = @IsLessThanOrEqualTo
								AND ActiveFrom <= @ActiveFrom
								)
							OR (
								@op4 = @IsGreaterThan
								AND ActiveFrom > @ActiveFrom
								)
							OR (
								@op4 = @IsGreaterThanOrEqualTo
								AND ActiveFrom >= @ActiveFrom
								)
							OR (
								@op4 = @Contains
								AND ActiveFrom LIKE '%' + @ActiveFromVarchar + '%'
								)
							OR (
								@op4 = @DoesNotContain
								AND ActiveFrom NOT LIKE '%' + @ActiveFromVarchar + '%'
								)
							OR (
								@op4 = @StartsWith
								AND ActiveFrom LIKE '' + @ActiveFromVarchar + '%'
								)
							OR (
								@op4 = @EndsWith
								AND ActiveFrom LIKE '%' + @ActiveFromVarchar + ''
								)
							)
						AND (
							(
								@Secondop4 = @IsEqualTo
								AND ActiveFrom = @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsNotEqualTo
								AND ActiveFrom <> @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsLessThan
								AND ActiveFrom < @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsLessThanOrEqualTo
								AND ActiveFrom <= @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsGreaterThan
								AND ActiveFrom > @SecondActiveFrom
								)
							OR (
								@Secondop4 = @IsGreaterThanOrEqualTo
								AND ActiveFrom >= @SecondActiveFrom
								)
							OR (
								@Secondop4 = @Contains
								AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + '%'
								)
							OR (
								@Secondop4 = @DoesNotContain
								AND ActiveFrom NOT LIKE '%' + @SecondActiveFromVarchar + '%'
								)
							OR (
								@Secondop4 = @StartsWith
								AND ActiveFrom LIKE '' + @SecondActiveFromVarchar + '%'
								)
							OR (
								@Secondop4 = @EndsWith
								AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop4 IS NULL
					AND (
						(
							@op4 = @IsEqualTo
							AND ActiveFrom = @ActiveFrom
							)
						OR (
							@op4 = @IsNotEqualTo
							AND ActiveFrom <> @ActiveFrom
							)
						OR (
							@op4 = @IsLessThan
							AND ActiveFrom < @ActiveFrom
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND ActiveFrom <= @ActiveFrom
							)
						OR (
							@op4 = @IsGreaterThan
							AND ActiveFrom > @ActiveFrom
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND ActiveFrom >= @ActiveFrom
							)
						OR (
							@op4 = @Contains
							AND ActiveFrom LIKE '%' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND ActiveFrom NOT LIKE '%' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @StartsWith
							AND ActiveFrom LIKE '' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @EndsWith
							AND ActiveFrom LIKE '%' + @ActiveFromVarchar + ''
							)
						)
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 IS NULL
					AND @LogicalOperator4 IS NULL
					)
				OR (
					@LogicalOperator5 = 'OR'
					AND (
						(
							(
								@op5 = @IsEqualTo
								AND ActiveTo = @ActiveTo
								)
							OR (
								@op5 = @IsNotEqualTo
								AND ActiveTo <> @ActiveTo
								)
							OR (
								@op5 = @IsLessThan
								AND ActiveTo < @ActiveTo
								)
							OR (
								@op5 = @IsLessThanOrEqualTo
								AND ActiveTo <= @ActiveTo
								)
							OR (
								@op5 = @IsGreaterThan
								AND ActiveTo > @ActiveTo
								)
							OR (
								@op5 = @IsGreaterThanOrEqualTo
								AND ActiveTo >= @ActiveTo
								)
							OR (
								@op5 = @Contains
								AND ActiveTo LIKE '%' + @ActiveToVarchar + '%'
								)
							OR (
								@op5 = @DoesNotContain
								AND ActiveTo NOT LIKE '%' + @ActiveToVarchar + '%'
								)
							OR (
								@op5 = @StartsWith
								AND ActiveTo LIKE '' + @ActiveToVarchar + '%'
								)
							OR (
								@op5 = @EndsWith
								AND ActiveTo LIKE '%' + @ActiveToVarchar + ''
								)
							)
						OR (
							(
								@Secondop5 = @IsEqualTo
								AND ActiveTo = @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsNotEqualTo
								AND ActiveTo <> @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsLessThan
								AND ActiveTo < @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsLessThanOrEqualTo
								AND ActiveTo <= @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsGreaterThan
								AND ActiveTo > @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsGreaterThanOrEqualTo
								AND ActiveTo >= @SecondActiveTo
								)
							OR (
								@Secondop5 = @Contains
								AND ActiveTo LIKE '%' + @SecondActiveToVarchar + '%'
								)
							OR (
								@Secondop5 = @DoesNotContain
								AND ActiveTo NOT LIKE '%' + @SecondActiveToVarchar + '%'
								)
							OR (
								@Secondop5 = @StartsWith
								AND ActiveTo LIKE '' + @SecondActiveToVarchar + '%'
								)
							OR (
								@Secondop5 = @EndsWith
								AND ActiveTo LIKE '%' + @SecondActiveToVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator5 = 'AND'
					AND (
						(
							(
								@op5 = @IsEqualTo
								AND ActiveTo = @ActiveTo
								)
							OR (
								@op5 = @IsNotEqualTo
								AND ActiveTo <> @ActiveTo
								)
							OR (
								@op5 = @IsLessThan
								AND ActiveTo < @ActiveTo
								)
							OR (
								@op5 = @IsLessThanOrEqualTo
								AND ActiveTo <= @ActiveTo
								)
							OR (
								@op5 = @IsGreaterThan
								AND ActiveTo > @ActiveTo
								)
							OR (
								@op5 = @IsGreaterThanOrEqualTo
								AND ActiveTo >= @ActiveTo
								)
							OR (
								@op5 = @Contains
								AND ActiveTo LIKE '%' + @ActiveToVarchar + '%'
								)
							OR (
								@op5 = @DoesNotContain
								AND ActiveTo NOT LIKE '%' + @ActiveToVarchar + '%'
								)
							OR (
								@op5 = @StartsWith
								AND ActiveTo LIKE '' + @ActiveToVarchar + '%'
								)
							OR (
								@op5 = @EndsWith
								AND ActiveTo LIKE '%' + @ActiveToVarchar + ''
								)
							)
						AND (
							(
								@Secondop5 = @IsEqualTo
								AND ActiveTo = @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsNotEqualTo
								AND ActiveTo <> @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsLessThan
								AND ActiveTo < @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsLessThanOrEqualTo
								AND ActiveTo <= @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsGreaterThan
								AND ActiveTo > @SecondActiveTo
								)
							OR (
								@Secondop5 = @IsGreaterThanOrEqualTo
								AND ActiveTo >= @SecondActiveTo
								)
							OR (
								@Secondop5 = @Contains
								AND ActiveTo LIKE '%' + @SecondActiveToVarchar + '%'
								)
							OR (
								@Secondop5 = @DoesNotContain
								AND ActiveTo NOT LIKE '%' + @SecondActiveToVarchar + '%'
								)
							OR (
								@Secondop5 = @StartsWith
								AND ActiveTo LIKE '' + @SecondActiveToVarchar + '%'
								)
							OR (
								@Secondop5 = @EndsWith
								AND ActiveTo LIKE '%' + @SecondActiveToVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop5 IS NULL
					AND (
						(
							@op5 = @IsEqualTo
							AND ActiveTo = @ActiveTo
							)
						OR (
							@op5 = @IsNotEqualTo
							AND ActiveTo <> @ActiveTo
							)
						OR (
							@op5 = @IsLessThan
							AND ActiveTo < @ActiveTo
							)
						OR (
							@op5 = @IsLessThanOrEqualTo
							AND ActiveTo <= @ActiveTo
							)
						OR (
							@op5 = @IsGreaterThan
							AND ActiveTo > @ActiveTo
							)
						OR (
							@op5 = @IsGreaterThanOrEqualTo
							AND ActiveTo >= @ActiveTo
							)
						OR (
							@op5 = @Contains
							AND ActiveTo LIKE '%' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @DoesNotContain
							AND ActiveTo NOT LIKE '%' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @StartsWith
							AND ActiveTo LIKE '' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @EndsWith
							AND ActiveTo LIKE '%' + @ActiveToVarchar + ''
							)
						)
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND convert(VARCHAR, Mandatory) = CASE @Mandatory
						WHEN 'True'
							THEN '1'
						ELSE '0'
						END
					)
				)

		OPTION (RECOMPILE)
	END

	SELECT *
	FROM (
		SELECT SPT.SurveyParticipationTaskId AS [Id]
			,SPT.CODE AS [Code]
			,SPT.NAME AS [Name]
			,CASE TT.VALUE
				WHEN NULL
					THEN '[' + T.KeyName + ']'
				ELSE TT.VALUE
				END AS [TaskType]
			,PSPT.ActiveFrom
			,PSPT.ActiveTo
			,PSPT.Mandatory
			,SPT.PanelTaskType_Id
		FROM SurveyParticipationTask SPT
		JOIN PanelSurveyParticipationTask PSPT ON SPT.SurveyParticipationTaskId = PSPT.Task_Id
		LEFT JOIN PANELTASKTYPE PTT ON SPT.PANELTASKTYPE_ID = PTT.GUIDREFERENCE
		LEFT JOIN TRANSLATION T ON T.TRANSLATIONID = PTT.[DESCRIPTION_Id]
		LEFT JOIN TRANSLATIONTERM TT ON T.TRANSLATIONID = TT.TRANSLATION_ID
			AND TT.CULTURECODE = @pCultureCode
		WHERE PSPT.PANEL_ID = @pPanelId
		) AS TEMPTABLE
	WHERE (
			(@op1 IS NULL)
			OR (
				@op1 = @IsEqualTo
				AND Code = @Code
				)
			OR (
				@op1 = @IsNotEqualTo
				AND Code <> @Code
				)
			OR (
				@op1 = @IsLessThan
				AND Code < @Code
				)
			OR (
				@op1 = @IsLessThanOrEqualTo
				AND Code <= @Code
				)
			OR (
				@op1 = @IsGreaterThan
				AND Code > @Code
				)
			OR (
				@op1 = @IsGreaterThanOrEqualTo
				AND Code >= @Code
				)
			OR (
				@op1 = @Contains
				AND Code LIKE '%' + @Code + '%'
				)
			OR (
				@op1 = @DoesNotContain
				AND Code NOT LIKE '%' + @Code + '%'
				)
			OR (
				@op1 = @StartsWith
				AND Code LIKE '' + @Code + '%'
				)
			OR (
				@op1 = @EndsWith
				AND Code LIKE '%' + @Code + ''
				)
			)
		AND (
			(@op2 IS NULL)
			OR (
				@op2 = @IsEqualTo
				AND NAME = @Name
				)
			OR (
				@op2 = @IsNotEqualTo
				AND NAME <> @Name
				)
			OR (
				@op2 = @IsLessThan
				AND NAME < @Name
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND NAME <= @Name
				)
			OR (
				@op2 = @IsGreaterThan
				AND NAME > @Name
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND NAME >= @Name
				)
			OR (
				@op2 = @Contains
				AND NAME LIKE '%' + @Name + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND NAME NOT LIKE '%' + @Name + '%'
				)
			OR (
				@op2 = @StartsWith
				AND NAME LIKE '' + @Name + '%'
				)
			OR (
				@op2 = @EndsWith
				AND NAME LIKE '%' + @Name + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 = @IsEqualTo
				AND TaskType = @TaskType
				)
			OR (
				@op3 = @IsNotEqualTo
				AND TaskType <> @TaskType
				)
			OR (
				@op3 = @IsLessThan
				AND TaskType < @TaskType
				)
			OR (
				@op3 = @IsLessThanOrEqualTo
				AND TaskType <= @TaskType
				)
			OR (
				@op3 = @IsGreaterThan
				AND TaskType > @TaskType
				)
			OR (
				@op3 = @IsGreaterThanOrEqualTo
				AND TaskType >= @TaskType
				)
			OR (
				@op3 = @Contains
				AND TaskType LIKE '%' + @TaskType + '%'
				)
			OR (
				@op3 = @DoesNotContain
				AND TaskType NOT LIKE '%' + @TaskType + '%'
				)
			OR (
				@op3 = @StartsWith
				AND TaskType LIKE '' + @TaskType + '%'
				)
			OR (
				@op3 = @EndsWith
				AND TaskType LIKE '%' + @TaskType + ''
				)
			)
		AND (
			(@op4 IS NULL)
			OR (
				@op4 IS NULL
				AND @LogicalOperator4 IS NULL
				)
			OR (
				@LogicalOperator4 = 'OR'
				AND (
					(
						(
							@op4 = @IsEqualTo
							AND ActiveFrom = @ActiveFrom
							)
						OR (
							@op4 = @IsNotEqualTo
							AND ActiveFrom <> @ActiveFrom
							)
						OR (
							@op4 = @IsLessThan
							AND ActiveFrom < @ActiveFrom
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND ActiveFrom <= @ActiveFrom
							)
						OR (
							@op4 = @IsGreaterThan
							AND ActiveFrom > @ActiveFrom
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND ActiveFrom >= @ActiveFrom
							)
						OR (
							@op4 = @Contains
							AND ActiveFrom LIKE '%' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND ActiveFrom NOT LIKE '%' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @StartsWith
							AND ActiveFrom LIKE '' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @EndsWith
							AND ActiveFrom LIKE '%' + @ActiveFromVarchar + ''
							)
						)
					OR (
						(
							@Secondop4 = @IsEqualTo
							AND ActiveFrom = @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsNotEqualTo
							AND ActiveFrom <> @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsLessThan
							AND ActiveFrom < @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsLessThanOrEqualTo
							AND ActiveFrom <= @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsGreaterThan
							AND ActiveFrom > @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsGreaterThanOrEqualTo
							AND ActiveFrom >= @SecondActiveFrom
							)
						OR (
							@Secondop4 = @Contains
							AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + '%'
							)
						OR (
							@Secondop4 = @DoesNotContain
							AND ActiveFrom NOT LIKE '%' + @SecondActiveFromVarchar + '%'
							)
						OR (
							@Secondop4 = @StartsWith
							AND ActiveFrom LIKE '' + @SecondActiveFromVarchar + '%'
							)
						OR (
							@Secondop4 = @EndsWith
							AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator4 = 'AND'
				AND (
					(
						(
							@op4 = @IsEqualTo
							AND ActiveFrom = @ActiveFrom
							)
						OR (
							@op4 = @IsNotEqualTo
							AND ActiveFrom <> @ActiveFrom
							)
						OR (
							@op4 = @IsLessThan
							AND ActiveFrom < @ActiveFrom
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND ActiveFrom <= @ActiveFrom
							)
						OR (
							@op4 = @IsGreaterThan
							AND ActiveFrom > @ActiveFrom
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND ActiveFrom >= @ActiveFrom
							)
						OR (
							@op4 = @Contains
							AND ActiveFrom LIKE '%' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND ActiveFrom NOT LIKE '%' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @StartsWith
							AND ActiveFrom LIKE '' + @ActiveFromVarchar + '%'
							)
						OR (
							@op4 = @EndsWith
							AND ActiveFrom LIKE '%' + @ActiveFromVarchar + ''
							)
						)
					AND (
						(
							@Secondop4 = @IsEqualTo
							AND ActiveFrom = @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsNotEqualTo
							AND ActiveFrom <> @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsLessThan
							AND ActiveFrom < @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsLessThanOrEqualTo
							AND ActiveFrom <= @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsGreaterThan
							AND ActiveFrom > @SecondActiveFrom
							)
						OR (
							@Secondop4 = @IsGreaterThanOrEqualTo
							AND ActiveFrom >= @SecondActiveFrom
							)
						OR (
							@Secondop4 = @Contains
							AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + '%'
							)
						OR (
							@Secondop4 = @DoesNotContain
							AND ActiveFrom NOT LIKE '%' + @SecondActiveFromVarchar + '%'
							)
						OR (
							@Secondop4 = @StartsWith
							AND ActiveFrom LIKE '' + @SecondActiveFromVarchar + '%'
							)
						OR (
							@Secondop4 = @EndsWith
							AND ActiveFrom LIKE '%' + @SecondActiveFromVarchar + ''
							)
						)
					)
				)
			OR (
				@Secondop4 IS NULL
				AND (
					(
						@op4 = @IsEqualTo
						AND ActiveFrom = @ActiveFrom
						)
					OR (
						@op4 = @IsNotEqualTo
						AND ActiveFrom <> @ActiveFrom
						)
					OR (
						@op4 = @IsLessThan
						AND ActiveFrom < @ActiveFrom
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND ActiveFrom <= @ActiveFrom
						)
					OR (
						@op4 = @IsGreaterThan
						AND ActiveFrom > @ActiveFrom
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND ActiveFrom >= @ActiveFrom
						)
					OR (
						@op4 = @Contains
						AND ActiveFrom LIKE '%' + @ActiveFromVarchar + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND ActiveFrom NOT LIKE '%' + @ActiveFromVarchar + '%'
						)
					OR (
						@op4 = @StartsWith
						AND ActiveFrom LIKE '' + @ActiveFromVarchar + '%'
						)
					OR (
						@op4 = @EndsWith
						AND ActiveFrom LIKE '%' + @ActiveFromVarchar + ''
						)
					)
				)
			)
		AND (
			(@op5 IS NULL)
			OR (
				@op5 IS NULL
				AND @LogicalOperator4 IS NULL
				)
			OR (
				@LogicalOperator5 = 'OR'
				AND (
					(
						(
							@op5 = @IsEqualTo
							AND ActiveTo = @ActiveTo
							)
						OR (
							@op5 = @IsNotEqualTo
							AND ActiveTo <> @ActiveTo
							)
						OR (
							@op5 = @IsLessThan
							AND ActiveTo < @ActiveTo
							)
						OR (
							@op5 = @IsLessThanOrEqualTo
							AND ActiveTo <= @ActiveTo
							)
						OR (
							@op5 = @IsGreaterThan
							AND ActiveTo > @ActiveTo
							)
						OR (
							@op5 = @IsGreaterThanOrEqualTo
							AND ActiveTo >= @ActiveTo
							)
						OR (
							@op5 = @Contains
							AND ActiveTo LIKE '%' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @DoesNotContain
							AND ActiveTo NOT LIKE '%' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @StartsWith
							AND ActiveTo LIKE '' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @EndsWith
							AND ActiveTo LIKE '%' + @ActiveToVarchar + ''
							)
						)
					OR (
						(
							@Secondop5 = @IsEqualTo
							AND ActiveTo = @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsNotEqualTo
							AND ActiveTo <> @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsLessThan
							AND ActiveTo < @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsLessThanOrEqualTo
							AND ActiveTo <= @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsGreaterThan
							AND ActiveTo > @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsGreaterThanOrEqualTo
							AND ActiveTo >= @SecondActiveTo
							)
						OR (
							@Secondop5 = @Contains
							AND ActiveTo LIKE '%' + @SecondActiveToVarchar + '%'
							)
						OR (
							@Secondop5 = @DoesNotContain
							AND ActiveTo NOT LIKE '%' + @SecondActiveToVarchar + '%'
							)
						OR (
							@Secondop5 = @StartsWith
							AND ActiveTo LIKE '' + @SecondActiveToVarchar + '%'
							)
						OR (
							@Secondop5 = @EndsWith
							AND ActiveTo LIKE '%' + @SecondActiveToVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator5 = 'AND'
				AND (
					(
						(
							@op5 = @IsEqualTo
							AND ActiveTo = @ActiveTo
							)
						OR (
							@op5 = @IsNotEqualTo
							AND ActiveTo <> @ActiveTo
							)
						OR (
							@op5 = @IsLessThan
							AND ActiveTo < @ActiveTo
							)
						OR (
							@op5 = @IsLessThanOrEqualTo
							AND ActiveTo <= @ActiveTo
							)
						OR (
							@op5 = @IsGreaterThan
							AND ActiveTo > @ActiveTo
							)
						OR (
							@op5 = @IsGreaterThanOrEqualTo
							AND ActiveTo >= @ActiveTo
							)
						OR (
							@op5 = @Contains
							AND ActiveTo LIKE '%' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @DoesNotContain
							AND ActiveTo NOT LIKE '%' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @StartsWith
							AND ActiveTo LIKE '' + @ActiveToVarchar + '%'
							)
						OR (
							@op5 = @EndsWith
							AND ActiveTo LIKE '%' + @ActiveToVarchar + ''
							)
						)
					AND (
						(
							@Secondop5 = @IsEqualTo
							AND ActiveTo = @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsNotEqualTo
							AND ActiveTo <> @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsLessThan
							AND ActiveTo < @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsLessThanOrEqualTo
							AND ActiveTo <= @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsGreaterThan
							AND ActiveTo > @SecondActiveTo
							)
						OR (
							@Secondop5 = @IsGreaterThanOrEqualTo
							AND ActiveTo >= @SecondActiveTo
							)
						OR (
							@Secondop5 = @Contains
							AND ActiveTo LIKE '%' + @SecondActiveToVarchar + '%'
							)
						OR (
							@Secondop5 = @DoesNotContain
							AND ActiveTo NOT LIKE '%' + @SecondActiveToVarchar + '%'
							)
						OR (
							@Secondop5 = @StartsWith
							AND ActiveTo LIKE '' + @SecondActiveToVarchar + '%'
							)
						OR (
							@Secondop5 = @EndsWith
							AND ActiveTo LIKE '%' + @SecondActiveToVarchar + ''
							)
						)
					)
				)
			OR (
				@Secondop5 IS NULL
				AND (
					(
						@op5 = @IsEqualTo
						AND ActiveTo = @ActiveTo
						)
					OR (
						@op5 = @IsNotEqualTo
						AND ActiveTo <> @ActiveTo
						)
					OR (
						@op5 = @IsLessThan
						AND ActiveTo < @ActiveTo
						)
					OR (
						@op5 = @IsLessThanOrEqualTo
						AND ActiveTo <= @ActiveTo
						)
					OR (
						@op5 = @IsGreaterThan
						AND ActiveTo > @ActiveTo
						)
					OR (
						@op5 = @IsGreaterThanOrEqualTo
						AND ActiveTo >= @ActiveTo
						)
					OR (
						@op5 = @Contains
						AND ActiveTo LIKE '%' + @ActiveToVarchar + '%'
						)
					OR (
						@op5 = @DoesNotContain
						AND ActiveTo NOT LIKE '%' + @ActiveToVarchar + '%'
						)
					OR (
						@op5 = @StartsWith
						AND ActiveTo LIKE '' + @ActiveToVarchar + '%'
						)
					OR (
						@op5 = @EndsWith
						AND ActiveTo LIKE '%' + @ActiveToVarchar + ''
						)
					)
				)
			)
		AND (
			(@op6 IS NULL)
			OR (
				@op6 = @IsEqualTo
				AND convert(VARCHAR, Mandatory) = CASE @Mandatory
					WHEN 'True'
						THEN '1'
					ELSE '0'
					END
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'Code'
				AND @pOrderType = 'ASC'
				THEN Code
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Code'
				AND @pOrderType = 'DESC'
				THEN Code
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Name'
				AND @pOrderType = 'ASC'
				THEN Name
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Name'
				AND @pOrderType = 'DESC'
				THEN Name
			END DESC
		,CASE 
			WHEN @pOrderBy = 'TaskType'
				AND @pOrderType = 'ASC'
				THEN TaskType
			END ASC
		,CASE 
			WHEN @pOrderBy = 'TaskType'
				AND @pOrderType = 'DESC'
				THEN TaskType
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ActiveFrom'
				AND @pOrderType = 'ASC'
				THEN ActiveFrom
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ActiveFrom'
				AND @pOrderType = 'DESC'
				THEN ActiveFrom
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ActiveTo'
				AND @pOrderType = 'ASC'
				THEN ActiveTo
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ActiveTo'
				AND @pOrderType = 'DESC'
				THEN ActiveTo
			END DESC
		,CASE 
			WHEN @pOrderBy IS NULL
				THEN Name
			END DESC OFFSET @OFFSETRows rows

	FETCH NEXT @pPageSize rows ONLY
	OPTION (RECOMPILE)
END
