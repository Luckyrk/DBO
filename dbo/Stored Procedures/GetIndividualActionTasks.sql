/*##########################################################################  
-- Name    : GetIndividualActionTasks  
-- Date             : 2014-11-12  
-- Author           : GPS Developer  
-- Company          : Cognizant Technology Solution  
-- Purpose          :   
-- PARAM Definitions  
  @pIndividualGUID UNIQUEIDENTIFIER  - Guid of individual  
 ,@pCountryId UNIQUEIDENTIFIER -- Guid of country  
 ,@pActionStatFilters INT  
 ,@pIsAdmin BIT  
 ,@pGPSUser varchar(50)  
 ,@pCultureCode INT  
 ,@pOrderBy varchar(100),@pOrderType varchar(10) -- ASC OR DESC  
 ,@pPageNumber int=1,@pPageSize int=100,@pIsExport bit=0  
 ,@pParametersTable dbo.GridParametersTable readonly  
-- Sample Execution :  
   
##########################################################################  
-- ver  user    date        change   
-- 1.0  Ramana   2014-11-12  initial  
-- 1.1  Teena Areti     2014-12-01  Added history  
-- 1.2  Fiorillo D.  2014-12-22  Join Form and Questionnaire
-- 1.3	Satish		2015-09-24	 [Bug - 36013]  - Bug-Delete,Edit and done icon is not displayed when we add the action.  
##########################################################################*/


