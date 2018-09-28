CREATE PROCEDURE [dbo].[GetQuestionnaireList] 
	@pCountryId UNIQUEIDENTIFIER
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
		,@op7 VARCHAR(50)
		,@op8 VARCHAR(50)
		,@op9 VARCHAR(50)
		,@op10 VARCHAR(50)
	DECLARE @LogicalOperator8 VARCHAR(5)
		,@Secondop8 VARCHAR(50)
		,@SecondCreationDate DATE
	DECLARE @QuestionnaireId INT
		,@SurveyName VARCHAR(500)
		,@ClientName VARCHAR(500)
		,@Comment VARCHAR(500)
		,@ClientTeamPerson VARCHAR(500)
		,@QuestionnaireType VARCHAR(50)
		,@Department VARCHAR(50)
		,@CreatedDate VARCHAR(500)
		,@Points VARCHAR(50)
		,@QuestionnaireLink VARCHAR(50)

	SELECT @op1 = Opertor
		,@QuestionnaireId = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Questionnaire_ID'

	SELECT @op2 = Opertor
		,@SurveyName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'SurveyName'

	SELECT @op3 = Opertor
		,@ClientName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'ClientName'

	SELECT @op4 = Opertor
		,@Comment = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Comment'

	SELECT @op5 = Opertor
		,@ClientTeamPerson = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'ClientTeamPerson'

	SELECT @op6 = Opertor
		,@QuestionnaireType = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'QuestionnaireType'

	SELECT @op7 = Opertor
		,@Department = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Department'

	SELECT @op8 = Opertor
		,@CreatedDate = CAST(ParameterValue AS DATE)
		,@Secondop8 = SecondParameterOperator
		,@SecondCreationDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator8 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'CreationTimestamp'

	SELECT @op9 = Opertor
		,@Points = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Points'

	SELECT @op10 = Opertor
		,@QuestionnaireLink = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'QuestionnaireLink'

	DECLARE @CreatedDateVarchar VARCHAR(100) = CAST(@CreatedDate AS VARCHAR)
		,@SecondCreationDateVarchar VARCHAR(100) = CAST(@SecondCreationDate AS VARCHAR)

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'Questionnaire_ID'

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
			SELECT Questionnaire_ID AS Questionnaire_ID
				,ClientTeamPerson AS ClientTeamPerson
				,SurveyName AS SurveyName
				,ClientName AS ClientName
				,Comment AS Comment
				,QuestionnaireType AS QuestionnaireType
				,Department AS Department
				,CAST(CreationTimestamp AS DATE) AS CreationTimestamp
				,Points AS Points
				,QuestionnaireLink AS QuestionnaireLink
			FROM dbo.Questionnaire
			WHERE Questionnaire_ID <> 0
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Questionnaire_ID = @QuestionnaireId
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Questionnaire_ID <> @QuestionnaireId
					)
				OR (
					@op1 = @IsLessThan
					AND Questionnaire_ID < @QuestionnaireId
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Questionnaire_ID <= @QuestionnaireId
					)
				OR (
					@op1 = @IsGreaterThan
					AND Questionnaire_ID > @QuestionnaireId
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Questionnaire_ID >= @QuestionnaireId
					)
				OR (
					@op1 = @Contains
					AND Questionnaire_ID LIKE '%' + @QuestionnaireId + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Questionnaire_ID NOT LIKE '%' + @QuestionnaireId + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Questionnaire_ID LIKE '' + @QuestionnaireId + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Questionnaire_ID LIKE '%' + @QuestionnaireId + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND SurveyName = @SurveyName
					)
				OR (
					@op2 = @IsNotEqualTo
					AND SurveyName <> @SurveyName
					)
				OR (
					@op2 = @IsLessThan
					AND SurveyName < @SurveyName
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND SurveyName <= @SurveyName
					)
				OR (
					@op2 = @IsGreaterThan
					AND SurveyName > @SurveyName
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND SurveyName >= @SurveyName
					)
				OR (
					@op2 = @Contains
					AND SurveyName LIKE '%' + @SurveyName + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND SurveyName NOT LIKE '%' + @SurveyName + '%'
					)
				OR (
					@op2 = @StartsWith
					AND SurveyName LIKE '' + @SurveyName + '%'
					)
				OR (
					@op2 = @EndsWith
					AND SurveyName LIKE '%' + @SurveyName + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND ClientName = @ClientName
					)
				OR (
					@op3 = @IsNotEqualTo
					AND ClientName <> @ClientName
					)
				OR (
					@op3 = @IsLessThan
					AND ClientName < @ClientName
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND ClientName <= @ClientName
					)
				OR (
					@op3 = @IsGreaterThan
					AND ClientName > @ClientName
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND ClientName >= @ClientName
					)
				OR (
					@op3 = @Contains
					AND ClientName LIKE '%' + @ClientName + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND ClientName NOT LIKE '%' + @ClientName + '%'
					)
				OR (
					@op3 = @StartsWith
					AND ClientName LIKE '' + @ClientName + '%'
					)
				OR (
					@op3 = @EndsWith
					AND ClientName LIKE '%' + @ClientName + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND Comment = @Comment
					)
				OR (
					@op4 = @IsNotEqualTo
					AND Comment <> @Comment
					)
				OR (
					@op4 = @IsLessThan
					AND Comment < @Comment
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND Comment <= @Comment
					)
				OR (
					@op4 = @IsGreaterThan
					AND Comment > @Comment
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND Comment >= @Comment
					)
				OR (
					@op4 = @Contains
					AND Comment LIKE '%' + @Comment + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND Comment NOT LIKE '%' + @Comment + '%'
					)
				OR (
					@op4 = @StartsWith
					AND Comment LIKE '' + @Comment + '%'
					)
				OR (
					@op4 = @EndsWith
					AND Comment LIKE '%' + @Comment + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND ClientTeamPerson = @ClientTeamPerson
					)
				OR (
					@op5 = @IsNotEqualTo
					AND ClientTeamPerson <> @ClientTeamPerson
					)
				OR (
					@op5 = @IsLessThan
					AND ClientTeamPerson < @ClientTeamPerson
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND ClientTeamPerson <= @ClientTeamPerson
					)
				OR (
					@op5 = @IsGreaterThan
					AND ClientTeamPerson > @ClientTeamPerson
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND ClientTeamPerson >= @ClientTeamPerson
					)
				OR (
					@op5 = @Contains
					AND ClientTeamPerson LIKE '%' + @ClientTeamPerson + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND ClientTeamPerson NOT LIKE '%' + @ClientTeamPerson + '%'
					)
				OR (
					@op5 = @StartsWith
					AND ClientTeamPerson LIKE '' + @ClientTeamPerson + '%'
					)
				OR (
					@op5 = @EndsWith
					AND ClientTeamPerson LIKE '%' + @ClientTeamPerson + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND QuestionnaireType = @QuestionnaireType
					)
				OR (
					@op6 = @IsNotEqualTo
					AND QuestionnaireType <> @QuestionnaireType
					)
				OR (
					@op6 = @IsLessThan
					AND QuestionnaireType < @QuestionnaireType
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND QuestionnaireType <= @QuestionnaireType
					)
				OR (
					@op6 = @IsGreaterThan
					AND QuestionnaireType > @QuestionnaireType
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND QuestionnaireType >= @QuestionnaireType
					)
				OR (
					@op6 = @Contains
					AND QuestionnaireType LIKE '%' + @QuestionnaireType + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND QuestionnaireType NOT LIKE '%' + @QuestionnaireType + '%'
					)
				OR (
					@op6 = @StartsWith
					AND QuestionnaireType LIKE '' + @QuestionnaireType + '%'
					)
				OR (
					@op6 = @EndsWith
					AND QuestionnaireType LIKE '%' + @QuestionnaireType + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND Department = @Department
					)
				OR (
					@op7 = @IsNotEqualTo
					AND Department <> @Department
					)
				OR (
					@op7 = @IsLessThan
					AND Department < @Department
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND Department <= @Department
					)
				OR (
					@op7 = @IsGreaterThan
					AND Department > @Department
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND Department >= @Department
					)
				OR (
					@op7 = @Contains
					AND Department LIKE '%' + @Department + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND Department NOT LIKE '%' + @Department + '%'
					)
				OR (
					@op7 = @StartsWith
					AND Department LIKE '' + @Department + '%'
					)
				OR (
					@op7 = @EndsWith
					AND Department LIKE '%' + @Department + ''
					)
				)
			AND (
				(@op8 IS NULL)
				OR (
					@op8 IS NULL
					AND @LogicalOperator8 IS NULL
					)
				OR (
					@LogicalOperator8 = 'OR'
					AND (
						(
							(
								@op8 = @IsEqualTo
								AND CreationTimestamp = @CreatedDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND CreationTimestamp <> @CreatedDate
								)
							OR (
								@op8 = @IsLessThan
								AND CreationTimestamp < @CreatedDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND CreationTimestamp <= @CreatedDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND CreationTimestamp > @CreatedDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND CreationTimestamp >= @CreatedDate
								)
							OR (
								@op8 = @Contains
								AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND CreationTimestamp NOT LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND CreationTimestamp LIKE '' + @CreatedDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop8 = @IsEqualTo
								AND CreationTimestamp = @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND CreationTimestamp <> @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND CreationTimestamp < @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND CreationTimestamp <= @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND CreationTimestamp > @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND CreationTimestamp >= @SecondCreationDate
								)
							OR (
								@Secondop8 = @Contains
								AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND CreationTimestamp NOT LIKE '%' + @SecondCreationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND CreationTimestamp LIKE '' + @SecondCreationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator8 = 'AND'
					AND (
						(
							(
								@op8 = @IsEqualTo
								AND CreationTimestamp = @CreatedDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND CreationTimestamp <> @CreatedDate
								)
							OR (
								@op8 = @IsLessThan
								AND CreationTimestamp < @CreatedDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND CreationTimestamp <= @CreatedDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND CreationTimestamp > @CreatedDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND CreationTimestamp >= @CreatedDate
								)
							OR (
								@op8 = @Contains
								AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND CreationTimestamp NOT LIKE '%' + @CreatedDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND CreationTimestamp LIKE '' + @CreatedDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop8 = @IsEqualTo
								AND CreationTimestamp = @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND CreationTimestamp <> @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND CreationTimestamp < @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND CreationTimestamp <= @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND CreationTimestamp > @SecondCreationDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND CreationTimestamp >= @SecondCreationDate
								)
							OR (
								@Secondop8 = @Contains
								AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND CreationTimestamp NOT LIKE '%' + @SecondCreationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND CreationTimestamp LIKE '' + @SecondCreationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop8 IS NULL
					AND (
						(
							@op8 = @IsEqualTo
							AND CreationTimestamp = @CreatedDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND CreationTimestamp <> @CreatedDate
							)
						OR (
							@op8 = @IsLessThan
							AND CreationTimestamp < @CreatedDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND CreationTimestamp <= @CreatedDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND CreationTimestamp > @CreatedDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND CreationTimestamp >= @CreatedDate
							)
						OR (
							@op8 = @Contains
							AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND CreationTimestamp NOT LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND CreationTimestamp LIKE '' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op9 IS NULL)
				OR (
					@op9 = @IsEqualTo
					AND Points = @Points
					)
				OR (
					@op9 = @IsNotEqualTo
					AND Points <> @Points
					)
				OR (
					@op9 = @IsLessThan
					AND Points < @Points
					)
				OR (
					@op9 = @IsLessThanOrEqualTo
					AND Points <= @Points
					)
				OR (
					@op9 = @IsGreaterThan
					AND Points > @Points
					)
				OR (
					@op9 = @IsGreaterThanOrEqualTo
					AND Points >= @Points
					)
				OR (
					@op9 = @Contains
					AND Points LIKE '%' + @Points + '%'
					)
				OR (
					@op9 = @DoesNotContain
					AND Points NOT LIKE '%' + @Points + '%'
					)
				OR (
					@op9 = @StartsWith
					AND Points LIKE '' + @Points + '%'
					)
				OR (
					@op9 = @EndsWith
					AND Points LIKE '%' + @Points + ''
					)
				)
			AND (
				(@op10 IS NULL)
				OR (
					@op10 = @IsEqualTo
					AND QuestionnaireLink = @QuestionnaireLink
					)
				OR (
					@op10 = @IsNotEqualTo
					AND QuestionnaireLink <> @QuestionnaireLink
					)
				OR (
					@op10 = @IsLessThan
					AND QuestionnaireLink < @QuestionnaireLink
					)
				OR (
					@op10 = @IsLessThanOrEqualTo
					AND QuestionnaireLink <= @QuestionnaireLink
					)
				OR (
					@op10 = @IsGreaterThan
					AND QuestionnaireLink > @QuestionnaireLink
					)
				OR (
					@op10 = @IsGreaterThanOrEqualTo
					AND QuestionnaireLink >= @QuestionnaireLink
					)
				OR (
					@op10 = @Contains
					AND QuestionnaireLink LIKE '%' + @QuestionnaireLink + '%'
					)
				OR (
					@op10 = @DoesNotContain
					AND QuestionnaireLink NOT LIKE '%' + @QuestionnaireLink + '%'
					)
				OR (
					@op10 = @StartsWith
					AND QuestionnaireLink LIKE '' + @QuestionnaireLink + '%'
					)
				OR (
					@op10 = @EndsWith
					AND QuestionnaireLink LIKE '%' + @QuestionnaireLink + ''
					)
				)
		OPTION (RECOMPILE)
	END

	SELECT *
	FROM (
		SELECT Questionnaire_ID AS Questionnaire_ID
			,ClientTeamPerson AS ClientTeamPerson
			,SurveyName AS SurveyName
			,ClientName AS ClientName
			,Comment AS Comment
			,QuestionnaireType AS QuestionnaireType
			,Department AS Department
			,CAST(CreationTimestamp AS DATE) AS CreationTimestamp
			,Points AS Points
			,QuestionnaireLink AS QuestionnaireLink
		FROM dbo.Questionnaire
		WHERE Questionnaire_ID <> 0
		) AS TEMPTABLE
	WHERE (
			(@op1 IS NULL)
			OR (
				@op1 = @IsEqualTo
				AND Questionnaire_ID = @QuestionnaireId
				)
			OR (
				@op1 = @IsNotEqualTo
				AND Questionnaire_ID <> @QuestionnaireId
				)
			OR (
				@op1 = @IsLessThan
				AND Questionnaire_ID < @QuestionnaireId
				)
			OR (
				@op1 = @IsLessThanOrEqualTo
				AND Questionnaire_ID <= @QuestionnaireId
				)
			OR (
				@op1 = @IsGreaterThan
				AND Questionnaire_ID > @QuestionnaireId
				)
			OR (
				@op1 = @IsGreaterThanOrEqualTo
				AND Questionnaire_ID >= @QuestionnaireId
				)
			OR (
				@op1 = @Contains
				AND Questionnaire_ID LIKE '%' + @QuestionnaireId + '%'
				)
			OR (
				@op1 = @DoesNotContain
				AND Questionnaire_ID NOT LIKE '%' + @QuestionnaireId + '%'
				)
			OR (
				@op1 = @StartsWith
				AND Questionnaire_ID LIKE '' + @QuestionnaireId + '%'
				)
			OR (
				@op1 = @EndsWith
				AND Questionnaire_ID LIKE '%' + @QuestionnaireId + ''
				)
			)
		AND (
			(@op2 IS NULL)
			OR (
				@op2 = @IsEqualTo
				AND SurveyName = @SurveyName
				)
			OR (
				@op2 = @IsNotEqualTo
				AND SurveyName <> @SurveyName
				)
			OR (
				@op2 = @IsLessThan
				AND SurveyName < @SurveyName
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND SurveyName <= @SurveyName
				)
			OR (
				@op2 = @IsGreaterThan
				AND SurveyName > @SurveyName
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND SurveyName >= @SurveyName
				)
			OR (
				@op2 = @Contains
				AND SurveyName LIKE '%' + @SurveyName + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND SurveyName NOT LIKE '%' + @SurveyName + '%'
				)
			OR (
				@op2 = @StartsWith
				AND SurveyName LIKE '' + @SurveyName + '%'
				)
			OR (
				@op2 = @EndsWith
				AND SurveyName LIKE '%' + @SurveyName + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 = @IsEqualTo
				AND ClientName = @ClientName
				)
			OR (
				@op3 = @IsNotEqualTo
				AND ClientName <> @ClientName
				)
			OR (
				@op3 = @IsLessThan
				AND ClientName < @ClientName
				)
			OR (
				@op3 = @IsLessThanOrEqualTo
				AND ClientName <= @ClientName
				)
			OR (
				@op3 = @IsGreaterThan
				AND ClientName > @ClientName
				)
			OR (
				@op3 = @IsGreaterThanOrEqualTo
				AND ClientName >= @ClientName
				)
			OR (
				@op3 = @Contains
				AND ClientName LIKE '%' + @ClientName + '%'
				)
			OR (
				@op3 = @DoesNotContain
				AND ClientName NOT LIKE '%' + @ClientName + '%'
				)
			OR (
				@op3 = @StartsWith
				AND ClientName LIKE '' + @ClientName + '%'
				)
			OR (
				@op3 = @EndsWith
				AND ClientName LIKE '%' + @ClientName + ''
				)
			)
		AND (
			(@op4 IS NULL)
			OR (
				@op4 = @IsEqualTo
				AND Comment = @Comment
				)
			OR (
				@op4 = @IsNotEqualTo
				AND Comment <> @Comment
				)
			OR (
				@op4 = @IsLessThan
				AND Comment < @Comment
				)
			OR (
				@op4 = @IsLessThanOrEqualTo
				AND Comment <= @Comment
				)
			OR (
				@op4 = @IsGreaterThan
				AND Comment > @Comment
				)
			OR (
				@op4 = @IsGreaterThanOrEqualTo
				AND Comment >= @Comment
				)
			OR (
				@op4 = @Contains
				AND Comment LIKE '%' + @Comment + '%'
				)
			OR (
				@op4 = @DoesNotContain
				AND Comment NOT LIKE '%' + @Comment + '%'
				)
			OR (
				@op4 = @StartsWith
				AND Comment LIKE '' + @Comment + '%'
				)
			OR (
				@op4 = @EndsWith
				AND Comment LIKE '%' + @Comment + ''
				)
			)
		AND (
			(@op5 IS NULL)
			OR (
				@op5 = @IsEqualTo
				AND ClientTeamPerson = @ClientTeamPerson
				)
			OR (
				@op5 = @IsNotEqualTo
				AND ClientTeamPerson <> @ClientTeamPerson
				)
			OR (
				@op5 = @IsLessThan
				AND ClientTeamPerson < @ClientTeamPerson
				)
			OR (
				@op5 = @IsLessThanOrEqualTo
				AND ClientTeamPerson <= @ClientTeamPerson
				)
			OR (
				@op5 = @IsGreaterThan
				AND ClientTeamPerson > @ClientTeamPerson
				)
			OR (
				@op5 = @IsGreaterThanOrEqualTo
				AND ClientTeamPerson >= @ClientTeamPerson
				)
			OR (
				@op5 = @Contains
				AND ClientTeamPerson LIKE '%' + @ClientTeamPerson + '%'
				)
			OR (
				@op5 = @DoesNotContain
				AND ClientTeamPerson NOT LIKE '%' + @ClientTeamPerson + '%'
				)
			OR (
				@op5 = @StartsWith
				AND ClientTeamPerson LIKE '' + @ClientTeamPerson + '%'
				)
			OR (
				@op5 = @EndsWith
				AND ClientTeamPerson LIKE '%' + @ClientTeamPerson + ''
				)
			)
		AND (
			(@op6 IS NULL)
			OR (
				@op6 = @IsEqualTo
				AND QuestionnaireType = @QuestionnaireType
				)
			OR (
				@op6 = @IsNotEqualTo
				AND QuestionnaireType <> @QuestionnaireType
				)
			OR (
				@op6 = @IsLessThan
				AND QuestionnaireType < @QuestionnaireType
				)
			OR (
				@op6 = @IsLessThanOrEqualTo
				AND QuestionnaireType <= @QuestionnaireType
				)
			OR (
				@op6 = @IsGreaterThan
				AND QuestionnaireType > @QuestionnaireType
				)
			OR (
				@op6 = @IsGreaterThanOrEqualTo
				AND QuestionnaireType >= @QuestionnaireType
				)
			OR (
				@op6 = @Contains
				AND QuestionnaireType LIKE '%' + @QuestionnaireType + '%'
				)
			OR (
				@op6 = @DoesNotContain
				AND QuestionnaireType NOT LIKE '%' + @QuestionnaireType + '%'
				)
			OR (
				@op6 = @StartsWith
				AND QuestionnaireType LIKE '' + @QuestionnaireType + '%'
				)
			OR (
				@op6 = @EndsWith
				AND QuestionnaireType LIKE '%' + @QuestionnaireType + ''
				)
			)
		AND (
			(@op7 IS NULL)
			OR (
				@op7 = @IsEqualTo
				AND Department = @Department
				)
			OR (
				@op7 = @IsNotEqualTo
				AND Department <> @Department
				)
			OR (
				@op7 = @IsLessThan
				AND Department < @Department
				)
			OR (
				@op7 = @IsLessThanOrEqualTo
				AND Department <= @Department
				)
			OR (
				@op7 = @IsGreaterThan
				AND Department > @Department
				)
			OR (
				@op7 = @IsGreaterThanOrEqualTo
				AND Department >= @Department
				)
			OR (
				@op7 = @Contains
				AND Department LIKE '%' + @Department + '%'
				)
			OR (
				@op7 = @DoesNotContain
				AND Department NOT LIKE '%' + @Department + '%'
				)
			OR (
				@op7 = @StartsWith
				AND Department LIKE '' + @Department + '%'
				)
			OR (
				@op7 = @EndsWith
				AND Department LIKE '%' + @Department + ''
				)
			)
		AND (
			(@op8 IS NULL)
			OR (
				@op8 IS NULL
				AND @LogicalOperator8 IS NULL
				)
			OR (
				@LogicalOperator8 = 'OR'
				AND (
					(
						(
							@op8 = @IsEqualTo
							AND CreationTimestamp = @CreatedDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND CreationTimestamp <> @CreatedDate
							)
						OR (
							@op8 = @IsLessThan
							AND CreationTimestamp < @CreatedDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND CreationTimestamp <= @CreatedDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND CreationTimestamp > @CreatedDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND CreationTimestamp >= @CreatedDate
							)
						OR (
							@op8 = @Contains
							AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND CreationTimestamp NOT LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND CreationTimestamp LIKE '' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + ''
							)
						)
					OR (
						(
							@Secondop8 = @IsEqualTo
							AND CreationTimestamp = @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsNotEqualTo
							AND CreationTimestamp <> @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsLessThan
							AND CreationTimestamp < @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsLessThanOrEqualTo
							AND CreationTimestamp <= @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsGreaterThan
							AND CreationTimestamp > @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsGreaterThanOrEqualTo
							AND CreationTimestamp >= @SecondCreationDate
							)
						OR (
							@Secondop8 = @Contains
							AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @DoesNotContain
							AND CreationTimestamp NOT LIKE '%' + @SecondCreationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @StartsWith
							AND CreationTimestamp LIKE '' + @SecondCreationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @EndsWith
							AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator8 = 'AND'
				AND (
					(
						(
							@op8 = @IsEqualTo
							AND CreationTimestamp = @CreatedDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND CreationTimestamp <> @CreatedDate
							)
						OR (
							@op8 = @IsLessThan
							AND CreationTimestamp < @CreatedDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND CreationTimestamp <= @CreatedDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND CreationTimestamp > @CreatedDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND CreationTimestamp >= @CreatedDate
							)
						OR (
							@op8 = @Contains
							AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND CreationTimestamp NOT LIKE '%' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND CreationTimestamp LIKE '' + @CreatedDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + ''
							)
						)
					AND (
						(
							@Secondop8 = @IsEqualTo
							AND CreationTimestamp = @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsNotEqualTo
							AND CreationTimestamp <> @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsLessThan
							AND CreationTimestamp < @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsLessThanOrEqualTo
							AND CreationTimestamp <= @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsGreaterThan
							AND CreationTimestamp > @SecondCreationDate
							)
						OR (
							@Secondop8 = @IsGreaterThanOrEqualTo
							AND CreationTimestamp >= @SecondCreationDate
							)
						OR (
							@Secondop8 = @Contains
							AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @DoesNotContain
							AND CreationTimestamp NOT LIKE '%' + @SecondCreationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @StartsWith
							AND CreationTimestamp LIKE '' + @SecondCreationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @EndsWith
							AND CreationTimestamp LIKE '%' + @SecondCreationDateVarchar + ''
							)
						)
					)
				)
			OR (
				@Secondop8 IS NULL
				AND (
					(
						@op8 = @IsEqualTo
						AND CreationTimestamp = @CreatedDate
						)
					OR (
						@op8 = @IsNotEqualTo
						AND CreationTimestamp <> @CreatedDate
						)
					OR (
						@op8 = @IsLessThan
						AND CreationTimestamp < @CreatedDate
						)
					OR (
						@op8 = @IsLessThanOrEqualTo
						AND CreationTimestamp <= @CreatedDate
						)
					OR (
						@op8 = @IsGreaterThan
						AND CreationTimestamp > @CreatedDate
						)
					OR (
						@op8 = @IsGreaterThanOrEqualTo
						AND CreationTimestamp >= @CreatedDate
						)
					OR (
						@op8 = @Contains
						AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + '%'
						)
					OR (
						@op8 = @DoesNotContain
						AND CreationTimestamp NOT LIKE '%' + @CreatedDateVarchar + '%'
						)
					OR (
						@op8 = @StartsWith
						AND CreationTimestamp LIKE '' + @CreatedDateVarchar + '%'
						)
					OR (
						@op8 = @EndsWith
						AND CreationTimestamp LIKE '%' + @CreatedDateVarchar + ''
						)
					)
				)
			)
		AND (
			(@op9 IS NULL)
			OR (
				@op9 = @IsEqualTo
				AND Points = @Points
				)
			OR (
				@op9 = @IsNotEqualTo
				AND Points <> @Points
				)
			OR (
				@op9 = @IsLessThan
				AND Points < @Points
				)
			OR (
				@op9 = @IsLessThanOrEqualTo
				AND Points <= @Points
				)
			OR (
				@op9 = @IsGreaterThan
				AND Points > @Points
				)
			OR (
				@op9 = @IsGreaterThanOrEqualTo
				AND Points >= @Points
				)
			OR (
				@op9 = @Contains
				AND Points LIKE '%' + @Points + '%'
				)
			OR (
				@op9 = @DoesNotContain
				AND Points NOT LIKE '%' + @Points + '%'
				)
			OR (
				@op9 = @StartsWith
				AND Points LIKE '' + @Points + '%'
				)
			OR (
				@op9 = @EndsWith
				AND Points LIKE '%' + @Points + ''
				)
			)
		AND (
			(@op10 IS NULL)
			OR (
				@op10 = @IsEqualTo
				AND QuestionnaireLink = @QuestionnaireLink
				)
			OR (
				@op10 = @IsNotEqualTo
				AND QuestionnaireLink <> @QuestionnaireLink
				)
			OR (
				@op10 = @IsLessThan
				AND QuestionnaireLink < @QuestionnaireLink
				)
			OR (
				@op10 = @IsLessThanOrEqualTo
				AND QuestionnaireLink <= @QuestionnaireLink
				)
			OR (
				@op10 = @IsGreaterThan
				AND QuestionnaireLink > @QuestionnaireLink
				)
			OR (
				@op10 = @IsGreaterThanOrEqualTo
				AND QuestionnaireLink >= @QuestionnaireLink
				)
			OR (
				@op10 = @Contains
				AND QuestionnaireLink LIKE '%' + @QuestionnaireLink + '%'
				)
			OR (
				@op10 = @DoesNotContain
				AND QuestionnaireLink NOT LIKE '%' + @QuestionnaireLink + '%'
				)
			OR (
				@op10 = @StartsWith
				AND QuestionnaireLink LIKE '' + @QuestionnaireLink + '%'
				)
			OR (
				@op10 = @EndsWith
				AND QuestionnaireLink LIKE '%' + @QuestionnaireLink + ''
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'Questionnaire_ID'
				AND @pOrderType = 'ASC'
				THEN Questionnaire_ID
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Questionnaire_ID'
				AND @pOrderType = 'DESC'
				THEN Questionnaire_ID
			END DESC
		,CASE 
			WHEN @pOrderBy = 'SurveyName'
				AND @pOrderType = 'ASC'
				THEN SurveyName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'SurveyName'
				AND @pOrderType = 'DESC'
				THEN SurveyName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ClientName'
				AND @pOrderType = 'ASC'
				THEN ClientName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ClientName'
				AND @pOrderType = 'DESC'
				THEN ClientName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'CreationTimestamp'
				AND @pOrderType = 'ASC'
				THEN CreationTimestamp
			END ASC
		,CASE 
			WHEN @pOrderBy = 'CreationTimestamp'
				AND @pOrderType = 'DESC'
				THEN CreationTimestamp
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ClientTeamPerson'
				AND @pOrderType = 'ASC'
				THEN ClientTeamPerson
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ClientTeamPerson'
				AND @pOrderType = 'DESC'
				THEN ClientTeamPerson
			END DESC
		,CASE 
			WHEN @pOrderBy = 'QuestionnaireType'
				AND @pOrderType = 'ASC'
				THEN QuestionnaireType
			END ASC
		,CASE 
			WHEN @pOrderBy = 'QuestionnaireType'
				AND @pOrderType = 'DESC'
				THEN QuestionnaireType
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Department'
				AND @pOrderType = 'ASC'
				THEN Department
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Department'
				AND @pOrderType = 'DESC'
				THEN Department
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Points'
				AND @pOrderType = 'ASC'
				THEN Points
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Points'
				AND @pOrderType = 'DESC'
				THEN Points
			END DESC
		,CASE 
			WHEN @pOrderBy = 'QuestionnaireLink'
				AND @pOrderType = 'ASC'
				THEN QuestionnaireLink
			END ASC
		,CASE 
			WHEN @pOrderBy = 'QuestionnaireLink'
				AND @pOrderType = 'DESC'
				THEN QuestionnaireLink
			END DESC OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)
END

GO


