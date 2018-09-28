/*##########################################################################
-- Name             : GetScheduledActionTasks
-- Date             : 2014-11-05
-- Author           : Jagadeesh B
-- Purpose          : To Get the Scheduled Action Tasks
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
       @pCountryCode NVARCHAR(10) -- Country Code
       @pCultureCode int  - Culture Code of type int
	   @pCommInProgressState - Communication InProgress State
	   @pTodoState			- ActionTaskStateEnum ToDo state
	   @pActionInProgessState - ActionTaskStateEnum InProgress state
	   @pTodoStateLabelKey NVARCHAR(256) - ActionState ToDo translation key
	   @pInProgressStateLabelKey NVARCHAR(256)- ActionState InProgress translation key
	   @pOrderBy - order by coulmn name
	   @pOrderType - Order by type (desc or asc)
	   @pPageNumber - page number 
	   @pPageSize - Size of the page
	   @pIsExport bool - 
	   @pParametersTable dbo.GridParametersTable type table conatines all paging and order by, serach values
-- Sample Execution :
SET STATISTICS time ON
declare @p8 dbo.GridParametersTable
--insert into @p8 values(N'ActionCode',N'8',N'IsNotEqualTo',NULL,NULL,NULL)
--insert into @p8 values(N'CreationTimeStamp',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
--insert into @p8 values(N'Points',N'100',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
--insert into @p8 values(N'DiaryDateFull',N'2006.7.4',N'IsEqualTo',NULL,NULL,NULL)
--insert into @p8 values(N'BusinessId',N'10257901-01',N'IsEqualTo',NULL,NULL,NULL)
exec GetScheduledActionTasks '17D348D8-A08D-CE7A-CB8C-08CF81794A86',2057,1,1,2,'ActionState.ToDo','ActionState.InProgress','nextcall','desc',1,100,0,@p8

##########################################################################
-- version  user                                       date        change 
-- 1.0     Jagadeesh B                            2014-11-27   Initial
##########################################################################*/
CREATE PROCEDURE GetScheduledActionTasks (
	@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pCommInProgressState INT
	,@pTodoState INT
	,@pActionInProgessState INT
	,@pTodoStateLabelKey NVARCHAR(1000)
	,@pInProgressStateLabelKey NVARCHAR(1000)
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10)
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly
	,@pGPSUser VARCHAR(100) = ''
	)
