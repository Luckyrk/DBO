CREATE PROCEDURE [dbo].[FR_GetQuestionnaireTransactionList] @pIndividualId UNIQUEIDENTIFIER
	,@pBusinessId VARCHAR(100)
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
		,@op7 VARCHAR(50)
		,@op8 VARCHAR(50)
		,@op9 VARCHAR(50)
		,@op10 VARCHAR(50)
		,@op11 VARCHAR(50)
		,@op12 VARCHAR(50)
		,@op13 VARCHAR(50)
		,@op14 VARCHAR(50)
	DECLARE @LogicalOperator8 VARCHAR(5)
		,@Secondop8 VARCHAR(50)
		,@SecondInvitationDate DATE
	DECLARE @QuestionnaireId INT
		,@QuestionnaireName VARCHAR(500)
		,@ID INT
		,@QuestionnaireType VARCHAR(500)
		,@Service VARCHAR(500)
		,@Name VARCHAR(500)
		,@Status VARCHAR(500)
		,@InvitationDate VARCHAR(500)
		,@CompletionDate VARCHAR(500)
		,@NumberofDays INT
		,@CollaborationType VARCHAR(500)
		,@UID NVARCHAR(200)
		,@InterviewerID BIGINT
		,@QuestionnaireLink NVARCHAR(500)

	SELECT @op1 = Opertor
		,@QuestionnaireId = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Questionnaire_ID'

	SELECT @op2 = Opertor
		,@QuestionnaireName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'QuestionnaireName'

	SELECT @op3 = Opertor
		,@ID = CAST(ParameterValue AS INT)
	FROM @pParametersTable
	WHERE ParameterName = 'ID'

	SELECT @op4 = Opertor
		,@QuestionnaireType = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'QuestionnaireType'

	SELECT @op5 = Opertor
		,@Service = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Service'

	SELECT @op6 = Opertor
		,@Name = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Name'

	SELECT @op7 = Opertor
		,@Status = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Status'

	SELECT @op8 = Opertor
		,@InvitationDate = CAST(ParameterValue AS DATE)
		,@Secondop8 = SecondParameterOperator
		,@SecondInvitationDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator8 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'InvitationDate'

	SELECT @op9 = Opertor
		,@CompletionDate = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'CompletionDate'

	SELECT @op10 = Opertor
		,@NumberofDays = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'NumberofDays'

	SELECT @op11 = Opertor
		,@CollaborationType = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'CollaborationType'

	SELECT @op12 = Opertor
		,@UID = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'UID'

	SELECT @op13 = Opertor
		,@InterviewerID = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'InterviewerID'

	SELECT @op14 = Opertor
		,@InterviewerID = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'QuestionnaireLink'

	DECLARE @InvitationDateVarchar VARCHAR(100) = CAST(@InvitationDate AS VARCHAR)
		,@SecondInvitationDateVarchar VARCHAR(100) = CAST(@SecondInvitationDate AS VARCHAR)

	IF (@pOrderBy IS NULL OR @pOrderBy='InvitationDatestring' OR @pOrderBy='CreationTimeStamp')
	BEGIN
		SET @pOrderBy = 'InvitationDate'
	END
		IF(@pOrderBy='InvitationDatestring')
		SET @pOrderBy = 'InvitationDate'

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
			SELECT *
			FROM (
				SELECT FRT.QuestionnaireTransactionID AS Questionnaire_ID
					,isnull(FRT.PanelistName, isnull(PR.FirstOrderedName, ' ') + ' ' + isnull(PR.MiddleOrderedName, ' ') + ' ' + isnull(PR.LastOrderedName, ' ')) AS NAME
					,FR.SurveyName AS QuestionnaireName
					,FRT.QuestionnaireID AS ID
					,FR.QuestionnaireType AS QuestionnaireType
					,FR.CollaborationType AS CollaborationType
					,FR.ClientTeamPerson AS [Service]
					,CAST(FRT.InvitationDate AS DATE) AS [InvitationDate]
					,STD.Code AS [Status]
					,FRT.CompletionDate AS CompletionDate
					,FRT.NumberofDays AS NumberofDays
					,FRT.[UID] AS [UID]
					,FRT.InterviewerId AS InterviewerID
					,REPLACE(FR.QuestionnaireLink,'/@temp','') AS [QuestionnaireLink]
				FROM dbo.QuestionnaireTransaction FRT
				INNER JOIN dbo.Questionnaire FR ON FRT.QuestionnaireID = FR.Questionnaire_ID
				INNER JOIN StateDefinition STD ON FRT.StateId = STD.Id
				INNER JOIN Panelist PN ON PN.GUIDreference = FRT.PanelistId
				INNER JOIN Individual IND ON IND.GUIDReference = PN.PanelMember_Id
				INNER JOIN PersonalIdentification PR ON PR.PersonalIdentificationId = IND.PersonalIdentificationId
				WHERE Questionnaire_ID <> 0
					AND IND.IndividualId = @pBusinessId
				
				UNION
				
				SELECT FRT.QuestionnaireTransactionID AS Questionnaire_ID
					,isnull(FRT.PanelistName, isnull(PR.FirstOrderedName, ' ') + ' ' + isnull(PR.MiddleOrderedName, ' ') + ' ' + isnull(PR.LastOrderedName, ' ')) AS NAME
					,FR.SurveyName AS QuestionnaireName
					,FRT.QuestionnaireID AS ID
					,FR.QuestionnaireType AS QuestionnaireType
					,FR.CollaborationType AS CollaborationType
					,FR.ClientTeamPerson AS [Service]
					,CAST(FRT.InvitationDate AS DATE) AS [InvitationDate]
					,STD.Code AS [Status]
					,FRT.CompletionDate AS CompletionDate
					,FRT.NumberofDays AS NumberofDays
					,FRT.[UID] AS [UID]
					,FRT.InterviewerId AS InterviewerID
					,REPLACE(FR.QuestionnaireLink,'/@temp','') AS [QuestionnaireLink]
				FROM dbo.QuestionnaireTransaction FRT
				INNER JOIN dbo.Questionnaire FR ON FRT.QuestionnaireID = FR.Questionnaire_ID
				INNER JOIN StateDefinition STD ON FRT.StateId = STD.Id
				INNER JOIN Individual IND ON IND.GUIDReference = FRT.IndividualID
				INNER JOIN PersonalIdentification PR ON PR.PersonalIdentificationId = IND.PersonalIdentificationId
				WHERE Questionnaire_ID <> 0
					AND IND.IndividualId = @pBusinessId
				) T
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
					AND QuestionnaireName = @QuestionnaireName
					)
				OR (
					@op2 = @IsNotEqualTo
					AND QuestionnaireName <> @QuestionnaireName
					)
				OR (
					@op2 = @IsLessThan
					AND QuestionnaireName < @QuestionnaireName
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND QuestionnaireName <= @QuestionnaireName
					)
				OR (
					@op2 = @IsGreaterThan
					AND QuestionnaireName > @QuestionnaireName
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND QuestionnaireName >= @QuestionnaireName
					)
				OR (
					@op2 = @Contains
					AND QuestionnaireName LIKE '%' + @QuestionnaireName + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND QuestionnaireName NOT LIKE '%' + @QuestionnaireName + '%'
					)
				OR (
					@op2 = @StartsWith
					AND QuestionnaireName LIKE '' + @QuestionnaireName + '%'
					)
				OR (
					@op2 = @EndsWith
					AND QuestionnaireName LIKE '%' + @QuestionnaireName + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND ID = @ID
					)
				OR (
					@op3 = @IsNotEqualTo
					AND ID <> @ID
					)
				OR (
					@op3 = @IsLessThan
					AND ID < @ID
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND ID <= @ID
					)
				OR (
					@op3 = @IsGreaterThan
					AND ID > @ID
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND ID >= @ID
					)
				OR (
					@op3 = @Contains
					AND ID LIKE '%' + CAST(@ID AS VARCHAR) + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND ID NOT LIKE '%' + CAST(@ID AS VARCHAR) + '%'
					)
				OR (
					@op3 = @StartsWith
					AND ID LIKE '' + CAST(@ID AS VARCHAR) + '%'
					)
				OR (
					@op3 = @EndsWith
					AND ID LIKE '%' + CAST(@ID AS VARCHAR) + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND QuestionnaireType = @QuestionnaireType
					)
				OR (
					@op4 = @IsNotEqualTo
					AND QuestionnaireType <> @QuestionnaireType
					)
				OR (
					@op4 = @IsLessThan
					AND QuestionnaireType < @QuestionnaireType
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND QuestionnaireType <= @QuestionnaireType
					)
				OR (
					@op4 = @IsGreaterThan
					AND QuestionnaireType > @QuestionnaireType
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND QuestionnaireType >= @QuestionnaireType
					)
				OR (
					@op4 = @Contains
					AND QuestionnaireType LIKE '%' + @QuestionnaireType + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND QuestionnaireType NOT LIKE '%' + @QuestionnaireType + '%'
					)
				OR (
					@op4 = @StartsWith
					AND QuestionnaireType LIKE '' + @QuestionnaireType + '%'
					)
				OR (
					@op4 = @EndsWith
					AND QuestionnaireType LIKE '%' + @QuestionnaireType + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND [Service] = @Service
					)
				OR (
					@op5 = @IsNotEqualTo
					AND [Service] <> @Service
					)
				OR (
					@op5 = @IsLessThan
					AND [Service] < @Service
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND [Service] <= @Service
					)
				OR (
					@op5 = @IsGreaterThan
					AND [Service] > @Service
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND [Service] >= @Service
					)
				OR (
					@op5 = @Contains
					AND [Service] LIKE '%' + @Service + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND [Service] NOT LIKE '%' + @Service + '%'
					)
				OR (
					@op5 = @StartsWith
					AND [Service] LIKE '' + @Service + '%'
					)
				OR (
					@op5 = @EndsWith
					AND [Service] LIKE '%' + @Service + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND NAME = @Name
					)
				OR (
					@op6 = @IsNotEqualTo
					AND NAME <> @Name
					)
				OR (
					@op6 = @IsLessThan
					AND NAME < @Name
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND NAME <= @Name
					)
				OR (
					@op6 = @IsGreaterThan
					AND NAME > @Name
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND NAME >= @Name
					)
				OR (
					@op6 = @Contains
					AND NAME LIKE '%' + @Name + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND NAME NOT LIKE '%' + @Name + '%'
					)
				OR (
					@op6 = @StartsWith
					AND NAME LIKE '' + @Name + '%'
					)
				OR (
					@op6 = @EndsWith
					AND NAME LIKE '%' + @Name + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND [Status] = @Status
					)
				OR (
					@op7 = @IsNotEqualTo
					AND [Status] <> @Status
					)
				OR (
					@op7 = @IsLessThan
					AND [Status] < @Status
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND [Status] <= @Status
					)
				OR (
					@op7 = @IsGreaterThan
					AND [Status] > @Status
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND [Status] >= @Status
					)
				OR (
					@op7 = @Contains
					AND [Status] LIKE '%' + @Status + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND [Status] NOT LIKE '%' + @Status + '%'
					)
				OR (
					@op7 = @StartsWith
					AND [Status] LIKE '' + @Status + '%'
					)
				OR (
					@op7 = @EndsWith
					AND [Status] LIKE '%' + @Status + ''
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
								AND InvitationDate = @InvitationDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND InvitationDate <> @InvitationDate
								)
							OR (
								@op8 = @IsLessThan
								AND InvitationDate < @InvitationDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND InvitationDate <= @InvitationDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND InvitationDate > @InvitationDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND InvitationDate >= @InvitationDate
								)
							OR (
								@op8 = @Contains
								AND InvitationDate LIKE '%' + @InvitationDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND InvitationDate NOT LIKE '%' + @InvitationDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND InvitationDate LIKE '' + @InvitationDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND InvitationDate LIKE '%' + @InvitationDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop8 = @IsEqualTo
								AND InvitationDate = @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND InvitationDate <> @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND InvitationDate < @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND InvitationDate <= @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND InvitationDate > @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND InvitationDate >= @SecondInvitationDate
								)
							OR (
								@Secondop8 = @Contains
								AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND InvitationDate NOT LIKE '%' + @SecondInvitationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND InvitationDate LIKE '' + @SecondInvitationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + ''
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
								AND InvitationDate = @InvitationDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND InvitationDate <> @InvitationDate
								)
							OR (
								@op8 = @IsLessThan
								AND InvitationDate < @InvitationDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND InvitationDate <= @InvitationDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND InvitationDate > @InvitationDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND InvitationDate >= @InvitationDate
								)
							OR (
								@op8 = @Contains
								AND InvitationDate LIKE '%' + @InvitationDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND InvitationDate NOT LIKE '%' + @InvitationDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND InvitationDate LIKE '' + @InvitationDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND InvitationDate LIKE '%' + @InvitationDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop8 = @IsEqualTo
								AND InvitationDate = @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND InvitationDate <> @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND InvitationDate < @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND InvitationDate <= @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND InvitationDate > @SecondInvitationDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND InvitationDate >= @SecondInvitationDate
								)
							OR (
								@Secondop8 = @Contains
								AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND InvitationDate NOT LIKE '%' + @SecondInvitationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND InvitationDate LIKE '' + @SecondInvitationDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop8 IS NULL
					AND (
						(
							@op8 = @IsEqualTo
							AND InvitationDate = @InvitationDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND InvitationDate <> @InvitationDate
							)
						OR (
							@op8 = @IsLessThan
							AND InvitationDate < @InvitationDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND InvitationDate <= @InvitationDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND InvitationDate > @InvitationDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND InvitationDate >= @InvitationDate
							)
						OR (
							@op8 = @Contains
							AND InvitationDate LIKE '%' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND InvitationDate NOT LIKE '%' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND InvitationDate LIKE '' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND InvitationDate LIKE '%' + @InvitationDateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op9 IS NULL)
				OR (
					@op9 = @IsEqualTo
					AND [CompletionDate] = @CompletionDate
					)
				OR (
					@op9 = @IsNotEqualTo
					AND [CompletionDate] <> @CompletionDate
					)
				OR (
					@op9 = @IsLessThan
					AND [CompletionDate] < @CompletionDate
					)
				OR (
					@op9 = @IsLessThanOrEqualTo
					AND [CompletionDate] <= @CompletionDate
					)
				OR (
					@op9 = @IsGreaterThan
					AND [CompletionDate] > @CompletionDate
					)
				OR (
					@op9 = @IsGreaterThanOrEqualTo
					AND [CompletionDate] >= @CompletionDate
					)
				)
			AND (
				(@op10 IS NULL)
				OR (
					@op10 = @IsEqualTo
					AND NumberofDays = @NumberofDays
					)
				OR (
					@op10 = @IsNotEqualTo
					AND NumberofDays <> @NumberofDays
					)
				OR (
					@op10 = @IsLessThan
					AND NumberofDays < @NumberofDays
					)
				OR (
					@op10 = @IsLessThanOrEqualTo
					AND NumberofDays <= @NumberofDays
					)
				OR (
					@op10 = @IsGreaterThan
					AND NumberofDays > @NumberofDays
					)
				OR (
					@op10 = @IsGreaterThanOrEqualTo
					AND NumberofDays >= @NumberofDays
					)
				OR (
					@op10 = @Contains
					AND NumberofDays LIKE '%' + CAST(@NumberofDays AS VARCHAR) + '%'
					)
				OR (
					@op10 = @DoesNotContain
					AND NumberofDays NOT LIKE '%' + CAST(@NumberofDays AS VARCHAR) + '%'
					)
				OR (
					@op10 = @StartsWith
					AND NumberofDays LIKE '' + CAST(@NumberofDays AS VARCHAR) + '%'
					)
				OR (
					@op10 = @EndsWith
					AND NumberofDays LIKE '%' + CAST(@NumberofDays AS VARCHAR) + ''
					)
				)
			AND (
				(@op11 IS NULL)
				OR (
					@op11 = @IsEqualTo
					AND CollaborationType = @CollaborationType
					)
				OR (
					@op11 = @IsNotEqualTo
					AND CollaborationType <> @CollaborationType
					)
				OR (
					@op11 = @IsLessThan
					AND CollaborationType < @CollaborationType
					)
				OR (
					@op11 = @IsLessThanOrEqualTo
					AND CollaborationType <= @CollaborationType
					)
				OR (
					@op11 = @IsGreaterThan
					AND CollaborationType > @CollaborationType
					)
				OR (
					@op11 = @IsGreaterThanOrEqualTo
					AND CollaborationType >= @CollaborationType
					)
				OR (
					@op11 = @Contains
					AND CollaborationType LIKE '%' + @CollaborationType + '%'
					)
				OR (
					@op11 = @DoesNotContain
					AND CollaborationType NOT LIKE '%' + @CollaborationType + '%'
					)
				OR (
					@op11 = @StartsWith
					AND CollaborationType LIKE '' + @CollaborationType + '%'
					)
				OR (
					@op11 = @EndsWith
					AND CollaborationType LIKE '%' + @CollaborationType + ''
					)
				)
			AND (
				(@op12 IS NULL)
				OR (
					@op12 = @IsEqualTo
					AND [UID] = @UID
					)
				OR (
					@op12 = @IsNotEqualTo
					AND [UID] <> @UID
					)
				OR (
					@op12 = @IsLessThan
					AND [UID] < @UID
					)
				OR (
					@op12 = @IsLessThanOrEqualTo
					AND [UID] <= @UID
					)
				OR (
					@op12 = @IsGreaterThan
					AND [UID] > @UID
					)
				OR (
					@op12 = @IsGreaterThanOrEqualTo
					AND [UID] >= @UID
					)
				OR (
					@op12 = @Contains
					AND [UID] LIKE '%' + @UID + '%'
					)
				OR (
					@op12 = @DoesNotContain
					AND [UID] NOT LIKE '%' + @UID + '%'
					)
				OR (
					@op12 = @StartsWith
					AND [UID] LIKE '' + @UID + '%'
					)
				OR (
					@op12 = @EndsWith
					AND [UID] LIKE '%' + @UID + ''
					)
				)
			AND (
				(@op13 IS NULL)
				OR (
					@op13 = @IsEqualTo
					AND InterviewerID = @InterviewerID
					)
				OR (
					@op13 = @IsNotEqualTo
					AND InterviewerID <> @InterviewerID
					)
				OR (
					@op13 = @IsLessThan
					AND InterviewerID < @InterviewerID
					)
				OR (
					@op13 = @IsLessThanOrEqualTo
					AND InterviewerID <= @InterviewerID
					)
				OR (
					@op13 = @IsGreaterThan
					AND InterviewerID > @InterviewerID
					)
				OR (
					@op13 = @IsGreaterThanOrEqualTo
					AND InterviewerID >= @InterviewerID
					)
				OR (
					@op13 = @Contains
					AND InterviewerID LIKE '%' + @InterviewerID + '%'
					)
				OR (
					@op13 = @DoesNotContain
					AND InterviewerID NOT LIKE '%' + @InterviewerID + '%'
					)
				OR (
					@op13 = @StartsWith
					AND InterviewerID LIKE '' + @InterviewerID + '%'
					)
				OR (
					@op13 = @EndsWith
					AND InterviewerID LIKE '%' + @InterviewerID + ''
					)
				)
			AND (
				(@op14 IS NULL)
				OR (
					@op9 = @IsEqualTo
					AND [QuestionnaireLink] = @QuestionnaireLink
					)
				OR (
					@op9 = @IsNotEqualTo
					AND [QuestionnaireLink] <> @QuestionnaireLink
					)
				OR (
					@op9 = @IsLessThan
					AND [QuestionnaireLink] < @QuestionnaireLink
					)
				OR (
					@op9 = @IsLessThanOrEqualTo
					AND [QuestionnaireLink] <= @QuestionnaireLink
					)
				OR (
					@op9 = @IsGreaterThan
					AND [QuestionnaireLink] > @QuestionnaireLink
					)
				OR (
					@op9 = @IsGreaterThanOrEqualTo
					AND [QuestionnaireLink] >= @QuestionnaireLink
					)
				)
		OPTION (RECOMPILE)
	END

	SELECT *
	FROM (
		SELECT *
		FROM (
			SELECT FRT.QuestionnaireTransactionID AS Questionnaire_ID
				,isnull(FRT.PanelistName, isnull(PR.FirstOrderedName, ' ') + ' ' + isnull(PR.MiddleOrderedName, ' ') + ' ' + isnull(PR.LastOrderedName, ' ')) AS NAME
				,FR.SurveyName AS QuestionnaireName
				,FRT.QuestionnaireID AS ID
				,FR.QuestionnaireType AS QuestionnaireType
				,FR.CollaborationType AS CollaborationType
				,FR.ClientTeamPerson AS [Service]
				,CAST(FRT.InvitationDate AS DATE) AS [InvitationDate]
				,STD.Code AS [Status]
				,FRT.CompletionDate AS CompletionDate
				,FRT.NumberofDays AS NumberofDays
				,FRT.[UID] AS [UID]
				,FRT.InterviewerId AS InterviewerID
				,REPLACE(FR.QuestionnaireLink,'/@temp','') AS [QuestionnaireLink]
			FROM dbo.QuestionnaireTransaction FRT
			INNER JOIN dbo.Questionnaire FR ON FRT.QuestionnaireID = FR.Questionnaire_ID
			INNER JOIN StateDefinition STD ON FRT.StateId = STD.Id
			INNER JOIN Panelist PN ON PN.GUIDreference = FRT.PanelistId
			INNER JOIN Individual IND ON IND.GUIDReference = PN.PanelMember_Id
			INNER JOIN PersonalIdentification PR ON PR.PersonalIdentificationId = IND.PersonalIdentificationId
			WHERE Questionnaire_ID <> 0
				AND IND.IndividualId = @pBusinessId
			
			UNION
			
			SELECT FRT.QuestionnaireTransactionID AS Questionnaire_ID
				,isnull(FRT.PanelistName, isnull(PR.FirstOrderedName, ' ') + ' ' + isnull(PR.MiddleOrderedName, ' ') + ' ' + isnull(PR.LastOrderedName, ' ')) AS NAME
				,FR.SurveyName AS QuestionnaireName
				,FRT.QuestionnaireID AS ID
				,FR.QuestionnaireType AS QuestionnaireType
				,FR.CollaborationType AS CollaborationType
				,FR.ClientTeamPerson AS [Service]
				,CAST(FRT.InvitationDate AS DATE) AS [InvitationDate]
				,STD.Code AS [Status]
				,FRT.CompletionDate AS CompletionDate
				,FRT.NumberofDays AS NumberofDays
				,FRT.[UID] AS [UID]
				,FRT.InterviewerId AS InterviewerID
				,REPLACE(FR.QuestionnaireLink,'/@temp','') AS [QuestionnaireLink]
			FROM dbo.QuestionnaireTransaction FRT
			INNER JOIN dbo.Questionnaire FR ON FRT.QuestionnaireID = FR.Questionnaire_ID
			INNER JOIN StateDefinition STD ON FRT.StateId = STD.Id
			INNER JOIN Individual IND ON IND.GUIDReference = FRT.IndividualID
			INNER JOIN PersonalIdentification PR ON PR.PersonalIdentificationId = IND.PersonalIdentificationId
			WHERE Questionnaire_ID <> 0
				AND IND.IndividualId = @pBusinessId
			) T
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
				AND QuestionnaireName = @QuestionnaireName
				)
			OR (
				@op2 = @IsNotEqualTo
				AND QuestionnaireName <> @QuestionnaireName
				)
			OR (
				@op2 = @IsLessThan
				AND QuestionnaireName < @QuestionnaireName
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND QuestionnaireName <= @QuestionnaireName
				)
			OR (
				@op2 = @IsGreaterThan
				AND QuestionnaireName > @QuestionnaireName
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND QuestionnaireName >= @QuestionnaireName
				)
			OR (
				@op2 = @Contains
				AND QuestionnaireName LIKE '%' + @QuestionnaireName + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND QuestionnaireName NOT LIKE '%' + @QuestionnaireName + '%'
				)
			OR (
				@op2 = @StartsWith
				AND QuestionnaireName LIKE '' + @QuestionnaireName + '%'
				)
			OR (
				@op2 = @EndsWith
				AND QuestionnaireName LIKE '%' + @QuestionnaireName + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 = @IsEqualTo
				AND ID = @ID
				)
			OR (
				@op3 = @IsNotEqualTo
				AND ID <> @ID
				)
			OR (
				@op3 = @IsLessThan
				AND ID < @ID
				)
			OR (
				@op3 = @IsLessThanOrEqualTo
				AND ID <= @ID
				)
			OR (
				@op3 = @IsGreaterThan
				AND ID > @ID
				)
			OR (
				@op3 = @IsGreaterThanOrEqualTo
				AND ID >= @ID
				)
			OR (
				@op3 = @Contains
				AND ID LIKE '%' + CAST(@ID AS VARCHAR) + '%'
				)
			OR (
				@op3 = @DoesNotContain
				AND ID NOT LIKE '%' + CAST(@ID AS VARCHAR) + '%'
				)
			OR (
				@op3 = @StartsWith
				AND ID LIKE '' + CAST(@ID AS VARCHAR) + '%'
				)
			OR (
				@op3 = @EndsWith
				AND ID LIKE '%' + CAST(@ID AS VARCHAR) + ''
				)
			)
		AND (
			(@op4 IS NULL)
			OR (
				@op4 = @IsEqualTo
				AND QuestionnaireType = @QuestionnaireType
				)
			OR (
				@op4 = @IsNotEqualTo
				AND QuestionnaireType <> @QuestionnaireType
				)
			OR (
				@op4 = @IsLessThan
				AND QuestionnaireType < @QuestionnaireType
				)
			OR (
				@op4 = @IsLessThanOrEqualTo
				AND QuestionnaireType <= @QuestionnaireType
				)
			OR (
				@op4 = @IsGreaterThan
				AND QuestionnaireType > @QuestionnaireType
				)
			OR (
				@op4 = @IsGreaterThanOrEqualTo
				AND QuestionnaireType >= @QuestionnaireType
				)
			OR (
				@op4 = @Contains
				AND QuestionnaireType LIKE '%' + @QuestionnaireType + '%'
				)
			OR (
				@op4 = @DoesNotContain
				AND QuestionnaireType NOT LIKE '%' + @QuestionnaireType + '%'
				)
			OR (
				@op4 = @StartsWith
				AND QuestionnaireType LIKE '' + @QuestionnaireType + '%'
				)
			OR (
				@op4 = @EndsWith
				AND QuestionnaireType LIKE '%' + @QuestionnaireType + ''
				)
			)
		AND (
			(@op5 IS NULL)
			OR (
				@op5 = @IsEqualTo
				AND [Service] = @Service
				)
			OR (
				@op5 = @IsNotEqualTo
				AND [Service] <> @Service
				)
			OR (
				@op5 = @IsLessThan
				AND [Service] < @Service
				)
			OR (
				@op5 = @IsLessThanOrEqualTo
				AND [Service] <= @Service
				)
			OR (
				@op5 = @IsGreaterThan
				AND [Service] > @Service
				)
			OR (
				@op5 = @IsGreaterThanOrEqualTo
				AND [Service] >= @Service
				)
			OR (
				@op5 = @Contains
				AND [Service] LIKE '%' + @Service + '%'
				)
			OR (
				@op5 = @DoesNotContain
				AND [Service] NOT LIKE '%' + @Service + '%'
				)
			OR (
				@op5 = @StartsWith
				AND [Service] LIKE '' + @Service + '%'
				)
			OR (
				@op5 = @EndsWith
				AND [Service] LIKE '%' + @Service + ''
				)
			)
		AND (
			(@op6 IS NULL)
			OR (
				@op6 = @IsEqualTo
				AND NAME = @Name
				)
			OR (
				@op6 = @IsNotEqualTo
				AND NAME <> @Name
				)
			OR (
				@op6 = @IsLessThan
				AND NAME < @Name
				)
			OR (
				@op6 = @IsLessThanOrEqualTo
				AND NAME <= @Name
				)
			OR (
				@op6 = @IsGreaterThan
				AND NAME > @Name
				)
			OR (
				@op6 = @IsGreaterThanOrEqualTo
				AND NAME >= @Name
				)
			OR (
				@op6 = @Contains
				AND NAME LIKE '%' + @Name + '%'
				)
			OR (
				@op6 = @DoesNotContain
				AND NAME NOT LIKE '%' + @Name + '%'
				)
			OR (
				@op6 = @StartsWith
				AND NAME LIKE '' + @Name + '%'
				)
			OR (
				@op6 = @EndsWith
				AND NAME LIKE '%' + @Name + ''
				)
			)
		AND (
			(@op7 IS NULL)
			OR (
				@op7 = @IsEqualTo
				AND [Status] = @Status
				)
			OR (
				@op7 = @IsNotEqualTo
				AND [Status] <> @Status
				)
			OR (
				@op7 = @IsLessThan
				AND [Status] < @Status
				)
			OR (
				@op7 = @IsLessThanOrEqualTo
				AND [Status] <= @Status
				)
			OR (
				@op7 = @IsGreaterThan
				AND [Status] > @Status
				)
			OR (
				@op7 = @IsGreaterThanOrEqualTo
				AND [Status] >= @Status
				)
			OR (
				@op7 = @Contains
				AND [Status] LIKE '%' + @Status + '%'
				)
			OR (
				@op7 = @DoesNotContain
				AND [Status] NOT LIKE '%' + @Status + '%'
				)
			OR (
				@op7 = @StartsWith
				AND [Status] LIKE '' + @Status + '%'
				)
			OR (
				@op7 = @EndsWith
				AND [Status] LIKE '%' + @Status + ''
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
							AND InvitationDate = @InvitationDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND InvitationDate <> @InvitationDate
							)
						OR (
							@op8 = @IsLessThan
							AND InvitationDate < @InvitationDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND InvitationDate <= @InvitationDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND InvitationDate > @InvitationDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND InvitationDate >= @InvitationDate
							)
						OR (
							@op8 = @Contains
							AND InvitationDate LIKE '%' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND InvitationDate NOT LIKE '%' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND InvitationDate LIKE '' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND InvitationDate LIKE '%' + @InvitationDateVarchar + ''
							)
						)
					OR (
						(
							@Secondop8 = @IsEqualTo
							AND InvitationDate = @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsNotEqualTo
							AND InvitationDate <> @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsLessThan
							AND InvitationDate < @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsLessThanOrEqualTo
							AND InvitationDate <= @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsGreaterThan
							AND InvitationDate > @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsGreaterThanOrEqualTo
							AND InvitationDate >= @SecondInvitationDate
							)
						OR (
							@Secondop8 = @Contains
							AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @DoesNotContain
							AND InvitationDate NOT LIKE '%' + @SecondInvitationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @StartsWith
							AND InvitationDate LIKE '' + @SecondInvitationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @EndsWith
							AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + ''
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
							AND InvitationDate = @InvitationDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND InvitationDate <> @InvitationDate
							)
						OR (
							@op8 = @IsLessThan
							AND InvitationDate < @InvitationDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND InvitationDate <= @InvitationDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND InvitationDate > @InvitationDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND InvitationDate >= @InvitationDate
							)
						OR (
							@op8 = @Contains
							AND InvitationDate LIKE '%' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND InvitationDate NOT LIKE '%' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND InvitationDate LIKE '' + @InvitationDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND InvitationDate LIKE '%' + @InvitationDateVarchar + ''
							)
						)
					AND (
						(
							@Secondop8 = @IsEqualTo
							AND InvitationDate = @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsNotEqualTo
							AND InvitationDate <> @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsLessThan
							AND InvitationDate < @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsLessThanOrEqualTo
							AND InvitationDate <= @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsGreaterThan
							AND InvitationDate > @SecondInvitationDate
							)
						OR (
							@Secondop8 = @IsGreaterThanOrEqualTo
							AND InvitationDate >= @SecondInvitationDate
							)
						OR (
							@Secondop8 = @Contains
							AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @DoesNotContain
							AND InvitationDate NOT LIKE '%' + @SecondInvitationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @StartsWith
							AND InvitationDate LIKE '' + @SecondInvitationDateVarchar + '%'
							)
						OR (
							@Secondop8 = @EndsWith
							AND InvitationDate LIKE '%' + @SecondInvitationDateVarchar + ''
							)
						)
					)
				)
			OR (
				@Secondop8 IS NULL
				AND (
					(
						@op8 = @IsEqualTo
						AND InvitationDate = @InvitationDate
						)
					OR (
						@op8 = @IsNotEqualTo
						AND InvitationDate <> @InvitationDate
						)
					OR (
						@op8 = @IsLessThan
						AND InvitationDate < @InvitationDate
						)
					OR (
						@op8 = @IsLessThanOrEqualTo
						AND InvitationDate <= @InvitationDate
						)
					OR (
						@op8 = @IsGreaterThan
						AND InvitationDate > @InvitationDate
						)
					OR (
						@op8 = @IsGreaterThanOrEqualTo
						AND InvitationDate >= @InvitationDate
						)
					OR (
						@op8 = @Contains
						AND InvitationDate LIKE '%' + @InvitationDateVarchar + '%'
						)
					OR (
						@op8 = @DoesNotContain
						AND InvitationDate NOT LIKE '%' + @InvitationDateVarchar + '%'
						)
					OR (
						@op8 = @StartsWith
						AND InvitationDate LIKE '' + @InvitationDateVarchar + '%'
						)
					OR (
						@op8 = @EndsWith
						AND InvitationDate LIKE '%' + @InvitationDateVarchar + ''
						)
					)
				)
			)
		AND (
			(@op9 IS NULL)
			OR (
				@op9 = @IsEqualTo
				AND [CompletionDate] = @CompletionDate
				)
			OR (
				@op9 = @IsNotEqualTo
				AND [CompletionDate] <> @CompletionDate
				)
			OR (
				@op9 = @IsLessThan
				AND [CompletionDate] < @CompletionDate
				)
			OR (
				@op9 = @IsLessThanOrEqualTo
				AND [CompletionDate] <= @CompletionDate
				)
			OR (
				@op9 = @IsGreaterThan
				AND [CompletionDate] > @CompletionDate
				)
			OR (
				@op9 = @IsGreaterThanOrEqualTo
				AND [CompletionDate] >= @CompletionDate
				)
			)
		AND (
			(@op10 IS NULL)
			OR (
				@op10 = @IsEqualTo
				AND NumberofDays = @NumberofDays
				)
			OR (
				@op10 = @IsNotEqualTo
				AND NumberofDays <> @NumberofDays
				)
			OR (
				@op10 = @IsLessThan
				AND NumberofDays < @NumberofDays
				)
			OR (
				@op10 = @IsLessThanOrEqualTo
				AND NumberofDays <= @NumberofDays
				)
			OR (
				@op10 = @IsGreaterThan
				AND NumberofDays > @NumberofDays
				)
			OR (
				@op10 = @IsGreaterThanOrEqualTo
				AND NumberofDays >= @NumberofDays
				)
			OR (
				@op10 = @Contains
				AND NumberofDays LIKE '%' + CAST(@NumberofDays AS VARCHAR) + '%'
				)
			OR (
				@op10 = @DoesNotContain
				AND NumberofDays NOT LIKE '%' + CAST(@NumberofDays AS VARCHAR) + '%'
				)
			OR (
				@op10 = @StartsWith
				AND NumberofDays LIKE '' + CAST(@NumberofDays AS VARCHAR) + '%'
				)
			OR (
				@op10 = @EndsWith
				AND NumberofDays LIKE '%' + CAST(@NumberofDays AS VARCHAR) + ''
				)
			)
		AND (
			(@op11 IS NULL)
			OR (
				@op11 = @IsEqualTo
				AND CollaborationType = @CollaborationType
				)
			OR (
				@op11 = @IsNotEqualTo
				AND CollaborationType <> @CollaborationType
				)
			OR (
				@op11 = @IsLessThan
				AND CollaborationType < @CollaborationType
				)
			OR (
				@op11 = @IsLessThanOrEqualTo
				AND CollaborationType <= @CollaborationType
				)
			OR (
				@op11 = @IsGreaterThan
				AND CollaborationType > @CollaborationType
				)
			OR (
				@op11 = @IsGreaterThanOrEqualTo
				AND CollaborationType >= @CollaborationType
				)
			OR (
				@op11 = @Contains
				AND CollaborationType LIKE '%' + @CollaborationType + '%'
				)
			OR (
				@op11 = @DoesNotContain
				AND CollaborationType NOT LIKE '%' + @CollaborationType + '%'
				)
			OR (
				@op11 = @StartsWith
				AND CollaborationType LIKE '' + @CollaborationType + '%'
				)
			OR (
				@op11 = @EndsWith
				AND CollaborationType LIKE '%' + @CollaborationType + ''
				)
			)
		AND (
			(@op12 IS NULL)
			OR (
				@op12 = @IsEqualTo
				AND [UID] = @UID
				)
			OR (
				@op12 = @IsNotEqualTo
				AND [UID] <> @UID
				)
			OR (
				@op12 = @IsLessThan
				AND [UID] < @UID
				)
			OR (
				@op12 = @IsLessThanOrEqualTo
				AND [UID] <= @UID
				)
			OR (
				@op12 = @IsGreaterThan
				AND [UID] > @UID
				)
			OR (
				@op12 = @IsGreaterThanOrEqualTo
				AND [UID] >= @UID
				)
			OR (
				@op12 = @Contains
				AND [UID] LIKE '%' + @UID + '%'
				)
			OR (
				@op12 = @DoesNotContain
				AND [UID] NOT LIKE '%' + @UID + '%'
				)
			OR (
				@op12 = @StartsWith
				AND [UID] LIKE '' + @UID + '%'
				)
			OR (
				@op12 = @EndsWith
				AND [UID] LIKE '%' + @UID + ''
				)
			)
		AND (
			(@op13 IS NULL)
			OR (
				@op13 = @IsEqualTo
				AND InterviewerID = @InterviewerID
				)
			OR (
				@op13 = @IsNotEqualTo
				AND InterviewerID <> @InterviewerID
				)
			OR (
				@op13 = @IsLessThan
				AND InterviewerID < @InterviewerID
				)
			OR (
				@op13 = @IsLessThanOrEqualTo
				AND InterviewerID <= @InterviewerID
				)
			OR (
				@op13 = @IsGreaterThan
				AND InterviewerID > @InterviewerID
				)
			OR (
				@op13 = @IsGreaterThanOrEqualTo
				AND InterviewerID >= @InterviewerID
				)
			OR (
				@op13 = @Contains
				AND InterviewerID LIKE '%' + @InterviewerID + '%'
				)
			OR (
				@op13 = @DoesNotContain
				AND InterviewerID NOT LIKE '%' + @InterviewerID + '%'
				)
			OR (
				@op13 = @StartsWith
				AND InterviewerID LIKE '' + @InterviewerID + '%'
				)
			OR (
				@op13 = @EndsWith
				AND InterviewerID LIKE '%' + @InterviewerID + ''
				)
			)
		AND (
			(@op14 IS NULL)
			OR (
				@op9 = @IsEqualTo
				AND [QuestionnaireLink] = @QuestionnaireLink
				)
			OR (
				@op9 = @IsNotEqualTo
				AND [QuestionnaireLink] <> @QuestionnaireLink
				)
			OR (
				@op9 = @IsLessThan
				AND [QuestionnaireLink] < @QuestionnaireLink
				)
			OR (
				@op9 = @IsLessThanOrEqualTo
				AND [QuestionnaireLink] <= @QuestionnaireLink
				)
			OR (
				@op9 = @IsGreaterThan
				AND [QuestionnaireLink] > @QuestionnaireLink
				)
			OR (
				@op9 = @IsGreaterThanOrEqualTo
				AND [QuestionnaireLink] >= @QuestionnaireLink
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
			WHEN @pOrderBy = 'QuestionnaireName'
				AND @pOrderType = 'ASC'
				THEN QuestionnaireName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'QuestionnaireName'
				AND @pOrderType = 'DESC'
				THEN QuestionnaireName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ID'
				AND @pOrderType = 'ASC'
				THEN ID
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ID'
				AND @pOrderType = 'DESC'
				THEN ID
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
			WHEN @pOrderBy = 'Service'
				AND @pOrderType = 'ASC'
				THEN [Service]
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Service'
				AND @pOrderType = 'DESC'
				THEN [Service]
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Name'
				AND @pOrderType = 'ASC'
				THEN NAME
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Name'
				AND @pOrderType = 'DESC'
				THEN NAME
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
			WHEN @pOrderBy = 'InvitationDate'
				AND @pOrderType = 'ASC'
				THEN InvitationDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'InvitationDate'
				AND @pOrderType = 'DESC'
				THEN InvitationDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'CompletionDate'
				AND @pOrderType = 'ASC'
				THEN InvitationDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'CompletionDate'
				AND @pOrderType = 'DESC'
				THEN InvitationDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'NumberofDays'
				AND @pOrderType = 'ASC'
				THEN InvitationDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'NumberofDays'
				AND @pOrderType = 'DESC'
				THEN InvitationDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'CollaborationType'
				AND @pOrderType = 'ASC'
				THEN CollaborationType
			END ASC
		,CASE 
			WHEN @pOrderBy = 'CollaborationType'
				AND @pOrderType = 'DESC'
				THEN CollaborationType
			END DESC
		,CASE 
			WHEN @pOrderBy = 'UID'
				AND @pOrderType = 'ASC'
				THEN [UID]
			END ASC
		,CASE 
			WHEN @pOrderBy = 'UID'
				AND @pOrderType = 'DESC'
				THEN [UID]
			END DESC
		,CASE 
			WHEN @pOrderBy = 'InterviewerID'
				AND @pOrderType = 'ASC'
				THEN InterviewerID
			END ASC
		,CASE 
			WHEN @pOrderBy = 'InterviewerID'
				AND @pOrderType = 'DESC'
				THEN InterviewerID
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