CREATE PROCEDURE [dbo].[GetIndividualActionTasks] @pIndividualGUID UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pActionStatFilters INT
	,@pIsAdmin BIT
	,@pGPSUser VARCHAR(50)
	,@pCultureCode INT
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10) -- ASC OR DESC    
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly
	,@pCurrentUserRole INT
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
	DECLARE @LogicalOperator6 VARCHAR(5)
		,@LogicalOperator7 VARCHAR(5)
	DECLARE @Secondop6 VARCHAR(50)
		,@Secondop7 VARCHAR(50)
	DECLARE @SecondStartDate DATETIME
		,@SecondEndDate DATETIME
	DECLARE @ActionCode INT
		,@ActionLabel NVARCHAR(1000)
		,@Assignee NVARCHAR(800)
		,@Panel NVARCHAR(10)
		,@ActionComment NVARCHAR(1000)
		,@StartDate DATETIME
		,@EndDate DATETIME
		,@Questionnaire NVARCHAR(1000)
	DECLARE @ActionTaskCallBackDateTime BIT = 0

	SELECT @ActionTaskCallBackDateTime = fc.Visible
	FROM FieldConfiguration fc
	INNER JOIN country c ON fc.CountryConfiguration_Id = c.Configuration_Id
	WHERE fc.[Key] = 'ActionTask.CallBackDateTime'
		AND c.CountryId = @pCountryId

	DECLARE @CommunicationActionCallBackDateTimeTransId UNIQUEIDENTIFIER
	DECLARE @CommunicationActionCallBackDateTimeTransValue NVARCHAR(1000)

	SELECT @CommunicationActionCallBackDateTimeTransId = TranslationId
	FROM translation
	WHERE KeyName = 'Communication:Action:CallBackDateTime'

	SELECT @CommunicationActionCallBackDateTimeTransValue = dbo.GetTranslationValue(@CommunicationActionCallBackDateTimeTransId, @pCultureCode)

	BEGIN TRY
		IF (@pOrderType IS NULL)
			SET @pOrderType = 'DESC'

		SELECT @op1 = Opertor
			,@ActionCode = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionCode'

		SELECT @op2 = Opertor
			,@ActionLabel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionLabel'

		SELECT @op3 = Opertor
			,@Assignee = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'Assignee'

		SELECT @op4 = Opertor
			,@Panel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'Panel'

		SELECT @op5 = Opertor
			,@ActionComment = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionComment'

		SELECT @op6 = Opertor
			,@StartDate = CAST(ParameterValue AS DATETIME)
			,@Secondop6 = SecondParameterOperator
			,@SecondStartDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator6 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'StartDate'

		SELECT @op7 = Opertor
			,@EndDate = CAST(ParameterValue AS DATETIME)
			,@Secondop7 = SecondParameterOperator
			,@SecondEndDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator7 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'EndDate'

		SELECT @op8 = Opertor
			,@Questionnaire = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'Questionnaire'

		DECLARE @ActionCodeVarchar VARCHAR(100) = CAST(@ActionCode AS VARCHAR)
			,@StartDateVarchar VARCHAR(100) = CAST(@StartDate AS VARCHAR)
			,@SecondStartDateVarchar VARCHAR(100) = CAST(@SecondStartDate AS VARCHAR)
			,@EndDateVarchar VARCHAR(100) = CAST(@EndDate AS VARCHAR)
			,@SecondEndDateVarchar VARCHAR(100) = CAST(@SecondEndDate AS VARCHAR)
		DECLARE @OFFSETRows INT = 0
			,@UseIsForFqs BIT
			,@UseIsForCqs BIT

		IF EXISTS (
				SELECT 1
				FROM keyappsetting ka
				JOIN keyvalueappsetting kva ON kva.KeyAppSetting_Id = ka.GUIDReference
				WHERE kva.Country_Id = @pCountryId
					AND ka.KeyName = 'FrenchQuestionnaireInUse'
				)
		BEGIN
			SET @UseIsForFqs = (
					SELECT kva.Value
					FROM keyappsetting ka
					JOIN keyvalueappsetting kva ON kva.KeyAppSetting_Id = ka.GUIDReference
					WHERE kva.Country_Id = @pCountryId
						AND ka.KeyName = 'FrenchQuestionnaireInUse'
					)
		END
		ELSE
		BEGIN
			SET @UseIsForFqs = (
					SELECT DefaultValue
					FROM KeyAppSetting
					WHERE KeyName = 'FrenchQuestionnaireInUse'
					)
		END

		IF EXISTS (
				SELECT 1
				FROM keyappsetting ka
				JOIN keyvalueappsetting kva ON kva.KeyAppSetting_Id = ka.GUIDReference
				WHERE kva.Country_Id = @pCountryId
					AND ka.KeyName = 'ChineseQuestionnaireInUse'
				)
		BEGIN
			SET @UseIsForCqs = (
					SELECT kva.Value
					FROM keyappsetting ka
					JOIN keyvalueappsetting kva ON kva.KeyAppSetting_Id = ka.GUIDReference
					WHERE kva.Country_Id = @pCountryId
						AND ka.KeyName = 'ChineseQuestionnaireInUse'
					)
		END
		ELSE
		BEGIN
			SET @UseIsForCqs = (
					SELECT DefaultValue
					FROM KeyAppSetting
					WHERE KeyName = 'ChineseQuestionnaireInUse'
					)
		END

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
			SET @pPageSize = 65000

		DECLARE @SocialGradingId UNIQUEIDENTIFIER = NULL
			,@SocialGradingCallRequiredId UNIQUEIDENTIFIER = NULL
			,@SocialGradingLetterId UNIQUEIDENTIFIER = NULL
			,@SocialGradingDiscussionId UNIQUEIDENTIFIER = NULL
			,@CheckNewSignUpId UNIQUEIDENTIFIER = NULL
			,@CheckNewCallRequiredSignUpId UNIQUEIDENTIFIER = NULL
			,@IsUpdateAcess BIT = NULL
			,@IsCloseAcess BIT = NULL
			,@IsCancelAcess BIT = NULL
			,@BabyDueTranslationId UNIQUEIDENTIFIER = NULL
			,@TeenAccountReviewId UNIQUEIDENTIFIER = NULL
			,@TeenAccountCallRequiredId UNIQUEIDENTIFIER = NULL
			,@TeenAccountLetterId UNIQUEIDENTIFIER = NULL
		DECLARE @CurrentuserRoleId BIGINT

		SELECT @BabyDueTranslationId = (
				SELECT TranslationId
				FROM Translation
				WHERE [KeyName] = 'Babyduechecks'
				)

		SELECT @CurrentuserRoleId = SUR.SystemRoleTypeId
		FROM IdentityUser IU
		INNER JOIN SystemUserRole SUR ON SUR.IdentityUserId = IU.Id
		WHERE IU.UserName = @pGPSUser
			AND IU.Country_Id = @pCountryId

		SELECT @SocialGradingId = CC.SocialGradingActionTaskTypeId
			,@SocialGradingCallRequiredId = CC.SocialGradingCallActionTaskTypeId
			,@SocialGradingLetterId = CC.SocialGradingLetterActionTaskTypeId
			,@SocialGradingDiscussionId = CC.SocialGradingDiscussionActionTaskTypeId
			,@CheckNewSignUpId = CC.CheckNewSignupActionTaskTypeId
			,@CheckNewCallRequiredSignUpId = CC.CheckNewSignupCallRequiredActionTaskTypeId
			,@TeenAccountReviewId = CC.TeenAccountReviewId
			,@TeenAccountCallRequiredId = CC.TeenAccountCallActionTaskTypeId
			,@TeenAccountLetterId = CC.TeenAccountLetterActionTaskTypeId
		FROM CountryConfiguration CC
		INNER JOIN Country C ON C.Configuration_Id = CC.Id
		WHERE C.CountryId = @pCountryId

		SELECT Atra.ActionTaskTypeId
			,MAX(CASE 
					WHEN Ar.SystemOperationId = 3
						AND Ar.SystemRoleTypeId = ISNULL(@pCurrentUserRole, 3)
						THEN 1
					ELSE 0
					END) AS [IsUpdateAcess]
			,MAX(CASE 
					WHEN Ar.SystemOperationId = 7
						AND Ar.SystemRoleTypeId = ISNULL(@pCurrentUserRole, 3)
						THEN 1
					ELSE 0
					END) AS [IsCloseAcess]
			,MAX(CASE 
					WHEN Ar.SystemOperationId = 4
						AND Ar.SystemRoleTypeId = ISNULL(@pCurrentUserRole, 3)
						THEN 1
					ELSE 0
					END) AS [IsCancelAcess]
		INTO #ActionTaskPermissions
		FROM ActionTask AT
		INNER JOIN ActionTaskType ATT ON AT.ActionTaskType_Id = ATT.GUIDReference
		INNER JOIN ActionTaskTypeRestrictedAccessArea Atra ON Atra.ActionTaskTypeId = ATT.GUIDReference
		INNER JOIN RestrictedAccessArea Raa ON Raa.RestrictedAccessAreaId = Atra.RestrictedAccessAreaId
		INNER JOIN AccessRights Ar ON Ar.RestrictedAccessAreaId = Raa.RestrictedAccessAreaId
		INNER JOIN Individual I ON AT.Candidate_Id = I.GUIDReference
		WHERE Ar.IsPermissionGranted = 1
			AND I.GUIDReference = @pIndividualGUID
		GROUP BY Atra.ActionTaskTypeId

		IF (@pIsExport = 0)
		BEGIN
			SELECT COUNT(0) AS TotlaRows
			FROM (
				SELECT I.GUIDReference AS candidateId
					,I.IndividualId AS BusinessId
					,AT.GUIDReference AS Id
					,IIF(@ActionTaskCallBackDateTime = 0, AT.ActionComment, (
							IIF(AT.CallBackDateTime IS NULL, AT.ActionComment, @CommunicationActionCallBackDateTimeTransValue + ' :' + FORMAT(AT.CallBackDateTime, 'dd/MM/yyyy HH:mm') + IIF(AT.ActionComment IS NULL, '', '/

') + ISNULL(AT.ActionComment, ''))
							)) AS ActionComment
					,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, AT.StartDate, 103), 121) AS DATETIME) AS StartDate
					,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, AT.EndDate, 103), 121) AS DATETIME) AS EndDate
					,AT.CallBackDateTime
					,CAST(AT.CompletionDate AS DATE) AS CompletionDate
					,AT.GUIDReference AS ActionTaskId
					,ATT.ActionCode
					,ATT.IsForDpa AS Editable
					,O.OrderId AS OrderId
					,(
						CASE 
							WHEN OTB.[Type] = 'FinalTransitionBehavior'
								THEN 1
							ELSE 0
							END
						) AS OrderLastState
					,CASE 
						WHEN (
								@UseIsForFqs = 1
								AND ATT.IsForFqs = 1
								)
							THEN 1
						ELSE 0
						END AS IsForFqs
					,CASE 
						WHEN (
								@UseIsForCqs = 1
								AND ATT.IsForCqs = 1
								)
							THEN 1
						ELSE 0
						END AS IsForCqs
					,IU.UserName AS Assignee
					,P.NAME AS Panel
					,AT.CreationTimeStamp AS CreationTimeStamp
					,AT.GPSUpdateTimeStamp AS GPSUpdateTimeStamp
					,dbo.[GetTranslationValue](ATT.TagTranslation_Id, @pCulturecode) AS ActionLabel
					,CAST(CASE 
							WHEN ATT.GUIDReference IN (
									@SocialGradingId
									,@SocialGradingCallRequiredId
									,@SocialGradingLetterId
									,@SocialGradingDiscussionId
									)
								THEN 1
							ELSE 0
							END AS BIT) AS IsSocialGradingAction
					,CAST(CASE 
							WHEN ATT.GUIDReference IN (
									@TeenAccountReviewId
									,@TeenAccountCallRequiredId
									,@TeenAccountLetterId
									)
								THEN 1
							ELSE 0
							END AS BIT) AS IsTeenAccountAction
					,AT.FormId AS Form
					,dbo.[GetTranslationValue](F.Translation_Id, @pCulturecode) AS Questionnaire
					,ATT.GUIDReference AS ActionTaskTypeId
					,ATT.ActionCode AS Code
					,dbo.[GetTranslationValue](ATT.TagTranslation_Id, @pCulturecode) AS TagValue
					,dbo.[GetTranslationValue](ATT.DescriptionTranslation_Id, @pCulturecode) AS DescriptionValue
					,CASE (ATT.Type)
						WHEN 'DealtByCommunicationTeam'
							THEN 1
						ELSE 0
						END AS IsDealtByCommunicationTeam
					,CASE 
						WHEN (
								ATT.GUIDReference = @CheckNewSignUpId
								OR ATT.GUIDReference = @CheckNewCallRequiredSignUpId
								)
							THEN 1
						ELSE 0
						END AS IsCheckNewSignUpAction
					,(@pIsAdmin | ISNULL(ATP.IsUpdateAcess, 1)) AS IsUpdateAcess
					,(@pIsAdmin | ISNULL(ATP.IsCloseAcess, 1)) AS IsCloseAcess
					,(@pIsAdmin | ISNULL(ATP.IsCancelAcess, 1)) AS IsCancelAcess
					--,ATT.IsForFqs    
					,ISNULL(TranslationTermTable.Value, TranslationTermTable.KeyName) AS StateLabel
				FROM ActionTask AT
				INNER JOIN ActionTaskType ATT ON AT.ActionTaskType_Id = ATT.GUIDReference
				INNER JOIN Individual I ON AT.Candidate_Id = I.GUIDReference
				INNER JOIN Translation T ON T.TranslationId = ATT.TagTranslation_Id
				LEFT JOIN Panel P ON P.GUIDReference = AT.Panel_Id
				LEFT JOIN IdentityUser IU ON IU.Id = AT.Assignee_Id
				LEFT JOIN Form F ON F.GUIDReference = AT.FormId
				LEFT JOIN #ActionTaskPermissions ATP ON ATP.ActionTaskTypeId = ATT.GUIDReference
				LEFT JOIN [Order] O ON O.ActionTask_Id = AT.GUIDReference
				LEFT JOIN StateDefinition OSD ON O.State_Id = OSD.Id
				LEFT JOIN TransitionBehavior OTB ON OTB.GUIDReference = OSD.StateDefinitionBehavior_Id
				LEFT JOIN (
					SELECT T.TranslationId
						,T.KeyName
						,TT.Value
						,CASE 
							WHEN KeyName = 'ActionState.ToDo'
								THEN 1
							WHEN KeyName = 'ActionState.InProgress'
								THEN 2
							WHEN KeyName = 'ActionState.Performed'
								THEN 4
							WHEN KeyName = 'ActionState.CanceledByUser'
								THEN 8
							WHEN KeyName = 'ActionState.CanceledBySystem'
								THEN 16
							ELSE - 1
							END AS TTstate
					FROM Translation T
					INNER JOIN TranslationTerm TT ON TT.Translation_Id = T.TranslationId
					WHERE KeyName IN (
							'ActionState.ToDo'
							,'ActionState.InProgress'
							,'ActionState.Performed'
							,'ActionState.CanceledByUser'
							,'ActionState.CanceledBySystem'
							,'ActionState.Unknown'
							)
						AND CultureCode = @pCultureCode
					) AS TranslationTermTable ON TranslationTermTable.TTstate = CASE 
						WHEN AT.STATE NOT IN (
								1
								,2
								,4
								,8
								,16
								)
							THEN - 1
						ELSE AT.STATE
						END
				WHERE I.GUIDReference = @pIndividualGUID
					AND AT.STATE NOT IN (
						8
						,4
						,16
						)
				) AS TEMPTABLE
			WHERE (
					(@op1 IS NULL)
					OR (
						@op1 = @IsEqualTo
						AND ActionCode = @ActionCode
						)
					OR (
						@op1 = @IsNotEqualTo
						AND ActionCode <> @ActionCode
						)
					OR (
						@op1 = @IsLessThan
						AND ActionCode < @ActionCode
						)
					OR (
						@op1 = @IsLessThanOrEqualTo
						AND ActionCode <= @ActionCode
						)
					OR (
						@op1 = @IsGreaterThan
						AND ActionCode > @ActionCode
						)
					OR (
						@op1 = @IsGreaterThanOrEqualTo
						AND ActionCode >= @ActionCode
						)
					OR (
						@op1 = @Contains
						AND ActionCode LIKE '%' + @ActionCodeVarchar + '%'
						)
					OR (
						@op1 = @DoesNotContain
						AND ActionCode NOT LIKE '%' + @ActionCodeVarchar + '%'
						)
					OR (
						@op1 = @StartsWith
						AND ActionCode LIKE '' + @ActionCodeVarchar + '%'
						)
					OR (
						@op1 = @EndsWith
						AND ActionCode LIKE '%' + @ActionCodeVarchar + ''
						)
					)
				AND (
					(@op2 IS NULL)
					OR (
						@op2 = @IsEqualTo
						AND ActionLabel = @ActionLabel
						)
					OR (
						@op2 = @IsNotEqualTo
						AND ActionLabel <> @ActionLabel
						)
					OR (
						@op2 = @IsLessThan
						AND ActionLabel < @ActionLabel
						)
					OR (
						@op2 = @IsLessThanOrEqualTo
						AND ActionLabel <= @ActionLabel
						)
					OR (
						@op2 = @IsGreaterThan
						AND ActionLabel > @ActionLabel
						)
					OR (
						@op2 = @IsGreaterThanOrEqualTo
						AND ActionLabel >= @ActionLabel
						)
					OR (
						@op2 = @Contains
						AND ActionLabel LIKE '%' + @ActionLabel + '%'
						)
					OR (
						@op2 = @DoesNotContain
						AND ActionLabel NOT LIKE '%' + @ActionLabel + '%'
						)
					OR (
						@op2 = @StartsWith
						AND ActionLabel LIKE '' + @ActionLabel + '%'
						)
					OR (
						@op2 = @EndsWith
						AND ActionLabel LIKE '%' + @ActionLabel + ''
						)
					)
				AND (
					(@op3 IS NULL)
					OR (
						@op3 = @IsEqualTo
						AND Assignee = @Assignee
						)
					OR (
						@op3 = @IsNotEqualTo
						AND Assignee <> @Assignee
						)
					OR (
						@op3 = @IsLessThan
						AND Assignee < @Assignee
						)
					OR (
						@op3 = @IsLessThanOrEqualTo
						AND Assignee <= @Assignee
						)
					OR (
						@op3 = @IsGreaterThan
						AND Assignee > @Assignee
						)
					OR (
						@op3 = @IsGreaterThanOrEqualTo
						AND Assignee >= @Assignee
						)
					OR (
						@op3 = @Contains
						AND Assignee LIKE '%' + @Assignee + '%'
						)
					OR (
						@op3 = @DoesNotContain
						AND Assignee NOT LIKE '%' + @Assignee + '%'
						)
					OR (
						@op3 = @StartsWith
						AND Assignee LIKE '' + @Assignee + '%'
						)
					OR (
						@op3 = @EndsWith
						AND Assignee LIKE '%' + @Assignee + ''
						)
					)
				AND (
					(@op4 IS NULL)
					OR (
						@op4 = @IsEqualTo
						AND Panel = @Panel
						)
					OR (
						@op4 = @IsNotEqualTo
						AND Panel <> @Panel
						)
					OR (
						@op4 = @IsLessThan
						AND Panel < @Panel
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND Panel <= @Panel
						)
					OR (
						@op4 = @IsGreaterThan
						AND Panel > @Panel
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND Panel >= @Panel
						)
					OR (
						@op4 = @Contains
						AND Panel LIKE '%' + @Panel + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND Panel NOT LIKE '%' + @Panel + '%'
						)
					OR (
						@op4 = @StartsWith
						AND Panel LIKE '' + @Panel + '%'
						)
					OR (
						@op4 = @EndsWith
						AND Panel LIKE '%' + @Panel + ''
						)
					)
				AND (
					(@op5 IS NULL)
					OR (
						@op5 = @IsEqualTo
						AND ActionComment = @ActionComment
						)
					OR (
						@op5 = @IsNotEqualTo
						AND ActionComment <> @ActionComment
						)
					OR (
						@op5 = @IsLessThan
						AND ActionComment < @ActionComment
						)
					OR (
						@op5 = @IsLessThanOrEqualTo
						AND ActionComment <= @ActionComment
						)
					OR (
						@op5 = @IsGreaterThan
						AND ActionComment > @ActionComment
						)
					OR (
						@op5 = @IsGreaterThanOrEqualTo
						AND ActionComment >= @ActionComment
						)
					OR (
						@op5 = @Contains
						AND ActionComment LIKE '%' + @ActionComment + '%'
						)
					OR (
						@op5 = @DoesNotContain
						AND ActionComment NOT LIKE '%' + @ActionComment + '%'
						)
					OR (
						@op5 = @StartsWith
						AND ActionComment LIKE '' + @ActionComment + '%'
						)
					OR (
						@op5 = @EndsWith
						AND ActionComment LIKE '%' + @ActionComment + ''
						)
					)
				AND (
					(@op6 IS NULL)
					OR (
						@op6 IS NULL
						AND @LogicalOperator6 IS NULL
						)
					OR (
						@LogicalOperator6 = 'OR'
						AND (
							(
								(
									@op6 = @IsEqualTo
									AND CAST(StartDate AS DATETIME) = @StartDate
									)
								OR (
									@op6 = @IsNotEqualTo
									AND CAST(StartDate AS DATETIME) <> @StartDate
									)
								OR (
									@op6 = @IsLessThan
									AND CAST(StartDate AS DATETIME) < @StartDate
									)
								OR (
									@op6 = @IsLessThanOrEqualTo
									AND CAST(StartDate AS DATETIME) <= @StartDate
									)
								OR (
									@op6 = @IsGreaterThan
									AND CAST(StartDate AS DATETIME) > @StartDate
									)
								OR (
									@op6 = @IsGreaterThanOrEqualTo
									AND CAST(StartDate AS DATETIME) >= @StartDate
									)
								OR (
									@op6 = @Contains
									AND StartDate LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op6 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op6 = @StartsWith
									AND StartDate LIKE '' + @StartDateVarchar + '%'
									)
								OR (
									@op6 = @EndsWith
									AND StartDate LIKE '%' + @StartDateVarchar + ''
									)
								)
							OR (
								(
									@Secondop6 = @IsEqualTo
									AND CAST(StartDate AS DATETIME) = @SecondStartDate
									)
								OR (
									@Secondop6 = @IsNotEqualTo
									AND CAST(StartDate AS DATETIME) <> @SecondStartDate
									)
								OR (
									@Secondop6 = @IsLessThan
									AND CAST(StartDate AS DATETIME) < @SecondStartDate
									)
								OR (
									@Secondop6 = @IsLessThanOrEqualTo
									AND CAST(StartDate AS DATETIME) <= @SecondStartDate
									)
								OR (
									@Secondop6 = @IsGreaterThan
									AND CAST(StartDate AS DATETIME) > @SecondStartDate
									)
								OR (
									@Secondop6 = @IsGreaterThanOrEqualTo
									AND CAST(StartDate AS DATETIME) >= @SecondStartDate
									)
								OR (
									@Secondop6 = @Contains
									AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop6 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop6 = @StartsWith
									AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop6 = @EndsWith
									AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator6 = 'AND'
						AND (
							(
								(
									@op6 = @IsEqualTo
									AND CAST(StartDate AS DATETIME) = @StartDate
									)
								OR (
									@op6 = @IsNotEqualTo
									AND CAST(StartDate AS DATETIME) <> @StartDate
									)
								OR (
									@op6 = @IsLessThan
									AND CAST(StartDate AS DATETIME) < @StartDate
									)
								OR (
									@op6 = @IsLessThanOrEqualTo
									AND CAST(StartDate AS DATETIME) <= @StartDate
									)
								OR (
									@op6 = @IsGreaterThan
									AND CAST(StartDate AS DATETIME) > @StartDate
									)
								OR (
									@op6 = @IsGreaterThanOrEqualTo
									AND CAST(StartDate AS DATETIME) >= @StartDate
									)
								OR (
									@op6 = @Contains
									AND StartDate LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op6 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op6 = @StartsWith
									AND StartDate LIKE '' + @StartDateVarchar + '%'
									)
								OR (
									@op6 = @EndsWith
									AND StartDate LIKE '%' + @StartDateVarchar + ''
									)
								)
							AND (
								(
									@Secondop6 = @IsEqualTo
									AND CAST(StartDate AS DATETIME) = @SecondStartDate
									)
								OR (
									@Secondop6 = @IsNotEqualTo
									AND CAST(StartDate AS DATETIME) <> @SecondStartDate
									)
								OR (
									@Secondop6 = @IsLessThan
									AND CAST(StartDate AS DATETIME) < @SecondStartDate
									)
								OR (
									@Secondop6 = @IsLessThanOrEqualTo
									AND CAST(StartDate AS DATETIME) <= @SecondStartDate
									)
								OR (
									@Secondop6 = @IsGreaterThan
									AND CAST(StartDate AS DATETIME) > @SecondStartDate
									)
								OR (
									@Secondop6 = @IsGreaterThanOrEqualTo
									AND CAST(StartDate AS DATETIME) >= @SecondStartDate
									)
								OR (
									@Secondop6 = @Contains
									AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop6 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop6 = @StartsWith
									AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop6 = @EndsWith
									AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
									)
								)
							)
						)
					OR (
						@Secondop6 IS NULL
						AND (
							(
								@op6 = @IsEqualTo
								AND CAST(StartDate AS DATETIME) = @StartDate
								)
							OR (
								@op6 = @IsNotEqualTo
								AND CAST(StartDate AS DATETIME) <> @StartDate
								)
							OR (
								@op6 = @IsLessThan
								AND CAST(StartDate AS DATETIME) < @StartDate
								)
							OR (
								@op6 = @IsLessThanOrEqualTo
								AND CAST(StartDate AS DATETIME) <= @StartDate
								)
							OR (
								@op6 = @IsGreaterThan
								AND CAST(StartDate AS DATETIME) > @StartDate
								)
							OR (
								@op6 = @IsGreaterThanOrEqualTo
								AND CAST(StartDate AS DATETIME) >= @StartDate
								)
							OR (
								@op6 = @Contains
								AND StartDate LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @StartsWith
								AND StartDate LIKE '' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @EndsWith
								AND StartDate LIKE '%' + @StartDateVarchar + ''
								)
							)
						)
					)
				AND (
					(@op7 IS NULL)
					OR (
						@op7 IS NULL
						AND @LogicalOperator7 IS NULL
						)
					OR (
						@LogicalOperator7 = 'OR'
						AND (
							(
								(
									@op7 = @IsEqualTo
									AND CAST(EndDate AS DATETIME) = @EndDate
									)
								OR (
									@op7 = @IsNotEqualTo
									AND CAST(EndDate AS DATETIME) <> @EndDate
									)
								OR (
									@op7 = @IsLessThan
									AND CAST(EndDate AS DATETIME) < @EndDate
									)
								OR (
									@op7 = @IsLessThanOrEqualTo
									AND CAST(EndDate AS DATETIME) <= @EndDate
									)
								OR (
									@op7 = @IsGreaterThan
									AND CAST(EndDate AS DATETIME) > @EndDate
									)
								OR (
									@op7 = @IsGreaterThanOrEqualTo
									AND CAST(EndDate AS DATETIME) >= @EndDate
									)
								OR (
									@op7 = @Contains
									AND EndDate LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op7 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op7 = @StartsWith
									AND EndDate LIKE '' + @EndDateVarchar + '%'
									)
								OR (
									@op7 = @EndsWith
									AND EndDate LIKE '%' + @EndDateVarchar + ''
									)
								)
							OR (
								(
									@Secondop7 = @IsEqualTo
									AND CAST(EndDate AS DATETIME) = @SecondEndDate
									)
								OR (
									@Secondop7 = @IsNotEqualTo
									AND CAST(EndDate AS DATETIME) <> @SecondEndDate
									)
								OR (
									@Secondop7 = @IsLessThan
									AND CAST(EndDate AS DATETIME) < @SecondEndDate
									)
								OR (
									@Secondop7 = @IsLessThanOrEqualTo
									AND CAST(EndDate AS DATETIME) <= @SecondEndDate
									)
								OR (
									@Secondop7 = @IsGreaterThan
									AND CAST(EndDate AS DATETIME) > @SecondEndDate
									)
								OR (
									@Secondop7 = @IsGreaterThanOrEqualTo
									AND CAST(EndDate AS DATETIME) >= @SecondEndDate
									)
								OR (
									@Secondop7 = @Contains
									AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop7 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop7 = @StartsWith
									AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop7 = @EndsWith
									AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator7 = 'AND'
						AND (
							(
								(
									@op7 = @IsEqualTo
									AND CAST(EndDate AS DATETIME) = @EndDate
									)
								OR (
									@op7 = @IsNotEqualTo
									AND CAST(EndDate AS DATETIME) <> @EndDate
									)
								OR (
									@op7 = @IsLessThan
									AND CAST(EndDate AS DATETIME) < @EndDate
									)
								OR (
									@op7 = @IsLessThanOrEqualTo
									AND CAST(EndDate AS DATETIME) <= @EndDate
									)
								OR (
									@op7 = @IsGreaterThan
									AND CAST(EndDate AS DATETIME) > @EndDate
									)
								OR (
									@op7 = @IsGreaterThanOrEqualTo
									AND CAST(EndDate AS DATETIME) >= @EndDate
									)
								OR (
									@op7 = @Contains
									AND EndDate LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op7 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op7 = @StartsWith
									AND EndDate LIKE '' + @EndDateVarchar + '%'
									)
								OR (
									@op7 = @EndsWith
									AND EndDate LIKE '%' + @EndDateVarchar + ''
									)
								)
							AND (
								(
									@Secondop7 = @IsEqualTo
									AND CAST(EndDate AS DATETIME) = @SecondEndDate
									)
								OR (
									@Secondop7 = @IsNotEqualTo
									AND CAST(EndDate AS DATETIME) <> @SecondEndDate
									)
								OR (
									@Secondop7 = @IsLessThan
									AND CAST(EndDate AS DATETIME) < @SecondEndDate
									)
								OR (
									@Secondop7 = @IsLessThanOrEqualTo
									AND CAST(EndDate AS DATETIME) <= @SecondEndDate
									)
								OR (
									@Secondop7 = @IsGreaterThan
									AND CAST(EndDate AS DATETIME) > @SecondEndDate
									)
								OR (
									@Secondop7 = @IsGreaterThanOrEqualTo
									AND CAST(EndDate AS DATETIME) >= @SecondEndDate
									)
								OR (
									@Secondop7 = @Contains
									AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop7 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop7 = @StartsWith
									AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop7 = @EndsWith
									AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
									)
								)
							)
						)
					OR (
						@Secondop7 IS NULL
						AND (
							(
								@op7 = @IsEqualTo
								AND CAST(EndDate AS DATETIME) = @EndDate
								)
							OR (
								@op7 = @IsNotEqualTo
								AND CAST(EndDate AS DATETIME) <> @EndDate
								)
							OR (
								@op7 = @IsLessThan
								AND CAST(EndDate AS DATETIME) < @EndDate
								)
							OR (
								@op7 = @IsLessThanOrEqualTo
								AND CAST(EndDate AS DATETIME) <= @EndDate
								)
							OR (
								@op7 = @IsGreaterThan
								AND CAST(EndDate AS DATETIME) > @EndDate
								)
							OR (
								@op7 = @IsGreaterThanOrEqualTo
								AND CAST(EndDate AS DATETIME) >= @EndDate
								)
							OR (
								@op7 = @Contains
								AND EndDate LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @StartsWith
								AND EndDate LIKE '' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @EndsWith
								AND EndDate LIKE '%' + @EndDateVarchar + ''
								)
							)
						)
					)
				AND (
					(@op8 IS NULL)
					OR (
						@op8 = @IsEqualTo
						AND Questionnaire = @Questionnaire
						)
					OR (
						@op8 = @IsNotEqualTo
						AND Questionnaire <> @Questionnaire
						)
					OR (
						@op8 = @IsLessThan
						AND Questionnaire < @Questionnaire
						)
					OR (
						@op8 = @IsLessThanOrEqualTo
						AND Questionnaire <= @Questionnaire
						)
					OR (
						@op8 = @IsGreaterThan
						AND Questionnaire > @Questionnaire
						)
					OR (
						@op8 = @IsGreaterThanOrEqualTo
						AND Questionnaire >= @Questionnaire
						)
					OR (
						@op8 = @Contains
						AND Questionnaire LIKE '%' + @Questionnaire + '%'
						)
					OR (
						@op8 = @DoesNotContain
						AND Questionnaire NOT LIKE '%' + @Questionnaire + '%'
						)
					OR (
						@op8 = @StartsWith
						AND Questionnaire LIKE '' + @Questionnaire + '%'
						)
					OR (
						@op8 = @EndsWith
						AND Questionnaire LIKE '%' + @Questionnaire + ''
						)
					)
			OPTION (RECOMPILE)
		END

		SELECT *
		FROM (
			SELECT I.GUIDReference AS candidateId
				,I.IndividualId AS BusinessId
				,AT.GUIDReference AS Id
				,IIF(@ActionTaskCallBackDateTime = 0, AT.ActionComment, (
						IIF(AT.CallBackDateTime IS NULL, AT.ActionComment, @CommunicationActionCallBackDateTimeTransValue + ' :' + FORMAT(AT.CallBackDateTime, 'dd/MM/yyyy HH:mm') + IIF(AT.ActionComment IS NULL, '', '/
') + ISNULL(AT.ActionComment, ''))
						)) AS ActionComment
				,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, AT.StartDate, 103), 121) AS DATETIME) AS StartDate
				,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, AT.EndDate, 103), 121) AS DATETIME) AS EndDate
				,AT.CallBackDateTime
				,CAST(AT.CompletionDate AS DATE) AS CompletionDate
				,AT.GUIDReference AS ActionTaskId
				,ATT.ActionCode
				,dbo.[GetTranslationValue](@BabyDueTranslationId, @pCulturecode) AS BabyDueCheck
				,ATT.IsForDpa AS Editable
				,O.OrderId AS OrderId
				,(
					CASE 
						WHEN OTB.[Type] = 'FinalTransitionBehavior'
							THEN 1
						ELSE 0
						END
					) AS OrderLastState
				,CASE 
					WHEN (
							@UseIsForFqs = 1
							AND ATT.IsForFqs = 1
							)
						THEN 1
					ELSE 0
					END AS IsForFqs
				,CASE 
					WHEN (
							@UseIsForCqs = 1
							AND ATT.IsForCqs = 1
							)
						THEN 1
					ELSE 0
					END AS IsForCqs
				,IU.UserName AS Assignee
				,P.NAME AS Panel
				,AT.CreationTimeStamp AS CreationTimeStamp
				,AT.GPSUpdateTimeStamp AS GPSUpdateTimeStamp
				,dbo.[GetTranslationValue](ATT.TagTranslation_Id, @pCulturecode) AS ActionLabel
				,CAST(CASE 
						WHEN ATT.GUIDReference IN (
								@SocialGradingId
								,@SocialGradingCallRequiredId
								,@SocialGradingLetterId
								,@SocialGradingDiscussionId
								)
							THEN 1
						ELSE 0
						END AS BIT) AS IsSocialGradingAction
				,CAST(CASE 
						WHEN ATT.GUIDReference IN (
								@TeenAccountReviewId
								,@TeenAccountCallRequiredId
								,@TeenAccountLetterId
								)
							THEN 1
						ELSE 0
						END AS BIT) AS IsTeenAccountAction
				,AT.FormId AS Form
				,dbo.[GetTranslationValue](F.Translation_Id, @pCulturecode) AS Questionnaire
				,ATT.GUIDReference AS ActionTaskTypeId
				,ATT.ActionCode AS Code
				,dbo.[GetTranslationValue](ATT.TagTranslation_Id, @pCulturecode) AS TagValue
				,dbo.[GetTranslationValue](ATT.DescriptionTranslation_Id, @pCulturecode) AS DescriptionValue
				,CASE (ATT.Type)
					WHEN 'DealtByCommunicationTeam'
						THEN 1
					ELSE 0
					END AS IsDealtByCommunicationTeam
				,CASE 
					WHEN (
							ATT.GUIDReference = @CheckNewSignUpId
							OR ATT.GUIDReference = @CheckNewCallRequiredSignUpId
							)
						THEN 1
					ELSE 0
					END AS IsCheckNewSignUpAction
				,(@pIsAdmin | ISNULL(ATP.IsUpdateAcess, 1)) AS IsUpdateAcess
				,(@pIsAdmin | ISNULL(ATP.IsCloseAcess, 1)) AS IsCloseAcess
				,(@pIsAdmin | ISNULL(ATP.IsCancelAcess, 1)) AS IsCancelAcess
				--,ATT.IsForFqs    
				,ISNULL(TranslationTermTable.Value, TranslationTermTable.KeyName) AS StateLabel
			FROM ActionTask AT
			INNER JOIN ActionTaskType ATT ON AT.ActionTaskType_Id = ATT.GUIDReference
			INNER JOIN Individual I ON AT.Candidate_Id = I.GUIDReference
			INNER JOIN Translation T ON T.TranslationId = ATT.TagTranslation_Id
			LEFT JOIN Panel P ON P.GUIDReference = AT.Panel_Id
			LEFT JOIN IdentityUser IU ON IU.Id = AT.Assignee_Id
			LEFT JOIN Form F ON F.GUIDReference = AT.FormId
			LEFT JOIN #ActionTaskPermissions ATP ON ATP.ActionTaskTypeId = ATT.GUIDReference
			LEFT JOIN [Order] O ON O.ActionTask_Id = AT.GUIDReference
			LEFT JOIN StateDefinition OSD ON O.State_Id = OSD.Id
			LEFT JOIN TransitionBehavior OTB ON OTB.GUIDReference = OSD.StateDefinitionBehavior_Id
			LEFT JOIN (
				SELECT T.TranslationId
					,T.KeyName
					,TT.Value
					,CASE 
						WHEN KeyName = 'ActionState.ToDo'
							THEN 1
						WHEN KeyName = 'ActionState.InProgress'
							THEN 2
						WHEN KeyName = 'ActionState.Performed'
							THEN 4
						WHEN KeyName = 'ActionState.CanceledByUser'
							THEN 8
						WHEN KeyName = 'ActionState.CanceledBySystem'
							THEN 16
						ELSE - 1
						END AS TTstate
				FROM Translation T
				INNER JOIN TranslationTerm TT ON TT.Translation_Id = T.TranslationId
				WHERE KeyName IN (
						'ActionState.ToDo'
						,'ActionState.InProgress'
						,'ActionState.Performed'
						,'ActionState.CanceledByUser'
						,'ActionState.CanceledBySystem'
						,'ActionState.Unknown'
						)
					AND CultureCode = @pCultureCode
				) AS TranslationTermTable ON TranslationTermTable.TTstate = CASE 
					WHEN AT.STATE NOT IN (
							1
							,2
							,4
							,8
							,16
							)
						THEN - 1
					ELSE AT.STATE
					END
			WHERE I.GUIDReference = @pIndividualGUID
				AND AT.STATE NOT IN (
					8
					,4
					,16
					)
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND ActionCode = @ActionCode
					)
				OR (
					@op1 = @IsNotEqualTo
					AND ActionCode <> @ActionCode
					)
				OR (
					@op1 = @IsLessThan
					AND ActionCode < @ActionCode
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND ActionCode <= @ActionCode
					)
				OR (
					@op1 = @IsGreaterThan
					AND ActionCode > @ActionCode
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND ActionCode >= @ActionCode
					)
				OR (
					@op1 = @Contains
					AND ActionCode LIKE '%' + @ActionCodeVarchar + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND ActionCode NOT LIKE '%' + @ActionCodeVarchar + '%'
					)
				OR (
					@op1 = @StartsWith
					AND ActionCode LIKE '' + @ActionCodeVarchar + '%'
					)
				OR (
					@op1 = @EndsWith
					AND ActionCode LIKE '%' + @ActionCodeVarchar + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND ActionLabel = @ActionLabel
					)
				OR (
					@op2 = @IsNotEqualTo
					AND ActionLabel <> @ActionLabel
					)
				OR (
					@op2 = @IsLessThan
					AND ActionLabel < @ActionLabel
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND ActionLabel <= @ActionLabel
					)
				OR (
					@op2 = @IsGreaterThan
					AND ActionLabel > @ActionLabel
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND ActionLabel >= @ActionLabel
					)
				OR (
					@op2 = @Contains
					AND ActionLabel LIKE '%' + @ActionLabel + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND ActionLabel NOT LIKE '%' + @ActionLabel + '%'
					)
				OR (
					@op2 = @StartsWith
					AND ActionLabel LIKE '' + @ActionLabel + '%'
					)
				OR (
					@op2 = @EndsWith
					AND ActionLabel LIKE '%' + @ActionLabel + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND Assignee = @Assignee
					)
				OR (
					@op3 = @IsNotEqualTo
					AND Assignee <> @Assignee
					)
				OR (
					@op3 = @IsLessThan
					AND Assignee < @Assignee
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND Assignee <= @Assignee
					)
				OR (
					@op3 = @IsGreaterThan
					AND Assignee > @Assignee
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND Assignee >= @Assignee
					)
				OR (
					@op3 = @Contains
					AND Assignee LIKE '%' + @Assignee + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND Assignee NOT LIKE '%' + @Assignee + '%'
					)
				OR (
					@op3 = @StartsWith
					AND Assignee LIKE '' + @Assignee + '%'
					)
				OR (
					@op3 = @EndsWith
					AND Assignee LIKE '%' + @Assignee + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND Panel = @Panel
					)
				OR (
					@op4 = @IsNotEqualTo
					AND Panel <> @Panel
					)
				OR (
					@op4 = @IsLessThan
					AND Panel < @Panel
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND Panel <= @Panel
					)
				OR (
					@op4 = @IsGreaterThan
					AND Panel > @Panel
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND Panel >= @Panel
					)
				OR (
					@op4 = @Contains
					AND Panel LIKE '%' + @Panel + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND Panel NOT LIKE '%' + @Panel + '%'
					)
				OR (
					@op4 = @StartsWith
					AND Panel LIKE '' + @Panel + '%'
					)
				OR (
					@op4 = @EndsWith
					AND Panel LIKE '%' + @Panel + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND ActionComment = @ActionComment
					)
				OR (
					@op5 = @IsNotEqualTo
					AND ActionComment <> @ActionComment
					)
				OR (
					@op5 = @IsLessThan
					AND ActionComment < @ActionComment
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND ActionComment <= @ActionComment
					)
				OR (
					@op5 = @IsGreaterThan
					AND ActionComment > @ActionComment
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND ActionComment >= @ActionComment
					)
				OR (
					@op5 = @Contains
					AND ActionComment LIKE '%' + @ActionComment + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND ActionComment NOT LIKE '%' + @ActionComment + '%'
					)
				OR (
					@op5 = @StartsWith
					AND ActionComment LIKE '' + @ActionComment + '%'
					)
				OR (
					@op5 = @EndsWith
					AND ActionComment LIKE '%' + @ActionComment + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 IS NULL
					AND @LogicalOperator6 IS NULL
					)
				OR (
					@LogicalOperator6 = 'OR'
					AND (
						(
							(
								@op6 = @IsEqualTo
								AND CAST(StartDate AS DATETIME) = @StartDate
								)
							OR (
								@op6 = @IsNotEqualTo
								AND CAST(StartDate AS DATETIME) <> @StartDate
								)
							OR (
								@op6 = @IsLessThan
								AND CAST(StartDate AS DATETIME) < @StartDate
								)
							OR (
								@op6 = @IsLessThanOrEqualTo
								AND CAST(StartDate AS DATETIME) <= @StartDate
								)
							OR (
								@op6 = @IsGreaterThan
								AND CAST(StartDate AS DATETIME) > @StartDate
								)
							OR (
								@op6 = @IsGreaterThanOrEqualTo
								AND CAST(StartDate AS DATETIME) >= @StartDate
								)
							OR (
								@op6 = @Contains
								AND StartDate LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @StartsWith
								AND StartDate LIKE '' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @EndsWith
								AND StartDate LIKE '%' + @StartDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop6 = @IsEqualTo
								AND CAST(StartDate AS DATETIME) = @SecondStartDate
								)
							OR (
								@Secondop6 = @IsNotEqualTo
								AND CAST(StartDate AS DATETIME) <> @SecondStartDate
								)
							OR (
								@Secondop6 = @IsLessThan
								AND CAST(StartDate AS DATETIME) < @SecondStartDate
								)
							OR (
								@Secondop6 = @IsLessThanOrEqualTo
								AND CAST(StartDate AS DATETIME) <= @SecondStartDate
								)
							OR (
								@Secondop6 = @IsGreaterThan
								AND CAST(StartDate AS DATETIME) > @SecondStartDate
								)
							OR (
								@Secondop6 = @IsGreaterThanOrEqualTo
								AND CAST(StartDate AS DATETIME) >= @SecondStartDate
								)
							OR (
								@Secondop6 = @Contains
								AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop6 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop6 = @StartsWith
								AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop6 = @EndsWith
								AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator6 = 'AND'
					AND (
						(
							(
								@op6 = @IsEqualTo
								AND CAST(StartDate AS DATETIME) = @StartDate
								)
							OR (
								@op6 = @IsNotEqualTo
								AND CAST(StartDate AS DATETIME) <> @StartDate
								)
							OR (
								@op6 = @IsLessThan
								AND CAST(StartDate AS DATETIME) < @StartDate
								)
							OR (
								@op6 = @IsLessThanOrEqualTo
								AND CAST(StartDate AS DATETIME) <= @StartDate
								)
							OR (
								@op6 = @IsGreaterThan
								AND CAST(StartDate AS DATETIME) > @StartDate
								)
							OR (
								@op6 = @IsGreaterThanOrEqualTo
								AND CAST(StartDate AS DATETIME) >= @StartDate
								)
							OR (
								@op6 = @Contains
								AND StartDate LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @StartsWith
								AND StartDate LIKE '' + @StartDateVarchar + '%'
								)
							OR (
								@op6 = @EndsWith
								AND StartDate LIKE '%' + @StartDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop6 = @IsEqualTo
								AND CAST(StartDate AS DATETIME) = @SecondStartDate
								)
							OR (
								@Secondop6 = @IsNotEqualTo
								AND CAST(StartDate AS DATETIME) <> @SecondStartDate
								)
							OR (
								@Secondop6 = @IsLessThan
								AND CAST(StartDate AS DATETIME) < @SecondStartDate
								)
							OR (
								@Secondop6 = @IsLessThanOrEqualTo
								AND CAST(StartDate AS DATETIME) <= @SecondStartDate
								)
							OR (
								@Secondop6 = @IsGreaterThan
								AND CAST(StartDate AS DATETIME) > @SecondStartDate
								)
							OR (
								@Secondop6 = @IsGreaterThanOrEqualTo
								AND CAST(StartDate AS DATETIME) >= @SecondStartDate
								)
							OR (
								@Secondop6 = @Contains
								AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop6 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop6 = @StartsWith
								AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop6 = @EndsWith
								AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop6 IS NULL
					AND (
						(
							@op6 = @IsEqualTo
							AND CAST(StartDate AS DATETIME) = @StartDate
							)
						OR (
							@op6 = @IsNotEqualTo
							AND CAST(StartDate AS DATETIME) <> @StartDate
							)
						OR (
							@op6 = @IsLessThan
							AND CAST(StartDate AS DATETIME) < @StartDate
							)
						OR (
							@op6 = @IsLessThanOrEqualTo
							AND CAST(StartDate AS DATETIME) <= @StartDate
							)
						OR (
							@op6 = @IsGreaterThan
							AND CAST(StartDate AS DATETIME) > @StartDate
							)
						OR (
							@op6 = @IsGreaterThanOrEqualTo
							AND CAST(StartDate AS DATETIME) >= @StartDate
							)
						OR (
							@op6 = @Contains
							AND StartDate LIKE '%' + @StartDateVarchar + '%'
							)
						OR (
							@op6 = @DoesNotContain
							AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
							)
						OR (
							@op6 = @StartsWith
							AND StartDate LIKE '' + @StartDateVarchar + '%'
							)
						OR (
							@op6 = @EndsWith
							AND StartDate LIKE '%' + @StartDateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 IS NULL
					AND @LogicalOperator7 IS NULL
					)
				OR (
					@LogicalOperator7 = 'OR'
					AND (
						(
							(
								@op7 = @IsEqualTo
								AND CAST(EndDate AS DATETIME) = @EndDate
								)
							OR (
								@op7 = @IsNotEqualTo
								AND CAST(EndDate AS DATETIME) <> @EndDate
								)
							OR (
								@op7 = @IsLessThan
								AND CAST(EndDate AS DATETIME) < @EndDate
								)
							OR (
								@op7 = @IsLessThanOrEqualTo
								AND CAST(EndDate AS DATETIME) <= @EndDate
								)
							OR (
								@op7 = @IsGreaterThan
								AND CAST(EndDate AS DATETIME) > @EndDate
								)
							OR (
								@op7 = @IsGreaterThanOrEqualTo
								AND CAST(EndDate AS DATETIME) >= @EndDate
								)
							OR (
								@op7 = @Contains
								AND EndDate LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @StartsWith
								AND EndDate LIKE '' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @EndsWith
								AND EndDate LIKE '%' + @EndDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop7 = @IsEqualTo
								AND CAST(EndDate AS DATETIME) = @SecondEndDate
								)
							OR (
								@Secondop7 = @IsNotEqualTo
								AND CAST(EndDate AS DATETIME) <> @SecondEndDate
								)
							OR (
								@Secondop7 = @IsLessThan
								AND CAST(EndDate AS DATETIME) < @SecondEndDate
								)
							OR (
								@Secondop7 = @IsLessThanOrEqualTo
								AND CAST(EndDate AS DATETIME) <= @SecondEndDate
								)
							OR (
								@Secondop7 = @IsGreaterThan
								AND CAST(EndDate AS DATETIME) > @SecondEndDate
								)
							OR (
								@Secondop7 = @IsGreaterThanOrEqualTo
								AND CAST(EndDate AS DATETIME) >= @SecondEndDate
								)
							OR (
								@Secondop7 = @Contains
								AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop7 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop7 = @StartsWith
								AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop7 = @EndsWith
								AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator7 = 'AND'
					AND (
						(
							(
								@op7 = @IsEqualTo
								AND CAST(EndDate AS DATETIME) = @EndDate
								)
							OR (
								@op7 = @IsNotEqualTo
								AND CAST(EndDate AS DATETIME) <> @EndDate
								)
							OR (
								@op7 = @IsLessThan
								AND CAST(EndDate AS DATETIME) < @EndDate
								)
							OR (
								@op7 = @IsLessThanOrEqualTo
								AND CAST(EndDate AS DATETIME) <= @EndDate
								)
							OR (
								@op7 = @IsGreaterThan
								AND CAST(EndDate AS DATETIME) > @EndDate
								)
							OR (
								@op7 = @IsGreaterThanOrEqualTo
								AND CAST(EndDate AS DATETIME) >= @EndDate
								)
							OR (
								@op7 = @Contains
								AND EndDate LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @StartsWith
								AND EndDate LIKE '' + @EndDateVarchar + '%'
								)
							OR (
								@op7 = @EndsWith
								AND EndDate LIKE '%' + @EndDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop7 = @IsEqualTo
								AND CAST(EndDate AS DATETIME) = @SecondEndDate
								)
							OR (
								@Secondop7 = @IsNotEqualTo
								AND CAST(EndDate AS DATETIME) <> @SecondEndDate
								)
							OR (
								@Secondop7 = @IsLessThan
								AND CAST(EndDate AS DATETIME) < @SecondEndDate
								)
							OR (
								@Secondop7 = @IsLessThanOrEqualTo
								AND CAST(EndDate AS DATETIME) <= @SecondEndDate
								)
							OR (
								@Secondop7 = @IsGreaterThan
								AND CAST(EndDate AS DATETIME) > @SecondEndDate
								)
							OR (
								@Secondop7 = @IsGreaterThanOrEqualTo
								AND CAST(EndDate AS DATETIME) >= @SecondEndDate
								)
							OR (
								@Secondop7 = @Contains
								AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop7 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop7 = @StartsWith
								AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop7 = @EndsWith
								AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop7 IS NULL
					AND (
						(
							@op7 = @IsEqualTo
							AND CAST(EndDate AS DATETIME) = @EndDate
							)
						OR (
							@op7 = @IsNotEqualTo
							AND CAST(EndDate AS DATETIME) <> @EndDate
							)
						OR (
							@op7 = @IsLessThan
							AND CAST(EndDate AS DATETIME) < @EndDate
							)
						OR (
							@op7 = @IsLessThanOrEqualTo
							AND CAST(EndDate AS DATETIME) <= @EndDate
							)
						OR (
							@op7 = @IsGreaterThan
							AND CAST(EndDate AS DATETIME) > @EndDate
							)
						OR (
							@op7 = @IsGreaterThanOrEqualTo
							AND CAST(EndDate AS DATETIME) >= @EndDate
							)
						OR (
							@op7 = @Contains
							AND EndDate LIKE '%' + @EndDateVarchar + '%'
							)
						OR (
							@op7 = @DoesNotContain
							AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
							)
						OR (
							@op7 = @StartsWith
							AND EndDate LIKE '' + @EndDateVarchar + '%'
							)
						OR (
							@op7 = @EndsWith
							AND EndDate LIKE '%' + @EndDateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op8 IS NULL)
				OR (
					@op8 = @IsEqualTo
					AND Questionnaire = @Questionnaire
					)
				OR (
					@op8 = @IsNotEqualTo
					AND Questionnaire <> @Questionnaire
					)
				OR (
					@op8 = @IsLessThan
					AND Questionnaire < @Questionnaire
					)
				OR (
					@op8 = @IsLessThanOrEqualTo
					AND Questionnaire <= @Questionnaire
					)
				OR (
					@op8 = @IsGreaterThan
					AND Questionnaire > @Questionnaire
					)
				OR (
					@op8 = @IsGreaterThanOrEqualTo
					AND Questionnaire >= @Questionnaire
					)
				OR (
					@op8 = @Contains
					AND Questionnaire LIKE '%' + @Questionnaire + '%'
					)
				OR (
					@op8 = @DoesNotContain
					AND Questionnaire NOT LIKE '%' + @Questionnaire + '%'
					)
				OR (
					@op8 = @StartsWith
					AND Questionnaire LIKE '' + @Questionnaire + '%'
					)
				OR (
					@op8 = @EndsWith
					AND Questionnaire LIKE '%' + @Questionnaire + ''
					)
				)
		ORDER BY CASE 
				WHEN @pOrderBy = 'ActionCode'
					AND @pOrderType = 'asc'
					THEN ActionCode
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionCode'
					AND @pOrderType = 'desc'
					THEN ActionCode
				END DESC
			,CASE 
				WHEN @pOrderBy = 'ActionLabel'
					AND @pOrderType = 'asc'
					THEN ActionLabel
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionLabel'
					AND @pOrderType = 'desc'
					THEN ActionLabel
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Assignee'
					AND @pOrderType = 'asc'
					THEN Assignee
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Assignee'
					AND @pOrderType = 'desc'
					THEN Assignee
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Panel'
					AND @pOrderType = 'asc'
					THEN Panel
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Panel'
					AND @pOrderType = 'desc'
					THEN Panel
				END DESC
			,CASE 
				WHEN @pOrderBy = 'ActionComment'
					AND @pOrderType = 'asc'
					THEN ActionComment
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionComment'
					AND @pOrderType = 'desc'
					THEN ActionComment
				END DESC
			,CASE 
				WHEN @pOrderBy = 'StartDate'
					AND @pOrderType = 'asc'
					THEN StartDate
				END ASC
			,CASE 
				WHEN @pOrderBy = 'StartDate'
					AND @pOrderType = 'desc'
					THEN StartDate
				END DESC
			,CASE 
				WHEN @pOrderBy = 'EndDate'
					AND @pOrderType = 'asc'
					THEN EndDate
				END ASC
			,CASE 
				WHEN @pOrderBy = 'EndDate'
					AND @pOrderType = 'desc'
					THEN EndDate
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Questionnaire'
					AND @pOrderType = 'asc'
					THEN Questionnaire
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Questionnaire'
					AND @pOrderType = 'desc'
					THEN Questionnaire
				END DESC
			,CASE 
				WHEN @pOrderBy IS NULL
					THEN CreationTimeStamp
				END DESC
			--end desc    
			OFFSET @OFFSETRows rows

		FETCH NEXT @pPageSize rows ONLY
		OPTION (RECOMPILE)

		DROP TABLE #ActionTaskPermissions
	END TRY

	BEGIN CATCH
		RAISERROR (
				'Error executing the script'
				,16
				,1
				);
	END CATCH
END