AS
BEGIN
	SET NOCOUNT ON;	
	BEGIN TRY
		DECLARE @TodoStateLabel NVARCHAR(1000)
		DECLARE @InProgressStateLabel NVARCHAR(1000)

		DECLARE @Local_Getdate DATETIME
	SET @Local_Getdate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))

		DECLARE @Getdate DATE = CAST(@Local_Getdate AS DATE)

		SELECT @TodoStateLabel = ISNULL(tr.Value, '{' + t.KeyName + '}')
		FROM Translation t
		LEFT JOIN TranslationTerm tr ON t.TranslationId = tr.Translation_Id
			AND tr.CultureCode = @pCultureCode
		WHERE t.KeyName = @pTodoStateLabelKey

		SELECT @InProgressStateLabel = ISNULL(tr.Value, '{' + t.KeyName + '}')
		FROM Translation t
		LEFT JOIN TranslationTerm tr ON t.TranslationId = tr.Translation_Id
			AND tr.CultureCode = @pCultureCode
		WHERE t.KeyName = @pInProgressStateLabelKey

		DECLARE @DealtByCommunicationTeam NVARCHAR(256) = 'DealtByCommunicationTeam'
		DECLARE @EmptyGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
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
		DECLARE @LogicalOperator7 VARCHAR(5)
			,@LogicalOperator8 VARCHAR(5)
			,@LogicalOperator10 VARCHAR(5)
			,@LogicalOperator13 VARCHAR(5)
		DECLARE @Secondop7 VARCHAR(50)
			,@Secondop8 VARCHAR(50)
			,@Secondop10 VARCHAR(50)
			,@Secondop13 VARCHAR(50)
		DECLARE @SecondStartDate DATETIME
			,@SecondEndDate DATETIME
			,@SecondLastCallDate DATETIME
			,@SecondCallBackDate DATETIME
		DECLARE @BusinessId NVARCHAR(100)
			,@ActionCode INT
			,@ActionLabel NVARCHAR(1000)
			,@Assigned NVARCHAR(256)
			,@Panel NVARCHAR(100)
			,@ActionComment NVARCHAR(1000)
			,@StartDate DATETIME
			,@EndDate DATETIME
			,@StatusLabel NVARCHAR(1000)
			,@LastCallDate DATETIME
			,@NextCall NVARCHAR(1000)
			,@ActionTaskPriority NVARCHAR(1000)
			,@CallBackDateTime DATETIME

		SELECT @op1 = Opertor
			,@BusinessId = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'BusinessId'

		SELECT @op2 = Opertor
			,@ActionCode = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionCode'

		SELECT @op3 = Opertor
			,@ActionLabel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionLabel'

		SELECT @op4 = Opertor
			,@Assigned = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'Assignee'

		SELECT @op5 = Opertor
			,@Panel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'Panel'

		SELECT @op6 = Opertor
			,@ActionComment = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionComment'

		SELECT @op7 = Opertor
			,@StartDate = CAST(ParameterValue AS DATETIME)
			,@Secondop7 = SecondParameterOperator
			,@SecondStartDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator7 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'StartDate'

		SELECT @op8 = Opertor
			,@EndDate = CAST(ParameterValue AS DATETIME)
			,@Secondop8 = SecondParameterOperator
			,@SecondEndDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator8 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'EndDate'

		SELECT @op9 = Opertor
			,@StatusLabel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'StatusLabel'

		SELECT @op10 = Opertor
			,@LastCallDate = CAST(ParameterValue AS DATETIME)
			,@Secondop10 = SecondParameterOperator
			,@SecondLastCallDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator8 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'LastCallDate'

		SELECT @op11 = Opertor
			,@NextCall = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'NextCall'

		SELECT @op12 = Opertor
			,@ActionTaskPriority = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ActionTaskPriority'

		SELECT @op13 = Opertor
			,@CallBackDateTime = CAST(ParameterValue AS DATETIME)
			,@Secondop13 = SecondParameterOperator
			,@SecondCallBackDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator13 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'CallBackDateTime'

		DECLARE @ActionCodeVarchar VARCHAR(100) = CAST(@ActionCode AS VARCHAR)
			,@StartDateVarchar VARCHAR(100) = CAST(@StartDate AS VARCHAR)
			,@EndDateVarchar VARCHAR(100) = CAST(@EndDate AS VARCHAR)
			,@LastCallDateVarchar VARCHAR(100) = CAST(@LastCallDate AS VARCHAR)
			,@CallBackDateTimeVarchar VARCHAR(100) = CAST(@CallBackDateTime AS VARCHAR)
			,@SecondStartDateVarchar VARCHAR(100) = CAST(@SecondStartDate AS VARCHAR)
			,@SecondEndDateVarchar VARCHAR(100) = CAST(@SecondEndDate AS VARCHAR)
			,@SecondLastCallDateVarchar VARCHAR(100) = CAST(@SecondLastCallDate AS VARCHAR)
			,@SecondCallBackDateTimeVarchar VARCHAR(100) = CAST(@SecondCallBackDate AS VARCHAR)
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

		DECLARE @CheckNewSignupActionTaskTypeId UNIQUEIDENTIFIER
		DECLARE @CheckNewSignupCallRequiredActionTaskTypeId UNIQUEIDENTIFIER

		SELECT @CheckNewSignupActionTaskTypeId = CountryConfiguration.CheckNewSignupActionTaskTypeId
			,@CheckNewSignupCallRequiredActionTaskTypeId = CountryConfiguration.CheckNewSignupCallRequiredActionTaskTypeId
		FROM Country
		INNER JOIN CountryConfiguration ON CountryConfiguration.Id = Country.Configuration_Id
			AND Country.CountryId = @pCountryId

		IF (@pIsExport = 0)
			SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
		ELSE
			SET @pPageSize = 15000;


		IF (@pIsExport = 0)
		BEGIN
			WITH alldata
			AS (
				SELECT 
					IIF(atType.[Type] = @DealtByCommunicationTeam, 1, 0) AS IsDealtByCommunicationTeam,
					IIF(atType.GUIDReference IN (@CheckNewSignupActionTaskTypeId, @CheckNewSignupCallRequiredActionTaskTypeId), 1, 0) AS IsCheckNewSignUpAction
					,at.CreationTimeStamp AS CreationTimeStamp
					,at.GUIDReference AS ActionTaskId
					,ISNULL(at.Candidate_Id, @EmptyGuid) AS Id
					,at.ActionComment AS ActionComment
					,at.StartDate
					,at.EndDate
					,atType.GUIDReference AS ActionTaskTypeId
					,atType.ActionCode AS ActionCode
					,dbo.GetTranslationValue(atType.TagTranslation_Id, @pCultureCode) AS ActionLabel
					,IIF(at.[State] = @pTodoState, @TodoStateLabel, @InProgressStateLabel) AS StatusLabel
					,i.IndividualId AS BusinessId
					,(SELECT TOP 1 CreationDate FROM CalendarEvent WHERE Candidate_Id=i.GUIDReference ORDER BY 1 DESC) AS LastCallDate
					,at.[State] AS ActionState
					,u.UserName AS Assignee
					,p.Name AS Panel
					,IIF(i.GUIDReference IS NOT NULL, dbo.GetTranslationValue(efreq.Translation_Id, @pCultureCode), '') AS NextCall
					,at.Country_Id AS Country_Id
					,dbo.GetTranslationValue(ap.Translation_Id, @pCultureCode) as ActionTaskPriority
					,at.CallBackDateTime
				FROM ActionTask at
				INNER JOIN ActionTaskType atType ON at.ActionTaskType_Id = atType.[GUIDReference]
					AND at.Country_Id = @pCountryId
					AND at.[State] IN (
						@pTodoState
						,@pActionInProgessState
						)
				LEFT JOIN Individual i ON i.GUIDReference = at.Candidate_Id
				LEFT JOIN IdentityUser u ON u.Id = at.Assignee_Id
				LEFT JOIN Panel p ON p.GUIDReference = at.Panel_Id
				LEFT JOIN CalendarEvent ce ON ce.Id = i.Event_Id
				LEFT JOIN EventFrequency efreq ON efreq.GUIDReference = ce.Frequency_Id
				LEFT JOIN ActionTaskPriorities ap ON ap.Id = at.ActionTaskPriority AND ap.CountryId=at.Country_Id
				WHERE
					NOT EXISTS (SELECT 1 FROM CommunicationEvent WHERE Candidate_Id = at.Candidate_Id AND [State] = @pCommInProgressState AND GPSUser LIKE @pGPSUser)
					AND atType.IsDealtByCommunicationTeam = 1 AND atType.[Type] = 'DealtByCommunicationTeam'			
					AND ISNULL(i.GUIDReference,@EmptyGuid) NOT IN (
						SELECT e.Parent_Id
						FROM Exclusion e
						INNER JOIN ExclusionType et ON (
								CAST(e.[Range_From] AS DATE)<= @Getdate
								AND CAST(e.[Range_To] AS DATE)>= @Getdate
								)
							AND et.GUIDReference = e.[Type_Id]
							AND et.AllowedContact <> 1
							AND Country_Id = @pCountryId
						)
				)
			SELECT COUNT(0) AS TotalRecords
			FROM alldata
			WHERE (
					(@op1 IS NULL)
					OR (
						@op1 = @IsEqualTo
						AND BusinessId = @BusinessId
						)
					OR (
						@op1 = @IsNotEqualTo
						AND BusinessId <> @BusinessId
						)
					OR (
						@op1 = @IsLessThan
						AND BusinessId < @BusinessId
						)
					OR (
						@op1 = @IsLessThanOrEqualTo
						AND BusinessId <= @BusinessId
						)
					OR (
						@op1 = @IsGreaterThan
						AND BusinessId > @BusinessId
						)
					OR (
						@op1 = @IsGreaterThanOrEqualTo
						AND BusinessId >= @BusinessId
						)
					OR (
						@op1 = @Contains
						AND BusinessId LIKE '%' + @BusinessId + '%'
						)
					OR (
						@op1 = @DoesNotContain
						AND BusinessId NOT LIKE '%' + @BusinessId + '%'
						)
					OR (
						@op1 = @StartsWith
						AND BusinessId LIKE '' + @BusinessId + '%'
						)
					OR (
						@op1 = @EndsWith
						AND BusinessId LIKE '%' + @BusinessId + ''
						)
					)
				AND (
					(@op2 IS NULL)
					OR (
						@op2 = @IsEqualTo
						AND ActionCode = @ActionCode
						)
					OR (
						@op2 = @IsNotEqualTo
						AND ActionCode <> @ActionCode
						)
					OR (
						@op2 = @IsLessThan
						AND ActionCode < @ActionCode
						)
					OR (
						@op2 = @IsLessThanOrEqualTo
						AND ActionCode <= @ActionCode
						)
					OR (
						@op2 = @IsGreaterThan
						AND ActionCode > @ActionCode
						)
					OR (
						@op2 = @IsGreaterThanOrEqualTo
						AND ActionCode >= @ActionCode
						)
					OR (
						@op2 = @Contains
						AND ActionCode LIKE '%' + @ActionCodeVarchar + '%'
						)
					OR (
						@op2 = @DoesNotContain
						AND ActionCode NOT LIKE '%' + @ActionCodeVarchar + '%'
						)
					OR (
						@op2 = @StartsWith
						AND ActionCode LIKE '' + @ActionCodeVarchar + '%'
						)
					OR (
						@op2 = @EndsWith
						AND ActionCode LIKE '%' + @ActionCodeVarchar + ''
						)
					)
				AND (
					(@op3 IS NULL)
					OR (
						@op3 = @IsEqualTo
						AND ActionLabel = @ActionLabel
						)
					OR (
						@op3 = @IsNotEqualTo
						AND ActionLabel <> @ActionLabel
						)
					OR (
						@op3 = @IsLessThan
						AND ActionLabel < @ActionLabel
						)
					OR (
						@op3 = @IsLessThanOrEqualTo
						AND ActionLabel <= @ActionLabel
						)
					OR (
						@op3 = @IsGreaterThan
						AND ActionLabel > @ActionLabel
						)
					OR (
						@op3 = @IsGreaterThanOrEqualTo
						AND ActionLabel >= @ActionLabel
						)
					OR (
						@op3 = @Contains
						AND ActionLabel LIKE '%' + @ActionLabel + '%'
						)
					OR (
						@op3 = @DoesNotContain
						AND ActionLabel NOT LIKE '%' + @ActionLabel + '%'
						)
					OR (
						@op3 = @StartsWith
						AND ActionLabel LIKE '' + @ActionLabel + '%'
						)
					OR (
						@op3 = @EndsWith
						AND ActionLabel LIKE '%' + @ActionLabel + ''
						)
					)
				AND (
					(@op4 IS NULL)
					OR (
						@op4 = @IsEqualTo
						AND Assignee = @Assigned
						)
					OR (
						@op4 = @IsNotEqualTo
						AND Assignee <> @Assigned
						)
					OR (
						@op4 = @IsLessThan
						AND Assignee < @Assigned
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND Assignee <= @Assigned
						)
					OR (
						@op4 = @IsGreaterThan
						AND Assignee > @Assigned
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND Assignee >= @Assigned
						)
					OR (
						@op4 = @Contains
						AND Assignee LIKE '%' + @Assigned + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND Assignee NOT LIKE '%' + @Assigned + '%'
						)
					OR (
						@op4 = @StartsWith
						AND Assignee LIKE '' + @Assigned + '%'
						)
					OR (
						@op4 = @EndsWith
						AND Assignee LIKE '%' + @Assigned + ''
						)
					)
				AND (
					(@op5 IS NULL)
					OR (
						@op5 = @IsEqualTo
						AND Panel = @Panel
						)
					OR (
						@op5 = @IsNotEqualTo
						AND Panel <> @Panel
						)
					OR (
						@op5 = @IsLessThan
						AND Panel < @Panel
						)
					OR (
						@op5 = @IsLessThanOrEqualTo
						AND Panel <= @Panel
						)
					OR (
						@op5 = @IsGreaterThan
						AND Panel > @Panel
						)
					OR (
						@op5 = @IsGreaterThanOrEqualTo
						AND Panel >= @Panel
						)
					OR (
						@op5 = @Contains
						AND Panel LIKE '%' + @Panel + '%'
						)
					OR (
						@op5 = @DoesNotContain
						AND Panel NOT LIKE '%' + @Panel + '%'
						)
					OR (
						@op5 = @StartsWith
						AND Panel LIKE '' + @Panel + '%'
						)
					OR (
						@op5 = @EndsWith
						AND Panel LIKE '%' + @Panel + ''
						)
					)
				AND (
					(@op6 IS NULL)
					OR (
						@op6 = @IsEqualTo
						AND ActionComment = @ActionComment
						)
					OR (
						@op6 = @IsNotEqualTo
						AND ActionComment <> @ActionComment
						)
					OR (
						@op6 = @IsLessThan
						AND ActionComment < @ActionComment
						)
					OR (
						@op6 = @IsLessThanOrEqualTo
						AND ActionComment <= @ActionComment
						)
					OR (
						@op6 = @IsGreaterThan
						AND ActionComment > @ActionComment
						)
					OR (
						@op6 = @IsGreaterThanOrEqualTo
						AND ActionComment >= @ActionComment
						)
					OR (
						@op6 = @Contains
						AND ActionComment LIKE '%' + @ActionComment + '%'
						)
					OR (
						@op6 = @DoesNotContain
						AND ActionComment NOT LIKE '%' + @ActionComment + '%'
						)
					OR (
						@op6 = @StartsWith
						AND ActionComment LIKE '' + @ActionComment + '%'
						)
					OR (
						@op6 = @EndsWith
						AND ActionComment LIKE '%' + @ActionComment + ''
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
									AND StartDate = @StartDate
									)
								OR (
									@op7 = @IsNotEqualTo
									AND StartDate <> @StartDate
									)
								OR (
									@op7 = @IsLessThan
									AND StartDate < @StartDate
									)
								OR (
									@op7 = @IsLessThanOrEqualTo
									AND StartDate <= @StartDate
									)
								OR (
									@op7 = @IsGreaterThan
									AND StartDate > @StartDate
									)
								OR (
									@op7 = @IsGreaterThanOrEqualTo
									AND StartDate >= @StartDate
									)
								OR (
									@op7 = @Contains
									AND StartDate LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op7 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op7 = @StartsWith
									AND StartDate LIKE '' + @StartDateVarchar + '%'
									)
								OR (
									@op7 = @EndsWith
									AND StartDate LIKE '%' + @StartDateVarchar + ''
									)
								)
							OR (
								(
									@Secondop7 = @IsEqualTo
									AND StartDate = @SecondStartDate
									)
								OR (
									@Secondop7 = @IsNotEqualTo
									AND StartDate <> @SecondStartDate
									)
								OR (
									@Secondop7 = @IsLessThan
									AND StartDate < @SecondStartDate
									)
								OR (
									@Secondop7 = @IsLessThanOrEqualTo
									AND StartDate <= @SecondStartDate
									)
								OR (
									@Secondop7 = @IsGreaterThan
									AND StartDate > @SecondStartDate
									)
								OR (
									@Secondop7 = @IsGreaterThanOrEqualTo
									AND StartDate >= @SecondStartDate
									)
								OR (
									@Secondop7 = @Contains
									AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop7 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop7 = @StartsWith
									AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop7 = @EndsWith
									AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
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
									AND StartDate = @StartDate
									)
								OR (
									@op7 = @IsNotEqualTo
									AND StartDate <> @StartDate
									)
								OR (
									@op7 = @IsLessThan
									AND StartDate < @StartDate
									)
								OR (
									@op7 = @IsLessThanOrEqualTo
									AND StartDate <= @StartDate
									)
								OR (
									@op7 = @IsGreaterThan
									AND StartDate > @StartDate
									)
								OR (
									@op7 = @IsGreaterThanOrEqualTo
									AND StartDate >= @StartDate
									)
								OR (
									@op7 = @Contains
									AND StartDate LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op7 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
									)
								OR (
									@op7 = @StartsWith
									AND StartDate LIKE '' + @StartDateVarchar + '%'
									)
								OR (
									@op7 = @EndsWith
									AND StartDate LIKE '%' + @StartDateVarchar + ''
									)
								)
							AND (
								(
									@Secondop7 = @IsEqualTo
									AND StartDate = @SecondStartDate
									)
								OR (
									@Secondop7 = @IsNotEqualTo
									AND StartDate <> @SecondStartDate
									)
								OR (
									@Secondop7 = @IsLessThan
									AND StartDate < @SecondStartDate
									)
								OR (
									@Secondop7 = @IsLessThanOrEqualTo
									AND StartDate <= @SecondStartDate
									)
								OR (
									@Secondop7 = @IsGreaterThan
									AND StartDate > @SecondStartDate
									)
								OR (
									@Secondop7 = @IsGreaterThanOrEqualTo
									AND StartDate >= @SecondStartDate
									)
								OR (
									@Secondop7 = @Contains
									AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop7 = @DoesNotContain
									AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop7 = @StartsWith
									AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
									)
								OR (
									@Secondop7 = @EndsWith
									AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
									)
								)
							)
						)
					OR (@Secondop7 IS NULL 
						AND
						(
							 (
								@op7 = @IsEqualTo
								AND StartDate = @StartDate
								)
							OR (
								@op7 = @IsNotEqualTo
								AND StartDate <> @StartDate
								)
							OR (
								@op7 = @IsLessThan
								AND StartDate < @StartDate
								)
							OR (
								@op7 = @IsLessThanOrEqualTo
								AND StartDate <= @StartDate
								)
							OR (
								@op7 = @IsGreaterThan
								AND StartDate > @StartDate
								)
							OR (
								@op7 = @IsGreaterThanOrEqualTo
								AND StartDate >= @StartDate
								)
							OR (
								@op7 = @Contains
								AND StartDate LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @StartsWith
								AND StartDate LIKE '' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @EndsWith
								AND StartDate LIKE '%' + @StartDateVarchar + ''
								)
						)
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
									AND EndDate = @EndDate
									)
								OR (
									@op8 = @IsNotEqualTo
									AND EndDate <> @EndDate
									)
								OR (
									@op8 = @IsLessThan
									AND EndDate < @EndDate
									)
								OR (
									@op8 = @IsLessThanOrEqualTo
									AND EndDate <= @EndDate
									)
								OR (
									@op8 = @IsGreaterThan
									AND EndDate > @EndDate
									)
								OR (
									@op8 = @IsGreaterThanOrEqualTo
									AND EndDate >= @EndDate
									)
								OR (
									@op8 = @Contains
									AND EndDate LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op8 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op8 = @StartsWith
									AND EndDate LIKE '' + @EndDateVarchar + '%'
									)
								OR (
									@op8 = @EndsWith
									AND EndDate LIKE '%' + @EndDateVarchar + ''
									)
								)
							OR (
								(
									@Secondop8 = @IsEqualTo
									AND EndDate = @SecondEndDate
									)
								OR (
									@Secondop8 = @IsNotEqualTo
									AND EndDate <> @SecondEndDate
									)
								OR (
									@Secondop8 = @IsLessThan
									AND EndDate < @SecondEndDate
									)
								OR (
									@Secondop8 = @IsLessThanOrEqualTo
									AND EndDate <= @SecondEndDate
									)
								OR (
									@Secondop8 = @IsGreaterThan
									AND EndDate > @SecondEndDate
									)
								OR (
									@Secondop8 = @IsGreaterThanOrEqualTo
									AND EndDate >= @SecondEndDate
									)
								OR (
									@Secondop8 = @Contains
									AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop8 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop8 = @StartsWith
									AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop8 = @EndsWith
									AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
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
									AND EndDate = @EndDate
									)
								OR (
									@op8 = @IsNotEqualTo
									AND EndDate <> @EndDate
									)
								OR (
									@op8 = @IsLessThan
									AND EndDate < @EndDate
									)
								OR (
									@op8 = @IsLessThanOrEqualTo
									AND EndDate <= @EndDate
									)
								OR (
									@op8 = @IsGreaterThan
									AND EndDate > @EndDate
									)
								OR (
									@op8 = @IsGreaterThanOrEqualTo
									AND EndDate >= @EndDate
									)
								OR (
									@op8 = @Contains
									AND EndDate LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op8 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
									)
								OR (
									@op8 = @StartsWith
									AND EndDate LIKE '' + @EndDateVarchar + '%'
									)
								OR (
									@op8 = @EndsWith
									AND EndDate LIKE '%' + @EndDateVarchar + ''
									)
								)
							AND (
								(
									@Secondop8 = @IsEqualTo
									AND EndDate = @SecondEndDate
									)
								OR (
									@Secondop8 = @IsNotEqualTo
									AND EndDate <> @SecondEndDate
									)
								OR (
									@Secondop8 = @IsLessThan
									AND EndDate < @SecondEndDate
									)
								OR (
									@Secondop8 = @IsLessThanOrEqualTo
									AND EndDate <= @SecondEndDate
									)
								OR (
									@Secondop8 = @IsGreaterThan
									AND EndDate > @SecondEndDate
									)
								OR (
									@Secondop8 = @IsGreaterThanOrEqualTo
									AND EndDate >= @SecondEndDate
									)
								OR (
									@Secondop8 = @Contains
									AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop8 = @DoesNotContain
									AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop8 = @StartsWith
									AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
									)
								OR (
									@Secondop8 = @EndsWith
									AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
									)
								)
							)
						)
					OR (@Secondop8 IS NULL 
					    AND 
						(
							   (
								@op8 = @IsEqualTo
								AND EndDate = @EndDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND EndDate <> @EndDate
								)
							OR (
								@op8 = @IsLessThan
								AND EndDate < @EndDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND EndDate <= @EndDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND EndDate > @EndDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND EndDate >= @EndDate
								)
							OR (
								@op8 = @Contains
								AND EndDate LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND EndDate LIKE '' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND EndDate LIKE '%' + @EndDateVarchar + ''
								)
						)
					 )
					)
				AND (
					(@op9 IS NULL)
					OR (
						@op9 = @IsEqualTo
						AND StatusLabel = @StatusLabel
						)
					OR (
						@op9 = @IsNotEqualTo
						AND StatusLabel <> @StatusLabel
						)
					OR (
						@op9 = @IsLessThan
						AND StatusLabel < @StatusLabel
						)
					OR (
						@op9 = @IsLessThanOrEqualTo
						AND StatusLabel <= @StatusLabel
						)
					OR (
						@op9 = @IsGreaterThan
						AND StatusLabel > @StatusLabel
						)
					OR (
						@op9 = @IsGreaterThanOrEqualTo
						AND ActionComment >= @StatusLabel
						)
					OR (
						@op9 = @Contains
						AND StatusLabel LIKE '%' + @StatusLabel + '%'
						)
					OR (
						@op9 = @DoesNotContain
						AND StatusLabel NOT LIKE '%' + @StatusLabel + '%'
						)
					OR (
						@op9 = @StartsWith
						AND StatusLabel LIKE '' + @StatusLabel + '%'
						)
					OR (
						@op9 = @EndsWith
						AND StatusLabel LIKE '%' + @StatusLabel + ''
						)
					)
				AND (
					(@op10 IS NULL)
					OR (
						@op10 IS NULL
						AND @LogicalOperator8 IS NULL
						)
					OR (
						@LogicalOperator10 = 'OR'
						AND (
							(
								(
									@op10 = @IsEqualTo
									AND LastCallDate = @LastCallDate
									)
								OR (
									@op10 = @IsNotEqualTo
									AND LastCallDate <> @LastCallDate
									)
								OR (
									@op10 = @IsLessThan
									AND LastCallDate < @LastCallDate
									)
								OR (
									@op10 = @IsLessThanOrEqualTo
									AND LastCallDate <= @LastCallDate
									)
								OR (
									@op10 = @IsGreaterThan
									AND LastCallDate > @LastCallDate
									)
								OR (
									@op10 = @IsGreaterThanOrEqualTo
									AND LastCallDate >= @LastCallDate
									)
								OR (
									@op10 = @Contains
									AND LastCallDate LIKE '%' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @DoesNotContain
									AND LastCallDate NOT LIKE '%' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @StartsWith
									AND LastCallDate LIKE '' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @EndsWith
									AND LastCallDate LIKE '%' + @LastCallDateVarchar + ''
									)
								)
							OR (
								(
									@Secondop10 = @IsEqualTo
									AND LastCallDate = @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsNotEqualTo
									AND LastCallDate <> @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsLessThan
									AND LastCallDate < @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsLessThanOrEqualTo
									AND LastCallDate <= @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsGreaterThan
									AND LastCallDate > @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsGreaterThanOrEqualTo
									AND LastCallDate >= @SecondLastCallDate
									)
								OR (
									@Secondop10 = @Contains
									AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + '%'
									)
								OR (
									@Secondop10 = @DoesNotContain
									AND LastCallDate NOT LIKE '%' + @SecondLastCallDateVarchar + '%'
									)
								OR (
									@Secondop10 = @StartsWith
									AND LastCallDate LIKE '' + @SecondLastCallDateVarchar + '%'
									)
								OR (
									@Secondop10 = @EndsWith
									AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator10 = 'AND'
						AND (
							(
								(
									@op10 = @IsEqualTo
									AND LastCallDate = @LastCallDate
									)
								OR (
									@op10 = @IsNotEqualTo
									AND LastCallDate <> @LastCallDate
									)
								OR (
									@op10 = @IsLessThan
									AND LastCallDate < @LastCallDate
									)
								OR (
									@op10 = @IsLessThanOrEqualTo
									AND LastCallDate <= @LastCallDate
									)
								OR (
									@op10 = @IsGreaterThan
									AND LastCallDate > @LastCallDate
									)
								OR (
									@op10 = @IsGreaterThanOrEqualTo
									AND LastCallDate >= @LastCallDate
									)
								OR (
									@op10 = @Contains
									AND LastCallDate LIKE '%' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @DoesNotContain
									AND LastCallDate NOT LIKE '%' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @StartsWith
									AND LastCallDate LIKE '' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @EndsWith
									AND LastCallDate LIKE '%' + @LastCallDateVarchar + ''
									)
								)
							AND (
								(
									@Secondop10 = @IsEqualTo
									AND LastCallDate = @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsNotEqualTo
									AND LastCallDate <> @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsLessThan
									AND LastCallDate < @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsLessThanOrEqualTo
									AND LastCallDate <= @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsGreaterThan
									AND LastCallDate > @SecondLastCallDate
									)
								OR (
									@Secondop10 = @IsGreaterThanOrEqualTo
									AND LastCallDate >= @SecondLastCallDate
									)
								OR (
									@Secondop10 = @Contains
									AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + '%'
									)
								OR (
									@Secondop10 = @DoesNotContain
									AND LastCallDate NOT LIKE '%' + @SecondLastCallDateVarchar + '%'
									)
								OR (
									@Secondop10 = @StartsWith
									AND LastCallDate LIKE '' + @SecondLastCallDateVarchar + '%'
									)
								OR (
									@Secondop10 = @EndsWith
									AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + ''
									)
								)
							)
						)
					OR (@Secondop10 IS NULL 
							AND
							(
								 (
									@op10 = @IsEqualTo
									AND LastCallDate = @LastCallDate
									)
								OR (
									@op10 = @IsNotEqualTo
									AND LastCallDate <> @LastCallDate
									)
								OR (
									@op10 = @IsLessThan
									AND LastCallDate < @LastCallDate
									)
								OR (
									@op10 = @IsLessThanOrEqualTo
									AND LastCallDate <= @LastCallDate
									)
								OR (
									@op10 = @IsGreaterThan
									AND LastCallDate > @LastCallDate
									)
								OR (
									@op10 = @IsGreaterThanOrEqualTo
									AND LastCallDate >= @LastCallDate
									)
								OR (
									@op10 = @Contains
									AND LastCallDate LIKE '%' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @DoesNotContain
									AND LastCallDate NOT LIKE '%' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @StartsWith
									AND LastCallDate LIKE '' + @LastCallDateVarchar + '%'
									)
								OR (
									@op10 = @EndsWith
									AND LastCallDate LIKE '%' + @LastCallDateVarchar + ''
									)
							)
						)
					)
				AND (
					(@op11 IS NULL)
					OR (
						@op11 = @IsEqualTo
						AND NextCall = @NextCall
						)
					OR (
						@op11 = @IsNotEqualTo
						AND NextCall <> @NextCall
						)
					OR (
						@op11 = @IsLessThan
						AND NextCall < @NextCall
						)
					OR (
						@op11 = @IsLessThanOrEqualTo
						AND NextCall <= @NextCall
						)
					OR (
						@op11 = @IsGreaterThan
						AND NextCall > @NextCall
						)
					OR (
						@op11 = @IsGreaterThanOrEqualTo
						AND NextCall >= @NextCall
						)
					OR (
						@op11 = @Contains
						AND NextCall LIKE '%' + @NextCall + '%'
						)
					OR (
						@op11 = @DoesNotContain
						AND NextCall NOT LIKE '%' + @NextCall + '%'
						)
					OR (
						@op11 = @StartsWith
						AND NextCall LIKE '' + @NextCall + '%'
						)
					OR (
						@op11 = @EndsWith
						AND NextCall LIKE '%' + @NextCall + ''
						)
					)
				AND (
					(@op12 IS NULL)
					OR (
						@op12 = @IsEqualTo
						AND ActionTaskPriority = @ActionTaskPriority
						)
					OR (
						@op12 = @IsNotEqualTo
						AND ActionTaskPriority <> @ActionTaskPriority
						)
					OR (
						@op12 = @IsLessThan
						AND ActionTaskPriority < @ActionTaskPriority
						)
					OR (
						@op12 = @IsLessThanOrEqualTo
						AND ActionTaskPriority <= @ActionTaskPriority
						)
					OR (
						@op12 = @IsGreaterThan
						AND ActionTaskPriority > @ActionTaskPriority
						)
					OR (
						@op12 = @IsGreaterThanOrEqualTo
						AND ActionTaskPriority >= @ActionTaskPriority
						)
					OR (
						@op12 = @Contains
						AND ActionTaskPriority LIKE '%' + @ActionTaskPriority + '%'
						)
					OR (
						@op12 = @DoesNotContain
						AND ActionTaskPriority NOT LIKE '%' + @ActionTaskPriority + '%'
						)
					OR (
						@op12 = @StartsWith
						AND ActionTaskPriority LIKE '' + @ActionTaskPriority + '%'
						)
					OR (
						@op12 = @EndsWith
						AND ActionTaskPriority LIKE '%' + @ActionTaskPriority + ''
						)
					)
				AND (
					(@op13 IS NULL)
					OR (
						@op13 IS NULL
						AND @LogicalOperator13 IS NULL
						)
					OR (
						@LogicalOperator13 = 'OR'
						AND (
							(
								(
									@op13 = @IsEqualTo
									AND CallBackDateTime = @CallBackDateTime
									)
								OR (
									@op13 = @IsNotEqualTo
									AND CallBackDateTime <> @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThan
									AND CallBackDateTime < @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThan
									AND CallBackDateTime > @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @CallBackDateTime
									)
								OR (
									@op13 = @Contains
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @StartsWith
									AND CallBackDateTime LIKE '' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + ''
									)
								)
							OR (
								(
									@Secondop13 = @IsEqualTo
									AND CallBackDateTime = @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsNotEqualTo
									AND CallBackDateTime <> @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThan
									AND CallBackDateTime < @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThan
									AND CallBackDateTime > @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @Contains
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @StartsWith
									AND CallBackDateTime LIKE '' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator13 = 'AND'
						AND (
							(
								(
									@op13 = @IsEqualTo
									AND CallBackDateTime = @CallBackDateTime
									)
								OR (
									@op13 = @IsNotEqualTo
									AND CallBackDateTime <> @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThan
									AND CallBackDateTime < @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThan
									AND CallBackDateTime > @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @CallBackDateTime
									)
								OR (
									@op13 = @Contains
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @StartsWith
									AND CallBackDateTime LIKE '' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + ''
									)
								)
							AND (
								(
									@Secondop13 = @IsEqualTo
									AND CallBackDateTime = @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsNotEqualTo
									AND CallBackDateTime <> @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThan
									AND CallBackDateTime < @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThan
									AND CallBackDateTime > @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @Contains
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @StartsWith
									AND CallBackDateTime LIKE '' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + ''
									)
								)
							)
						)
					OR (@Secondop13 IS NULL 
					    AND 
						(
							   (
								@op13 = @IsEqualTo
								AND CallBackDateTime = @CallBackDateTime
								)
							OR (
								@op13 = @IsNotEqualTo
								AND CallBackDateTime <> @CallBackDateTime
								)
							OR (
								@op13 = @IsLessThan
								AND CallBackDateTime < @CallBackDateTime
								)
							OR (
								@op13 = @IsLessThanOrEqualTo
								AND CallBackDateTime <= @CallBackDateTime
								)
							OR (
								@op13 = @IsGreaterThan
								AND CallBackDateTime > @CallBackDateTime
								)
							OR (
								@op13 = @IsGreaterThanOrEqualTo
								AND CallBackDateTime >= @CallBackDateTime
								)
							OR (
								@op13 = @Contains
								AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + '%'
								)
							OR (
								@op13 = @DoesNotContain
								AND CallBackDateTime NOT LIKE '%' + @CallBackDateTimeVarchar + '%'
								)
							OR (
								@op13 = @StartsWith
								AND CallBackDateTime LIKE '' + @CallBackDateTimeVarchar + '%'
								)
							OR (
								@op13 = @EndsWith
								AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + ''
								)
						)
					 )
					)
			OPTION (RECOMPILE)
		END;

		WITH alldata
		AS (
			SELECT 
				IIF(atType.[Type] = @DealtByCommunicationTeam, 1, 0) AS IsDealtByCommunicationTeam,
				IIF(atType.GUIDReference IN (@CheckNewSignupActionTaskTypeId, @CheckNewSignupCallRequiredActionTaskTypeId), 1, 0) AS IsCheckNewSignUpAction
				,at.CreationTimeStamp AS CreationTimeStamp
				,at.GUIDReference AS ActionTaskId
				,ISNULL(at.Candidate_Id, @EmptyGuid) AS Id
				,at.ActionComment AS ActionComment
				,at.StartDate
				,at.EndDate
				,atType.GUIDReference AS ActionTaskTypeId
				,atType.ActionCode AS ActionCode
				,dbo.GetTranslationValue(atType.TagTranslation_Id, @pCultureCode) AS ActionLabel
				,IIF(at.[State] = @pTodoState, @TodoStateLabel, @InProgressStateLabel) AS StatusLabel
				,i.IndividualId AS BusinessId
				,(SELECT TOP 1 CreationDate FROM CalendarEvent WHERE Candidate_Id=i.GUIDReference ORDER BY 1 DESC) AS LastCallDate
				,at.[State] AS ActionState
				,u.UserName AS Assignee
				,p.Name AS Panel
				,IIF(i.GUIDReference IS NOT NULL, dbo.GetTranslationValue(efreq.Translation_Id, @pCultureCode), '') AS NextCall
				,at.Country_Id AS Country_Id
				,dbo.GetTranslationValue(ap.Translation_Id, @pCultureCode) as ActionTaskPriority
				,at.CallBackDateTime
			FROM ActionTask at
			INNER JOIN ActionTaskType atType ON at.ActionTaskType_Id = atType.[GUIDReference]
				AND at.Country_Id = @pCountryId
				AND at.[State] IN (
					@pTodoState
					,@pActionInProgessState
					)
			LEFT JOIN Individual i ON i.GUIDReference = at.Candidate_Id
			LEFT JOIN IdentityUser u ON u.Id = at.Assignee_Id
			LEFT JOIN Panel p ON p.GUIDReference = at.Panel_Id
			LEFT JOIN CalendarEvent ce ON ce.Id = i.Event_Id
			LEFT JOIN EventFrequency efreq ON efreq.GUIDReference = ce.Frequency_Id
			LEFT JOIN ActionTaskPriorities ap ON ap.Id = at.ActionTaskPriority AND ap.CountryId=at.Country_Id
			WHERE
				NOT EXISTS (SELECT 1 FROM CommunicationEvent WHERE Candidate_Id = at.Candidate_Id AND [State] = @pCommInProgressState AND GPSUser LIKE @pGPSUser)
				AND atType.IsDealtByCommunicationTeam = 1 AND atType.[Type] = 'DealtByCommunicationTeam'			
				AND ISNULL(i.GUIDReference,@EmptyGuid) NOT IN (
					SELECT e.Parent_Id
					FROM Exclusion e
					INNER JOIN ExclusionType et ON (
							CAST(e.[Range_From] AS DATE)<= @Getdate
							AND CAST(e.[Range_To] AS DATE)>= @Getdate
							)
						AND et.GUIDReference = e.[Type_Id]
						AND et.AllowedContact <> 1
						AND Country_Id = @pCountryId
					)
			)
		SELECT alldata.IsDealtByCommunicationTeam
			,alldata.IsCheckNewSignUpAction
			,CreationTimeStamp
			,alldata.ActionTaskId
			,alldata.Id
			,alldata.ActionComment
			,alldata.StartDate
			,alldata.EndDate
			,alldata.ActionTaskTypeId
			,alldata.ActionCode
			,alldata.ActionLabel
			,alldata.StatusLabel
			,alldata.BusinessId
			,alldata.LastCallDate
			,alldata.ActionState
			,alldata.Assignee
			,alldata.Panel
			--,alldata.CalendarEvent
			,alldata.NextCall
			,alldata.ActionTaskPriority
			,alldata.CallBackDateTime
		FROM alldata
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND BusinessId = @BusinessId
					)
				OR (
					@op1 = @IsNotEqualTo
					AND BusinessId <> @BusinessId
					)
				OR (
					@op1 = @IsLessThan
					AND BusinessId < @BusinessId
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND BusinessId <= @BusinessId
					)
				OR (
					@op1 = @IsGreaterThan
					AND BusinessId > @BusinessId
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND BusinessId >= @BusinessId
					)
				OR (
					@op1 = @Contains
					AND BusinessId LIKE '%' + @BusinessId + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND BusinessId NOT LIKE '%' + @BusinessId + '%'
					)
				OR (
					@op1 = @StartsWith
					AND BusinessId LIKE '' + @BusinessId + '%'
					)
				OR (
					@op1 = @EndsWith
					AND BusinessId LIKE '%' + @BusinessId + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND ActionCode = @ActionCode
					)
				OR (
					@op2 = @IsNotEqualTo
					AND ActionCode <> @ActionCode
					)
				OR (
					@op2 = @IsLessThan
					AND ActionCode < @ActionCode
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND ActionCode <= @ActionCode
					)
				OR (
					@op2 = @IsGreaterThan
					AND ActionCode > @ActionCode
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND ActionCode >= @ActionCode
					)
				OR (
					@op2 = @Contains
					AND ActionCode LIKE '%' + @ActionCodeVarchar + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND ActionCode NOT LIKE '%' + @ActionCodeVarchar + '%'
					)
				OR (
					@op2 = @StartsWith
					AND ActionCode LIKE '' + @ActionCodeVarchar + '%'
					)
				OR (
					@op2 = @EndsWith
					AND ActionCode LIKE '%' + @ActionCodeVarchar + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND ActionLabel = @ActionLabel
					)
				OR (
					@op3 = @IsNotEqualTo
					AND ActionLabel <> @ActionLabel
					)
				OR (
					@op3 = @IsLessThan
					AND ActionLabel < @ActionLabel
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND ActionLabel <= @ActionLabel
					)
				OR (
					@op3 = @IsGreaterThan
					AND ActionLabel > @ActionLabel
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND ActionLabel >= @ActionLabel
					)
				OR (
					@op3 = @Contains
					AND ActionLabel LIKE '%' + @ActionLabel + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND ActionLabel NOT LIKE '%' + @ActionLabel + '%'
					)
				OR (
					@op3 = @StartsWith
					AND ActionLabel LIKE '' + @ActionLabel + '%'
					)
				OR (
					@op3 = @EndsWith
					AND ActionLabel LIKE '%' + @ActionLabel + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND Assignee = @Assigned
					)
				OR (
					@op4 = @IsNotEqualTo
					AND Assignee <> @Assigned
					)
				OR (
					@op4 = @IsLessThan
					AND Assignee < @Assigned
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND Assignee <= @Assigned
					)
				OR (
					@op4 = @IsGreaterThan
					AND Assignee > @Assigned
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND Assignee >= @Assigned
					)
				OR (
					@op4 = @Contains
					AND Assignee LIKE '%' + @Assigned + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND Assignee NOT LIKE '%' + @Assigned + '%'
					)
				OR (
					@op4 = @StartsWith
					AND Assignee LIKE '' + @Assigned + '%'
					)
				OR (
					@op4 = @EndsWith
					AND Assignee LIKE '%' + @Assigned + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND Panel = @Panel
					)
				OR (
					@op5 = @IsNotEqualTo
					AND Panel <> @Panel
					)
				OR (
					@op5 = @IsLessThan
					AND Panel < @Panel
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND Panel <= @Panel
					)
				OR (
					@op5 = @IsGreaterThan
					AND Panel > @Panel
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND Panel >= @Panel
					)
				OR (
					@op5 = @Contains
					AND Panel LIKE '%' + @Panel + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND Panel NOT LIKE '%' + @Panel + '%'
					)
				OR (
					@op5 = @StartsWith
					AND Panel LIKE '' + @Panel + '%'
					)
				OR (
					@op5 = @EndsWith
					AND Panel LIKE '%' + @Panel + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND ActionComment = @ActionComment
					)
				OR (
					@op6 = @IsNotEqualTo
					AND ActionComment <> @ActionComment
					)
				OR (
					@op6 = @IsLessThan
					AND ActionComment < @ActionComment
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND ActionComment <= @ActionComment
					)
				OR (
					@op6 = @IsGreaterThan
					AND ActionComment > @ActionComment
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND ActionComment >= @ActionComment
					)
				OR (
					@op6 = @Contains
					AND ActionComment LIKE '%' + @ActionComment + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND ActionComment NOT LIKE '%' + @ActionComment + '%'
					)
				OR (
					@op6 = @StartsWith
					AND ActionComment LIKE '' + @ActionComment + '%'
					)
				OR (
					@op6 = @EndsWith
					AND ActionComment LIKE '%' + @ActionComment + ''
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
								AND StartDate = @StartDate
								)
							OR (
								@op7 = @IsNotEqualTo
								AND StartDate <> @StartDate
								)
							OR (
								@op7 = @IsLessThan
								AND StartDate < @StartDate
								)
							OR (
								@op7 = @IsLessThanOrEqualTo
								AND StartDate <= @StartDate
								)
							OR (
								@op7 = @IsGreaterThan
								AND StartDate > @StartDate
								)
							OR (
								@op7 = @IsGreaterThanOrEqualTo
								AND StartDate >= @StartDate
								)
							OR (
								@op7 = @Contains
								AND StartDate LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @StartsWith
								AND StartDate LIKE '' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @EndsWith
								AND StartDate LIKE '%' + @StartDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop7 = @IsEqualTo
								AND StartDate = @SecondStartDate
								)
							OR (
								@Secondop7 = @IsNotEqualTo
								AND StartDate <> @SecondStartDate
								)
							OR (
								@Secondop7 = @IsLessThan
								AND StartDate < @SecondStartDate
								)
							OR (
								@Secondop7 = @IsLessThanOrEqualTo
								AND StartDate <= @SecondStartDate
								)
							OR (
								@Secondop7 = @IsGreaterThan
								AND StartDate > @SecondStartDate
								)
							OR (
								@Secondop7 = @IsGreaterThanOrEqualTo
								AND StartDate >= @SecondStartDate
								)
							OR (
								@Secondop7 = @Contains
								AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop7 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop7 = @StartsWith
								AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop7 = @EndsWith
								AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
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
								AND StartDate = @StartDate
								)
							OR (
								@op7 = @IsNotEqualTo
								AND StartDate <> @StartDate
								)
							OR (
								@op7 = @IsLessThan
								AND StartDate < @StartDate
								)
							OR (
								@op7 = @IsLessThanOrEqualTo
								AND StartDate <= @StartDate
								)
							OR (
								@op7 = @IsGreaterThan
								AND StartDate > @StartDate
								)
							OR (
								@op7 = @IsGreaterThanOrEqualTo
								AND StartDate >= @StartDate
								)
							OR (
								@op7 = @Contains
								AND StartDate LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @StartsWith
								AND StartDate LIKE '' + @StartDateVarchar + '%'
								)
							OR (
								@op7 = @EndsWith
								AND StartDate LIKE '%' + @StartDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop7 = @IsEqualTo
								AND StartDate = @SecondStartDate
								)
							OR (
								@Secondop7 = @IsNotEqualTo
								AND StartDate <> @SecondStartDate
								)
							OR (
								@Secondop7 = @IsLessThan
								AND StartDate < @SecondStartDate
								)
							OR (
								@Secondop7 = @IsLessThanOrEqualTo
								AND StartDate <= @SecondStartDate
								)
							OR (
								@Secondop7 = @IsGreaterThan
								AND StartDate > @SecondStartDate
								)
							OR (
								@Secondop7 = @IsGreaterThanOrEqualTo
								AND StartDate >= @SecondStartDate
								)
							OR (
								@Secondop7 = @Contains
								AND StartDate LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop7 = @DoesNotContain
								AND StartDate NOT LIKE '%' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop7 = @StartsWith
								AND StartDate LIKE '' + @SecondStartDateVarchar + '%'
								)
							OR (
								@Secondop7 = @EndsWith
								AND StartDate LIKE '%' + @SecondStartDateVarchar + ''
								)
							)
						)
					)
				OR (@Secondop7 IS NULL
						AND 
						(
						   (
							@op7 = @IsEqualTo
							AND StartDate = @StartDate
							)
						OR (
							@op7 = @IsNotEqualTo
							AND StartDate <> @StartDate
							)
						OR (
							@op7 = @IsLessThan
							AND StartDate < @StartDate
							)
						OR (
							@op7 = @IsLessThanOrEqualTo
							AND StartDate <= @StartDate
							)
						OR (
							@op7 = @IsGreaterThan
							AND StartDate > @StartDate
							)
						OR (
							@op7 = @IsGreaterThanOrEqualTo
							AND StartDate >= @StartDate
							)
						OR (
							@op7 = @Contains
							AND StartDate LIKE '%' + @StartDateVarchar + '%'
							)
						OR (
							@op7 = @DoesNotContain
							AND StartDate NOT LIKE '%' + @StartDateVarchar + '%'
							)
						OR (
							@op7 = @StartsWith
							AND StartDate LIKE '' + @StartDateVarchar + '%'
							)
						OR (
							@op7 = @EndsWith
							AND StartDate LIKE '%' + @StartDateVarchar + ''
							)
						)
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
								AND EndDate = @EndDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND EndDate <> @EndDate
								)
							OR (
								@op8 = @IsLessThan
								AND EndDate < @EndDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND EndDate <= @EndDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND EndDate > @EndDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND EndDate >= @EndDate
								)
							OR (
								@op8 = @Contains
								AND EndDate LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND EndDate LIKE '' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND EndDate LIKE '%' + @EndDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop8 = @IsEqualTo
								AND EndDate = @SecondEndDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND EndDate <> @SecondEndDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND EndDate < @SecondEndDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND EndDate <= @SecondEndDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND EndDate > @SecondEndDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND EndDate >= @SecondEndDate
								)
							OR (
								@Secondop8 = @Contains
								AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
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
								AND EndDate = @EndDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND EndDate <> @EndDate
								)
							OR (
								@op8 = @IsLessThan
								AND EndDate < @EndDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND EndDate <= @EndDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND EndDate > @EndDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND EndDate >= @EndDate
								)
							OR (
								@op8 = @Contains
								AND EndDate LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND EndDate LIKE '' + @EndDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND EndDate LIKE '%' + @EndDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop8 = @IsEqualTo
								AND EndDate = @SecondEndDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND EndDate <> @SecondEndDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND EndDate < @SecondEndDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND EndDate <= @SecondEndDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND EndDate > @SecondEndDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND EndDate >= @SecondEndDate
								)
							OR (
								@Secondop8 = @Contains
								AND EndDate LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND EndDate NOT LIKE '%' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND EndDate LIKE '' + @SecondEndDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND EndDate LIKE '%' + @SecondEndDateVarchar + ''
								)
							)
						)
					)
				OR (@Secondop8 IS NULL 
					AND
					(
					   (
						@op8 = @IsEqualTo
						AND EndDate = @EndDate
						)
					OR (
						@op8 = @IsNotEqualTo
						AND EndDate <> @EndDate
						)
					OR (
						@op8 = @IsLessThan
						AND EndDate < @EndDate
						)
					OR (
						@op8 = @IsLessThanOrEqualTo
						AND EndDate <= @EndDate
						)
					OR (
						@op8 = @IsGreaterThan
						AND EndDate > @EndDate
						)
					OR (
						@op8 = @IsGreaterThanOrEqualTo
						AND EndDate >= @EndDate
						)
					OR (
						@op8 = @Contains
						AND EndDate LIKE '%' + @EndDateVarchar + '%'
						)
					OR (
						@op8 = @DoesNotContain
						AND EndDate NOT LIKE '%' + @EndDateVarchar + '%'
						)
					OR (
						@op8 = @StartsWith
						AND EndDate LIKE '' + @EndDateVarchar + '%'
						)
					OR (
						@op8 = @EndsWith
						AND EndDate LIKE '%' + @EndDateVarchar + ''
						)
					)
				 )
				)
			AND (
				(@op9 IS NULL)
				OR (
					@op9 = @IsEqualTo
					AND StatusLabel = @StatusLabel
					)
				OR (
					@op9 = @IsNotEqualTo
					AND StatusLabel <> @StatusLabel
					)
				OR (
					@op9 = @IsLessThan
					AND StatusLabel < @StatusLabel
					)
				OR (
					@op9 = @IsLessThanOrEqualTo
					AND StatusLabel <= @StatusLabel
					)
				OR (
					@op9 = @IsGreaterThan
					AND StatusLabel > @StatusLabel
					)
				OR (
					@op9 = @IsGreaterThanOrEqualTo
					AND ActionComment >= @StatusLabel
					)
				OR (
					@op9 = @Contains
					AND StatusLabel LIKE '%' + @StatusLabel + '%'
					)
				OR (
					@op9 = @DoesNotContain
					AND StatusLabel NOT LIKE '%' + @StatusLabel + '%'
					)
				OR (
					@op9 = @StartsWith
					AND StatusLabel LIKE '' + @StatusLabel + '%'
					)
				OR (
					@op9 = @EndsWith
					AND StatusLabel LIKE '%' + @StatusLabel + ''
					)
				)
			AND (
				(@op10 IS NULL)
				OR (
					@op10 IS NULL
					AND @LogicalOperator8 IS NULL
					)
				OR (
					@LogicalOperator10 = 'OR'
					AND (
						(
							(
								@op10 = @IsEqualTo
								AND LastCallDate = @LastCallDate
								)
							OR (
								@op10 = @IsNotEqualTo
								AND LastCallDate <> @LastCallDate
								)
							OR (
								@op10 = @IsLessThan
								AND LastCallDate < @LastCallDate
								)
							OR (
								@op10 = @IsLessThanOrEqualTo
								AND LastCallDate <= @LastCallDate
								)
							OR (
								@op10 = @IsGreaterThan
								AND LastCallDate > @LastCallDate
								)
							OR (
								@op10 = @IsGreaterThanOrEqualTo
								AND LastCallDate >= @LastCallDate
								)
							OR (
								@op10 = @Contains
								AND LastCallDate LIKE '%' + @LastCallDateVarchar + '%'
								)
							OR (
								@op10 = @DoesNotContain
								AND LastCallDate NOT LIKE '%' + @LastCallDateVarchar + '%'
								)
							OR (
								@op10 = @StartsWith
								AND LastCallDate LIKE '' + @LastCallDateVarchar + '%'
								)
							OR (
								@op10 = @EndsWith
								AND LastCallDate LIKE '%' + @LastCallDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop10 = @IsEqualTo
								AND LastCallDate = @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsNotEqualTo
								AND LastCallDate <> @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsLessThan
								AND LastCallDate < @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsLessThanOrEqualTo
								AND LastCallDate <= @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsGreaterThan
								AND LastCallDate > @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsGreaterThanOrEqualTo
								AND LastCallDate >= @SecondLastCallDate
								)
							OR (
								@Secondop10 = @Contains
								AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + '%'
								)
							OR (
								@Secondop10 = @DoesNotContain
								AND LastCallDate NOT LIKE '%' + @SecondLastCallDateVarchar + '%'
								)
							OR (
								@Secondop10 = @StartsWith
								AND LastCallDate LIKE '' + @SecondLastCallDateVarchar + '%'
								)
							OR (
								@Secondop10 = @EndsWith
								AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator10 = 'AND'
					AND (
						(
							(
								@op10 = @IsEqualTo
								AND LastCallDate = @LastCallDate
								)
							OR (
								@op10 = @IsNotEqualTo
								AND LastCallDate <> @LastCallDate
								)
							OR (
								@op10 = @IsLessThan
								AND LastCallDate < @LastCallDate
								)
							OR (
								@op10 = @IsLessThanOrEqualTo
								AND LastCallDate <= @LastCallDate
								)
							OR (
								@op10 = @IsGreaterThan
								AND LastCallDate > @LastCallDate
								)
							OR (
								@op10 = @IsGreaterThanOrEqualTo
								AND LastCallDate >= @LastCallDate
								)
							OR (
								@op10 = @Contains
								AND LastCallDate LIKE '%' + @LastCallDateVarchar + '%'
								)
							OR (
								@op10 = @DoesNotContain
								AND LastCallDate NOT LIKE '%' + @LastCallDateVarchar + '%'
								)
							OR (
								@op10 = @StartsWith
								AND LastCallDate LIKE '' + @LastCallDateVarchar + '%'
								)
							OR (
								@op10 = @EndsWith
								AND LastCallDate LIKE '%' + @LastCallDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop10 = @IsEqualTo
								AND LastCallDate = @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsNotEqualTo
								AND LastCallDate <> @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsLessThan
								AND LastCallDate < @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsLessThanOrEqualTo
								AND LastCallDate <= @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsGreaterThan
								AND LastCallDate > @SecondLastCallDate
								)
							OR (
								@Secondop10 = @IsGreaterThanOrEqualTo
								AND LastCallDate >= @SecondLastCallDate
								)
							OR (
								@Secondop10 = @Contains
								AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + '%'
								)
							OR (
								@Secondop10 = @DoesNotContain
								AND LastCallDate NOT LIKE '%' + @SecondLastCallDateVarchar + '%'
								)
							OR (
								@Secondop10 = @StartsWith
								AND LastCallDate LIKE '' + @SecondLastCallDateVarchar + '%'
								)
							OR (
								@Secondop10 = @EndsWith
								AND LastCallDate LIKE '%' + @SecondLastCallDateVarchar + ''
								)
							)
						)
					)
				OR (@Secondop10 IS NULL 
						AND
						(
						   (
							@op10 = @IsEqualTo
							AND LastCallDate = @LastCallDate
							)
						OR (
							@op10 = @IsNotEqualTo
							AND LastCallDate <> @LastCallDate
							)
						OR (
							@op10 = @IsLessThan
							AND LastCallDate < @LastCallDate
							)
						OR (
							@op10 = @IsLessThanOrEqualTo
							AND LastCallDate <= @LastCallDate
							)
						OR (
							@op10 = @IsGreaterThan
							AND LastCallDate > @LastCallDate
							)
						OR (
							@op10 = @IsGreaterThanOrEqualTo
							AND LastCallDate >= @LastCallDate
							)
						OR (
							@op10 = @Contains
							AND LastCallDate LIKE '%' + @LastCallDateVarchar + '%'
							)
						OR (
							@op10 = @DoesNotContain
							AND LastCallDate NOT LIKE '%' + @LastCallDateVarchar + '%'
							)
						OR (
							@op10 = @StartsWith
							AND LastCallDate LIKE '' + @LastCallDateVarchar + '%'
							)
						OR (
							@op10 = @EndsWith
							AND LastCallDate LIKE '%' + @LastCallDateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op11 IS NULL)
				OR (
					@op11 = @IsEqualTo
					AND NextCall = @NextCall
					)
				OR (
					@op11 = @IsNotEqualTo
					AND NextCall <> @NextCall
					)
				OR (
					@op11 = @IsLessThan
					AND NextCall < @NextCall
					)
				OR (
					@op11 = @IsLessThanOrEqualTo
					AND NextCall <= @NextCall
					)
				OR (
					@op11 = @IsGreaterThan
					AND NextCall > @NextCall
					)
				OR (
					@op11 = @IsGreaterThanOrEqualTo
					AND NextCall >= @NextCall
					)
				OR (
					@op11 = @Contains
					AND NextCall LIKE '%' + @NextCall + '%'
					)
				OR (
					@op11 = @DoesNotContain
					AND NextCall NOT LIKE '%' + @NextCall + '%'
					)
				OR (
					@op11 = @StartsWith
					AND NextCall LIKE '' + @NextCall + '%'
					)
				OR (
					@op11 = @EndsWith
					AND NextCall LIKE '%' + @NextCall + ''
					)
				)
			AND (
					(@op12 IS NULL)
					OR (
						@op12 = @IsEqualTo
						AND ActionTaskPriority = @ActionTaskPriority
						)
					OR (
						@op12 = @IsNotEqualTo
						AND ActionTaskPriority <> @ActionTaskPriority
						)
					OR (
						@op12 = @IsLessThan
						AND ActionTaskPriority < @ActionTaskPriority
						)
					OR (
						@op12 = @IsLessThanOrEqualTo
						AND ActionTaskPriority <= @ActionTaskPriority
						)
					OR (
						@op12 = @IsGreaterThan
						AND ActionTaskPriority > @ActionTaskPriority
						)
					OR (
						@op12 = @IsGreaterThanOrEqualTo
						AND ActionTaskPriority >= @ActionTaskPriority
						)
					OR (
						@op12 = @Contains
						AND ActionTaskPriority LIKE '%' + @ActionTaskPriority + '%'
						)
					OR (
						@op12 = @DoesNotContain
						AND ActionTaskPriority NOT LIKE '%' + @ActionTaskPriority + '%'
						)
					OR (
						@op12 = @StartsWith
						AND ActionTaskPriority LIKE '' + @ActionTaskPriority + '%'
						)
					OR (
						@op12 = @EndsWith
						AND ActionTaskPriority LIKE '%' + @ActionTaskPriority + ''
						)
					)
				AND (
					(@op13 IS NULL)
					OR (
						@op13 IS NULL
						AND @LogicalOperator13 IS NULL
						)
					OR (
						@LogicalOperator13 = 'OR'
						AND (
							(
								(
									@op13 = @IsEqualTo
									AND CallBackDateTime = @CallBackDateTime
									)
								OR (
									@op13 = @IsNotEqualTo
									AND CallBackDateTime <> @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThan
									AND CallBackDateTime < @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThan
									AND CallBackDateTime > @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @CallBackDateTime
									)
								OR (
									@op13 = @Contains
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @StartsWith
									AND CallBackDateTime LIKE '' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + ''
									)
								)
							OR (
								(
									@Secondop13 = @IsEqualTo
									AND CallBackDateTime = @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsNotEqualTo
									AND CallBackDateTime <> @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThan
									AND CallBackDateTime < @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThan
									AND CallBackDateTime > @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @Contains
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @StartsWith
									AND CallBackDateTime LIKE '' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator13 = 'AND'
						AND (
							(
								(
									@op13 = @IsEqualTo
									AND CallBackDateTime = @CallBackDateTime
									)
								OR (
									@op13 = @IsNotEqualTo
									AND CallBackDateTime <> @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThan
									AND CallBackDateTime < @CallBackDateTime
									)
								OR (
									@op13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThan
									AND CallBackDateTime > @CallBackDateTime
									)
								OR (
									@op13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @CallBackDateTime
									)
								OR (
									@op13 = @Contains
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @StartsWith
									AND CallBackDateTime LIKE '' + @CallBackDateTimeVarchar + '%'
									)
								OR (
									@op13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + ''
									)
								)
							AND (
								(
									@Secondop13 = @IsEqualTo
									AND CallBackDateTime = @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsNotEqualTo
									AND CallBackDateTime <> @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThan
									AND CallBackDateTime < @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsLessThanOrEqualTo
									AND CallBackDateTime <= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThan
									AND CallBackDateTime > @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @IsGreaterThanOrEqualTo
									AND CallBackDateTime >= @SecondCallBackDateTimeVarchar
									)
								OR (
									@Secondop13 = @Contains
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @DoesNotContain
									AND CallBackDateTime NOT LIKE '%' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @StartsWith
									AND CallBackDateTime LIKE '' + @SecondCallBackDateTimeVarchar + '%'
									)
								OR (
									@Secondop13 = @EndsWith
									AND CallBackDateTime LIKE '%' + @SecondCallBackDateTimeVarchar + ''
									)
								)
							)
						)
					OR (@Secondop13 IS NULL 
					    AND 
						(
							   (
								@op13 = @IsEqualTo
								AND CallBackDateTime = @CallBackDateTime
								)
							OR (
								@op13 = @IsNotEqualTo
								AND CallBackDateTime <> @CallBackDateTime
								)
							OR (
								@op13 = @IsLessThan
								AND CallBackDateTime < @CallBackDateTime
								)
							OR (
								@op13 = @IsLessThanOrEqualTo
								AND CallBackDateTime <= @CallBackDateTime
								)
							OR (
								@op13 = @IsGreaterThan
								AND CallBackDateTime > @CallBackDateTime
								)
							OR (
								@op13 = @IsGreaterThanOrEqualTo
								AND CallBackDateTime >= @CallBackDateTime
								)
							OR (
								@op13 = @Contains
								AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + '%'
								)
							OR (
								@op13 = @DoesNotContain
								AND CallBackDateTime NOT LIKE '%' + @CallBackDateTimeVarchar + '%'
								)
							OR (
								@op13 = @StartsWith
								AND CallBackDateTime LIKE '' + @CallBackDateTimeVarchar + '%'
								)
							OR (
								@op13 = @EndsWith
								AND CallBackDateTime LIKE '%' + @CallBackDateTimeVarchar + ''
								)
						)
					 )
					)
		ORDER BY CASE 
				WHEN @pOrderBy = 'BusinessId'
					AND @pOrderType = 'desc'
					THEN BusinessId
				END DESC
			,CASE 
				WHEN @pOrderBy = 'BusinessId'
					AND @pOrderType = 'asc'
					THEN BusinessId
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionCode'
					AND @pOrderType = 'desc'
					THEN ActionCode
				END DESC
			,CASE 
				WHEN @pOrderBy = 'ActionCode'
					AND @pOrderType = 'asc'
					THEN ActionCode
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionLabel'
					AND @pOrderType = 'desc'
					THEN ActionLabel
				END DESC
			,CASE 
				WHEN @pOrderBy = 'ActionLabel'
					AND @pOrderType = 'asc'
					THEN ActionLabel
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Assignee'
					AND @pOrderType = 'desc'
					THEN Assignee
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Assignee'
					AND @pOrderType = 'asc'
					THEN Assignee
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Panel'
					AND @pOrderType = 'desc'
					THEN Panel
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Panel'
					AND @pOrderType = 'asc'
					THEN Panel
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionComment'
					AND @pOrderType = 'desc'
					THEN ActionComment
				END DESC
			,CASE 
				WHEN @pOrderBy = 'ActionComment'
					AND @pOrderType = 'asc'
					THEN ActionComment
				END ASC
			,CASE 
				WHEN @pOrderBy = 'StartDate'
					AND @pOrderType = 'desc'
					THEN StartDate
				END DESC
			,CASE 
				WHEN @pOrderBy = 'StartDate'
					AND @pOrderType = 'asc'
					THEN StartDate
				END ASC
			,CASE 
				WHEN @pOrderBy = 'EndDate'
					AND @pOrderType = 'desc'
					THEN EndDate
				END DESC
			,CASE 
				WHEN @pOrderBy = 'EndDate'
					AND @pOrderType = 'asc'
					THEN EndDate
				END ASC
			,CASE 
				WHEN @pOrderBy = 'StatusLabel'
					AND @pOrderType = 'desc'
					THEN StatusLabel
				END DESC
			,CASE 
				WHEN @pOrderBy = 'StatusLabel'
					AND @pOrderType = 'asc'
					THEN StatusLabel
				END ASC
			,CASE 
				WHEN @pOrderBy = 'LastCallDate'
					AND @pOrderType = 'desc'
					THEN LastCallDate
				END DESC
			,CASE 
				WHEN @pOrderBy = 'LastCallDate'
					AND @pOrderType = 'asc'
					THEN LastCallDate
				END ASC
			,CASE 
				WHEN @pOrderBy = 'NextCall'
					AND @pOrderType = 'desc'
					THEN NextCall
				END DESC
			,CASE 
				WHEN @pOrderBy = 'NextCall'
					AND @pOrderType = 'asc'
					THEN NextCall
				END ASC
			,CASE 
				WHEN @pOrderBy = 'ActionTaskPriority'
					AND @pOrderType = 'desc'
					THEN ActionTaskPriority
				END DESC
			,CASE 
				WHEN @pOrderBy = 'ActionTaskPriority'
					AND @pOrderType = 'asc'
					THEN ActionTaskPriority
				END ASC
			,CASE 
				WHEN @pOrderBy = 'CreationTimeStamp'
					AND @pOrderType = 'desc'
					THEN CreationTimeStamp
				END DESC
			,CASE 
				WHEN @pOrderBy = 'CreationTimeStamp'
					AND @pOrderType = 'asc'
					THEN CreationTimeStamp
				END ASC 
			,CASE 
				WHEN @pOrderBy= 'CallBackDateTime'
					AND @pOrderType = 'desc'
					THEN CallBackDateTime
				END DESC
			,CASE 
				WHEN @pOrderBy= 'CallBackDateTime'
					AND @pOrderType = 'asc'
					THEN CallBackDateTime
				END ASC OFFSET @OFFSETRows ROWS

		FETCH NEXT @pPageSize ROWS ONLY
		OPTION (RECOMPILE);
	END TRY

	BEGIN CATCH
		DECLARE @ERR_MSG AS NVARCHAR(4000)
			,@ERR_STA AS SMALLINT

		SET @ERR_MSG = ERROR_MESSAGE();
		SET @ERR_STA = ERROR_STATE();

		THROW 50001
			,@ERR_MSG
			,@ERR_STA;
	END CATCH	
END