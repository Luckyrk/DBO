/*##########################################################################
-- Name				: GetDeviceDetailsByAssetItemId
-- Date             : 2015-Oct-01
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
       @pAssetItemId UNIQUEIDENTIFIER -- StockItem Id
       @pCultureCode int  - Culture Code of type int
	   @pOrderBy VARCHAR(100)
	   @pOrderType VARCHAR(10)
	   @pPageNumber INT = 1
	   @pPageSize INT = 100
	   @pdays NVARCHAR(10)
	   @pIsExport BIT = 0
	   @pParametersTable dbo.GridParametersTable readonly
-- Sample Execution :
					declare @p8 dbo.GridParametersTable
					insert into @p8 values(N'Location',N'762781',N'IsNotEqualTo',NULL,NULL,NULL)
					--insert into @p8 values(N'CreationTimeStamp',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
					--insert into @p8 values(N'Points',N'100',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
					--insert into @p8 values(N'DiaryDateFull',N'2006.7.4',N'IsEqualTo',NULL,NULL,NULL)
					--insert into @p8 values(N'BusinessId',N'10257901-01',N'IsEqualTo',NULL,NULL,NULL)
					exec GetDeviceDetailsByAssetItemId '47cb7413-56f7-43bd-a909-1e299d91c273',2057,'TransitionDate','asc',1,100,0,@p8
##########################################################################
-- version  user						date        change 
-- 1.0  Jagadeesh Boddu				  2015-Oct-01  Initial
-- 1.2  Fiorillo Damian							   Swap Creation Dates to get the real datetime
##########################################################################*/
CREATE PROCEDURE [dbo].[GetDeviceDetailsByAssetItemId] (
	@pAssetItemId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10) -- ASC OR DESC
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly
	)
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
	DECLARE @LogicalOperator1 VARCHAR(5)
	DECLARE @Secondop1 VARCHAR(50)
	DECLARE @SecondTransitionDate DATETIME
	DECLARE @TransitionDate DATETIME
		,@TransitionTime NVARCHAR(1000)
		,@Location NVARCHAR(1000)
		,@PanelMember NVARCHAR(MAX)
		,@State NVARCHAR(MAX)
		,@Reason NVARCHAR(MAX)
		,@Comment NVARCHAR(MAX)
		,@ModifiedBy NVARCHAR(MAX)

	SELECT @op1 = Opertor
		,@TransitionDate = CONVERT(DATE, CAST(ParameterValue AS DATETIME))
		,@Secondop1 = SecondParameterOperator
		,@SecondTransitionDate = CAST(SecondParameterValue AS DATETIME)
		,@LogicalOperator1 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'TransitionDate'

	SELECT @op2 = Opertor
		,@TransitionTime = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'TimeInSeconds'

	SELECT @op3 = Opertor
		,@Location = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Location'

	SELECT @op4 = Opertor
		,@PanelMember = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'PanelMember'

	SELECT @op5 = Opertor
		,@State = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'State'

	SELECT @op6 = Opertor
		,@Reason = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Reason'

	SELECT @op7 = Opertor
		,@Comment = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Comment'

	SELECT @op8 = Opertor
		,@ModifiedBy = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'ModifiedBy'

	DECLARE @TransitionDateVARCHAR VARCHAR(100) = CAST(@TransitionDate AS VARCHAR)
		,@SecondTransitionDateVARCHAR VARCHAR(100) = CAST(@SecondTransitionDate AS VARCHAR)
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
	DECLARE @Country_Id AS UNIQUEIDENTIFIER
	DECLARE @MCRoleId AS UNIQUEIDENTIFIER

	SELECT @Country_Id = Country_Id
	FROM StockItem
	WHERE GUIDReference = @pAssetItemId

	SELECT @MCRoleId = DynamicRoleId
	FROM dbo.DynamicRole
	INNER JOIN Translation ON TranslationId = Translation_Id
	WHERE country_id = @Country_Id
		AND KeyName = 'MainContactRoleName'
	
	IF (@pOrderBy IS NULL)
	BEGIN
		SET @pOrderBy = 'TransitionDate'
	END

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'desc'

	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 15000;

	IF (@pIsExport = 0)
	BEGIN
		SELECT count(0)
		FROM (
			SELECT TransitionDate
				,TransitionTime
				,[State]
				,Reason
				,Comments
				,Location
				,CreationTimeStamp
				,ModifiedBy
				,IsIndividualEntity
				,IndividualBussinesId
				,PanelMember
				,TimeInSeconds
			FROM (
				SELECT isnull(sd.CreationDate , sd.CreationTimeStamp ) AS TransitionDate
					,DATEDIFF(SS, CONVERT(DATE, isnull(sd.CreationDate ,sd.CreationTimeStamp)), isnull(sd.CreationDate ,sd.CreationTimeStamp)) AS TimeInSeconds
					,RIGHT('0' + CAST(DATEDIFF(SS, CONVERT(DATE, isnull(sd.CreationDate ,sd.CreationTimeStamp)), isnull(sd.CreationDate ,sd.CreationTimeStamp)) / 3600 AS VARCHAR), 2) + ':' + RIGHT('0' + CAST((DATEDIFF(SS, CONVERT(DATE, isnull(sd.CreationDate ,sd.CreationTimeStamp)), isnull(sd.CreationDate ,sd.CreationTimeStamp)) / 60) % 60 AS VARCHAR), 2) AS TransitionTime
					,dbo.GetTranslationValue(sdd.Label_Id, @pCultureCode) AS [State]
					,CONCAT(rc.Code, ' - ', dbo.GetTranslationValue(rc.Description_Id, @pCultureCode)) AS Reason
					,sd.Comments
					,gsl.Location
					,sd.CreationTimeStamp
					,sd.GPSUser AS ModifiedBy
					,0 AS IsIndividualEntity
					,NULL AS IndividualBussinesId
					,'' AS PanelMember
				FROM StockItem si
				INNER JOIN StockStateDefinitionHistory sh ON sh.StockItem_Id = si.GUIDReference
				INNER JOIN StateDefinitionHistory sd ON sh.GUIDReference = sd.GUIDReference
				INNER JOIN StateDefinition sdd ON sdd.Id = sd.To_Id
				LEFT JOIN ReasonForChangeState rc ON rc.Id = sd.ReasonForchangeState_Id
				LEFT JOIN GenericStockLocation gsl ON gsl.GUIDReference = sh.Location_Id
				LEFT JOIN StockPanelistLocation spl ON spl.GUIDReference = sh.Location_Id
				LEFT JOIN Panelist p ON sh.Panelist_Id = p.GUIDReference OR spl.Panelist_Id = p.GUIDReference
				LEFT JOIN Individual i ON i.GUIDReference = p.PanelMember_Id
				LEFT JOIN Collective c ON c.GUIDReference = p.PanelMember_Id
				LEFT JOIN Individual gc ON c.GroupContact_Id = gc.GUIDReference
				LEFT JOIN DynamicRoleAssignment dra ON dra.Panelist_Id = p.GUIDReference
					AND dra.DynamicRole_Id = @MCRoleId
				LEFT JOIN individual di ON di.GUIDReference = dra.Candidate_Id
				WHERE si.GUIDReference = @pAssetItemId
				) ResultTable
			WHERE (
					(
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
										AND TransitionDate = @TransitionDate
										)
									OR (
										@op1 = @IsNotEqualTo
										AND CONVERT(DATE, TransitionDate) <> @TransitionDate
										)
									OR (
										@op1 = @IsLessThan
										AND CONVERT(DATE, TransitionDate) < @TransitionDate
										)
									OR (
										@op1 = @IsLessThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) <= @TransitionDate
										)
									OR (
										@op1 = @IsGreaterThan
										AND CONVERT(DATE, TransitionDate) > @TransitionDate
										)
									OR (
										@op1 = @IsGreaterThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) >= @TransitionDate
										)
									OR (
										@op1 = @Contains
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + '%'
										)
									OR (
										@op1 = @DoesNotContain
										AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @TransitionDateVARCHAR + '%'
										)
									OR (
										@op1 = @StartsWith
										AND CONVERT(DATE, TransitionDate) LIKE '' + @TransitionDateVARCHAR + '%'
										)
									OR (
										@op1 = @EndsWith
										AND TransitionDate LIKE '%' + @TransitionDateVARCHAR + ''
										)
									)
								OR (
									(
										@Secondop1 = @IsEqualTo
										AND CONVERT(DATE, TransitionDate) = @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsNotEqualTo
										AND CONVERT(DATE, TransitionDate) <> @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsLessThan
										AND CONVERT(DATE, TransitionDate) < @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsLessThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) <= @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsGreaterThan
										AND CONVERT(DATE, TransitionDate) > @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsGreaterThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) >= @SecondTransitionDate
										)
									OR (
										@Secondop1 = @Contains
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + '%'
										)
									OR (
										@Secondop1 = @DoesNotContain
										AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @SecondTransitionDateVARCHAR + '%'
										)
									OR (
										@Secondop1 = @StartsWith
										AND CONVERT(DATE, TransitionDate) LIKE '' + @SecondTransitionDateVARCHAR + '%'
										)
									OR (
										@Secondop1 = @EndsWith
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + ''
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
										AND CONVERT(DATE, TransitionDate) = @TransitionDate
										)
									OR (
										@op1 = @IsNotEqualTo
										AND CONVERT(DATE, TransitionDate) <> @TransitionDate
										)
									OR (
										@op1 = @IsLessThan
										AND CONVERT(DATE, TransitionDate) < @TransitionDate
										)
									OR (
										@op1 = @IsLessThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) <= @TransitionDate
										)
									OR (
										@op1 = @IsGreaterThan
										AND CONVERT(DATE, TransitionDate) > @TransitionDate
										)
									OR (
										@op1 = @IsGreaterThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) >= @TransitionDate
										)
									OR (
										@op1 = @Contains
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + '%'
										)
									OR (
										@op1 = @DoesNotContain
										AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @TransitionDateVARCHAR + '%'
										)
									OR (
										@op1 = @StartsWith
										AND CONVERT(DATE, TransitionDate) LIKE '' + @TransitionDateVARCHAR + '%'
										)
									OR (
										@op1 = @EndsWith
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + ''
										)
									)
								AND (
									(
										@Secondop1 = @IsEqualTo
										AND CONVERT(DATE, TransitionDate) = @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsNotEqualTo
										AND CONVERT(DATE, TransitionDate) <> @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsLessThan
										AND CONVERT(DATE, TransitionDate) < @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsLessThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) <= @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsGreaterThan
										AND CONVERT(DATE, TransitionDate) > @SecondTransitionDate
										)
									OR (
										@Secondop1 = @IsGreaterThanOrEqualTo
										AND CONVERT(DATE, TransitionDate) >= @SecondTransitionDate
										)
									OR (
										@Secondop1 = @Contains
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + '%'
										)
									OR (
										@Secondop1 = @DoesNotContain
										AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @SecondTransitionDateVARCHAR + '%'
										)
									OR (
										@Secondop1 = @StartsWith
										AND CONVERT(DATE, TransitionDate) LIKE '' + @SecondTransitionDateVARCHAR + '%'
										)
									OR (
										@Secondop1 = @EndsWith
										AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + ''
										)
									)
								)
							)
						OR (
							@op1 = @IsEqualTo
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) = @TransitionDate
							)
						OR (
							@op1 = @IsNotEqualTo
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) <> @TransitionDate
							)
						OR (
							@op1 = @IsLessThan
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) < @TransitionDate
							)
						OR (
							@op1 = @IsLessThanOrEqualTo
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) <= @TransitionDate
							)
						OR (
							@op1 = @IsGreaterThan
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) > @TransitionDate
							)
						OR (
							@op1 = @IsGreaterThanOrEqualTo
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) >= @TransitionDate
							)
						OR (
							@op1 = @Contains
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + '%'
							)
						OR (
							@op1 = @DoesNotContain
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @TransitionDateVARCHAR + '%'
							)
						OR (
							@op1 = @StartsWith
							AND @Secondop1 IS NULL
							AND CONVERT(DATE, TransitionDate) LIKE '' + @TransitionDateVARCHAR + '%'
							)
						OR (
							@op1 = @EndsWith
							AND @Secondop1 IS NULL
							AND TransitionDate LIKE '%' + @TransitionDateVARCHAR + ''
							)
						)
					AND (
						(@op2 IS NULL)
						OR (
							@op2 = @IsEqualTo
							AND TransitionTime = @TransitionTime
							)
						OR (
							@op2 = @IsNotEqualTo
							AND TransitionTime <> @TransitionTime
							)
						OR (
							@op2 = @IsLessThan
							AND TransitionTime < @TransitionTime
							)
						OR (
							@op2 = @IsLessThanOrEqualTo
							AND TransitionTime >= @TransitionTime
							)
						OR (
							@op2 = @IsGreaterThan
							AND TransitionTime > @TransitionTime
							)
						OR (
							@op2 = @IsGreaterThanOrEqualTo
							AND TransitionTime >= @TransitionTime
							)
						OR (
							@op2 = @Contains
							AND TransitionTime LIKE '%' + @TransitionTime + '%'
							)
						OR (
							@op2 = @DoesNotContain
							AND TransitionTime NOT LIKE '%' + @TransitionTime + '%'
							)
						OR (
							@op2 = @StartsWith
							AND TransitionTime LIKE '' + @TransitionTime + '%'
							)
						OR (
							@op2 = @EndsWith
							AND TransitionTime LIKE '%' + @TransitionTime + ''
							)
						)
					AND (
						(@op3 IS NULL)
						OR (
							@op3 = @IsEqualTo
							AND Location = @Location
							)
						OR (
							@op3 = @IsNotEqualTo
							AND Location <> @Location
							)
						OR (
							@op3 = @IsLessThan
							AND Location < @Location
							)
						OR (
							@op3 = @IsLessThanOrEqualTo
							AND Location >= @Location
							)
						OR (
							@op3 = @IsGreaterThan
							AND Location > @Location
							)
						OR (
							@op3 = @IsGreaterThanOrEqualTo
							AND Location >= @Location
							)
						OR (
							@op3 = @Contains
							AND Location LIKE '%' + @Location + '%'
							)
						OR (
							@op3 = @DoesNotContain
							AND Location NOT LIKE '%' + @Location + '%'
							)
						OR (
							@op3 = @StartsWith
							AND Location LIKE '' + @Location + '%'
							)
						OR (
							@op3 = @EndsWith
							AND Location LIKE '%' + @Location + ''
							)
						)
					AND (
						(@op4 IS NULL)
						OR (
							@op4 = @IsEqualTo
							AND PanelMember = @PanelMember
							)
						OR (
							@op4 = @IsNotEqualTo
							AND PanelMember <> @PanelMember
							)
						OR (
							@op4 = @IsLessThan
							AND PanelMember < @PanelMember
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND PanelMember >= @PanelMember
							)
						OR (
							@op4 = @IsGreaterThan
							AND PanelMember > @PanelMember
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND PanelMember >= @PanelMember
							)
						OR (
							@op4 = @Contains
							AND PanelMember LIKE '%' + @PanelMember + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND PanelMember NOT LIKE '%' + @PanelMember + '%'
							)
						OR (
							@op4 = @StartsWith
							AND PanelMember LIKE '' + @PanelMember + '%'
							)
						OR (
							@op4 = @EndsWith
							AND PanelMember LIKE '%' + @PanelMember + ''
							)
						)
					AND (
						(@op5 IS NULL)
						OR (
							@op5 = @IsEqualTo
							AND [State] = @State
							)
						OR (
							@op5 = @IsNotEqualTo
							AND [State] <> @State
							)
						OR (
							@op5 = @IsLessThan
							AND [State] < @State
							)
						OR (
							@op5 = @IsLessThanOrEqualTo
							AND [State] >= @State
							)
						OR (
							@op5 = @IsGreaterThan
							AND [State] > @State
							)
						OR (
							@op5 = @IsGreaterThanOrEqualTo
							AND [State] >= @State
							)
						OR (
							@op5 = @Contains
							AND [State] LIKE '%' + @State + '%'
							)
						OR (
							@op5 = @DoesNotContain
							AND [State] NOT LIKE '%' + @State + '%'
							)
						OR (
							@op5 = @StartsWith
							AND [State] LIKE '' + @State + '%'
							)
						OR (
							@op5 = @EndsWith
							AND [State] LIKE '%' + @State + ''
							)
						)
					AND (
						(@op6 IS NULL)
						OR (
							@op6 = @IsEqualTo
							AND Reason = @Reason
							)
						OR (
							@op6 = @IsNotEqualTo
							AND Reason <> @Reason
							)
						OR (
							@op6 = @IsLessThan
							AND Reason < @Reason
							)
						OR (
							@op6 = @IsLessThanOrEqualTo
							AND Reason >= @Reason
							)
						OR (
							@op6 = @IsGreaterThan
							AND Reason > @Reason
							)
						OR (
							@op6 = @IsGreaterThanOrEqualTo
							AND Reason >= @Reason
							)
						OR (
							@op6 = @Contains
							AND Reason LIKE '%' + @Reason + '%'
							)
						OR (
							@op6 = @DoesNotContain
							AND Reason NOT LIKE '%' + @Reason + '%'
							)
						OR (
							@op6 = @StartsWith
							AND Reason LIKE '' + @Reason + '%'
							)
						OR (
							@op6 = @EndsWith
							AND Reason LIKE '%' + @Reason + ''
							)
						)
					AND (
						(@op7 IS NULL)
						OR (
							@op7 = @IsEqualTo
							AND Comments = @Comment
							)
						OR (
							@op7 = @IsNotEqualTo
							AND Comments <> @Comment
							)
						OR (
							@op7 = @IsLessThan
							AND Comments < @Comment
							)
						OR (
							@op7 = @IsLessThanOrEqualTo
							AND Comments >= @Comment
							)
						OR (
							@op7 = @IsGreaterThan
							AND Comments > @Comment
							)
						OR (
							@op7 = @IsGreaterThanOrEqualTo
							AND Comments >= @Comment
							)
						OR (
							@op7 = @Contains
							AND Comments LIKE '%' + @Comment + '%'
							)
						OR (
							@op7 = @DoesNotContain
							AND Comments NOT LIKE '%' + @Comment + '%'
							)
						OR (
							@op7 = @StartsWith
							AND Comments LIKE '' + @Comment + '%'
							)
						OR (
							@op7 = @EndsWith
							AND Comments LIKE '%' + @Comment + ''
							)
						)
					AND (
						(@op8 IS NULL)
						OR (
							@op8 = @IsEqualTo
							AND ModifiedBy = @ModifiedBy
							)
						OR (
							@op8 = @IsNotEqualTo
							AND ModifiedBy <> @ModifiedBy
							)
						OR (
							@op8 = @IsLessThan
							AND ModifiedBy < @ModifiedBy
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND ModifiedBy >= @ModifiedBy
							)
						OR (
							@op8 = @IsGreaterThan
							AND ModifiedBy > @ModifiedBy
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND ModifiedBy >= @ModifiedBy
							)
						OR (
							@op8 = @Contains
							AND ModifiedBy LIKE '%' + @ModifiedBy + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND ModifiedBy NOT LIKE '%' + @ModifiedBy + '%'
							)
						OR (
							@op8 = @StartsWith
							AND ModifiedBy LIKE '' + @ModifiedBy + '%'
							)
						OR (
							@op8 = @EndsWith
							AND ModifiedBy LIKE '%' + @ModifiedBy + ''
							)
						)
					)
			) t
		OPTION (RECOMPILE);
	END

	SELECT TransitionDate
		,TransitionTime
		,[State]
		,Reason
		,Comments AS Comment
		,Location
		,CreationTimeStamp
		,ModifiedBy
		,IsIndividualEntity
		,IndividualBussinesId
		,PanelMember
		,TimeInSeconds
	FROM (
		SELECT isnull(sd.CreationDate ,sd.CreationTimeStamp) AS TransitionDate
			,DATEDIFF(SS, CONVERT(DATE, isnull(sd.CreationDate ,sd.CreationTimeStamp)), isnull(sd.CreationDate ,sd.CreationTimeStamp)) AS TimeInSeconds
			,RIGHT('0' + CAST(DATEDIFF(SS, CONVERT(DATE, isnull(sd.CreationDate ,sd.CreationTimeStamp)), isnull(sd.CreationDate ,sd.CreationTimeStamp)) / 3600 AS VARCHAR), 2) + ':' + RIGHT('0' + CAST((DATEDIFF(SS, CONVERT(DATE, isnull(sd.CreationDate ,sd.CreationTimeStamp)), isnull(sd.CreationDate ,sd.CreationTimeStamp)) / 60) % 60 AS VARCHAR), 2) AS TransitionTime
			,dbo.GetTranslationValue(sdd.Label_Id, @pCultureCode) AS [State]
			,CONCAT(rc.Code, ' - ', dbo.GetTranslationValue(rc.Description_Id, @pCultureCode)) AS Reason
			,sd.Comments
			,gsl.Location
			,sd.CreationTimeStamp
			,sd.GPSUser AS ModifiedBy
			,0 AS IsIndividualEntity
			,di.IndividualId AS IndividualBussinesId
			,ISNULL(i.IndividualId, ISNULL(gc.IndividualId, di.IndividualId)) AS PanelMember
		FROM StockItem si
		INNER JOIN StockStateDefinitionHistory sh ON sh.StockItem_Id = si.GUIDReference
		INNER JOIN StateDefinitionHistory sd ON sh.GUIDReference = sd.GUIDReference
		INNER JOIN StateDefinition sdd ON sdd.Id = sd.To_Id
		LEFT JOIN ReasonForChangeState rc ON rc.Id = sd.ReasonForchangeState_Id
		LEFT JOIN GenericStockLocation gsl ON gsl.GUIDReference = sh.Location_Id
		LEFT JOIN StockPanelistLocation spl ON spl.GUIDReference = sh.Location_Id
		LEFT JOIN Panelist p ON sh.Panelist_Id = p.GUIDReference OR spl.Panelist_Id = p.GUIDReference
		LEFT JOIN Individual i ON i.GUIDReference = p.PanelMember_Id
		LEFT JOIN Collective c ON c.GUIDReference = p.PanelMember_Id
		LEFT JOIN Individual gc ON c.GroupContact_Id = gc.GUIDReference
		LEFT JOIN DynamicRoleAssignment dra ON dra.Panelist_Id = p.GUIDReference
			AND dra.DynamicRole_Id = @MCRoleId
		LEFT JOIN individual di ON di.GUIDReference = dra.Candidate_Id
		WHERE si.GUIDReference = @pAssetItemId
		) ResultTable
	WHERE (
			(
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
								AND TransitionDate = @TransitionDate
								)
							OR (
								@op1 = @IsNotEqualTo
								AND CONVERT(DATE, TransitionDate) <> @TransitionDate
								)
							OR (
								@op1 = @IsLessThan
								AND CONVERT(DATE, TransitionDate) < @TransitionDate
								)
							OR (
								@op1 = @IsLessThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) <= @TransitionDate
								)
							OR (
								@op1 = @IsGreaterThan
								AND CONVERT(DATE, TransitionDate) > @TransitionDate
								)
							OR (
								@op1 = @IsGreaterThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) >= @TransitionDate
								)
							OR (
								@op1 = @Contains
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + '%'
								)
							OR (
								@op1 = @DoesNotContain
								AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @TransitionDateVARCHAR + '%'
								)
							OR (
								@op1 = @StartsWith
								AND CONVERT(DATE, TransitionDate) LIKE '' + @TransitionDateVARCHAR + '%'
								)
							OR (
								@op1 = @EndsWith
								AND TransitionDate LIKE '%' + @TransitionDateVARCHAR + ''
								)
							)
						OR (
							(
								@Secondop1 = @IsEqualTo
								AND CONVERT(DATE, TransitionDate) = @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsNotEqualTo
								AND CONVERT(DATE, TransitionDate) <> @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsLessThan
								AND CONVERT(DATE, TransitionDate) < @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsLessThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) <= @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsGreaterThan
								AND CONVERT(DATE, TransitionDate) > @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsGreaterThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) >= @SecondTransitionDate
								)
							OR (
								@Secondop1 = @Contains
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + '%'
								)
							OR (
								@Secondop1 = @DoesNotContain
								AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @SecondTransitionDateVARCHAR + '%'
								)
							OR (
								@Secondop1 = @StartsWith
								AND CONVERT(DATE, TransitionDate) LIKE '' + @SecondTransitionDateVARCHAR + '%'
								)
							OR (
								@Secondop1 = @EndsWith
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + ''
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
								AND CONVERT(DATE, TransitionDate) = @TransitionDate
								)
							OR (
								@op1 = @IsNotEqualTo
								AND CONVERT(DATE, TransitionDate) <> @TransitionDate
								)
							OR (
								@op1 = @IsLessThan
								AND CONVERT(DATE, TransitionDate) < @TransitionDate
								)
							OR (
								@op1 = @IsLessThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) <= @TransitionDate
								)
							OR (
								@op1 = @IsGreaterThan
								AND CONVERT(DATE, TransitionDate) > @TransitionDate
								)
							OR (
								@op1 = @IsGreaterThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) >= @TransitionDate
								)
							OR (
								@op1 = @Contains
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + '%'
								)
							OR (
								@op1 = @DoesNotContain
								AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @TransitionDateVARCHAR + '%'
								)
							OR (
								@op1 = @StartsWith
								AND CONVERT(DATE, TransitionDate) LIKE '' + @TransitionDateVARCHAR + '%'
								)
							OR (
								@op1 = @EndsWith
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + ''
								)
							)
						AND (
							(
								@Secondop1 = @IsEqualTo
								AND CONVERT(DATE, TransitionDate) = @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsNotEqualTo
								AND CONVERT(DATE, TransitionDate) <> @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsLessThan
								AND CONVERT(DATE, TransitionDate) < @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsLessThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) <= @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsGreaterThan
								AND CONVERT(DATE, TransitionDate) > @SecondTransitionDate
								)
							OR (
								@Secondop1 = @IsGreaterThanOrEqualTo
								AND CONVERT(DATE, TransitionDate) >= @SecondTransitionDate
								)
							OR (
								@Secondop1 = @Contains
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + '%'
								)
							OR (
								@Secondop1 = @DoesNotContain
								AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @SecondTransitionDateVARCHAR + '%'
								)
							OR (
								@Secondop1 = @StartsWith
								AND CONVERT(DATE, TransitionDate) LIKE '' + @SecondTransitionDateVARCHAR + '%'
								)
							OR (
								@Secondop1 = @EndsWith
								AND CONVERT(DATE, TransitionDate) LIKE '%' + @SecondTransitionDateVARCHAR + ''
								)
							)
						)
					)
				OR (
					@op1 = @IsEqualTo
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) = @TransitionDate
					)
				OR (
					@op1 = @IsNotEqualTo
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) <> @TransitionDate
					)
				OR (
					@op1 = @IsLessThan
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) < @TransitionDate
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) <= @TransitionDate
					)
				OR (
					@op1 = @IsGreaterThan
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) > @TransitionDate
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) >= @TransitionDate
					)
				OR (
					@op1 = @Contains
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) LIKE '%' + @TransitionDateVARCHAR + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) NOT LIKE '%' + @TransitionDateVARCHAR + '%'
					)
				OR (
					@op1 = @StartsWith
					AND @Secondop1 IS NULL
					AND CONVERT(DATE, TransitionDate) LIKE '' + @TransitionDateVARCHAR + '%'
					)
				OR (
					@op1 = @EndsWith
					AND @Secondop1 IS NULL
					AND TransitionDate LIKE '%' + @TransitionDateVARCHAR + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND TransitionTime = @TransitionTime
					)
				OR (
					@op2 = @IsNotEqualTo
					AND TransitionTime <> @TransitionTime
					)
				OR (
					@op2 = @IsLessThan
					AND TransitionTime < @TransitionTime
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND TransitionTime >= @TransitionTime
					)
				OR (
					@op2 = @IsGreaterThan
					AND TransitionTime > @TransitionTime
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND TransitionTime >= @TransitionTime
					)
				OR (
					@op2 = @Contains
					AND TransitionTime LIKE '%' + @TransitionTime + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND TransitionTime NOT LIKE '%' + @TransitionTime + '%'
					)
				OR (
					@op2 = @StartsWith
					AND TransitionTime LIKE '' + @TransitionTime + '%'
					)
				OR (
					@op2 = @EndsWith
					AND TransitionTime LIKE '%' + @TransitionTime + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND Location = @Location
					)
				OR (
					@op3 = @IsNotEqualTo
					AND Location <> @Location
					)
				OR (
					@op3 = @IsLessThan
					AND Location < @Location
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND Location >= @Location
					)
				OR (
					@op3 = @IsGreaterThan
					AND Location > @Location
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND Location >= @Location
					)
				OR (
					@op3 = @Contains
					AND Location LIKE '%' + @Location + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND Location NOT LIKE '%' + @Location + '%'
					)
				OR (
					@op3 = @StartsWith
					AND Location LIKE '' + @Location + '%'
					)
				OR (
					@op3 = @EndsWith
					AND Location LIKE '%' + @Location + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND PanelMember = @PanelMember
					)
				OR (
					@op4 = @IsNotEqualTo
					AND PanelMember <> @PanelMember
					)
				OR (
					@op4 = @IsLessThan
					AND PanelMember < @PanelMember
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND PanelMember >= @PanelMember
					)
				OR (
					@op4 = @IsGreaterThan
					AND PanelMember > @PanelMember
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND PanelMember >= @PanelMember
					)
				OR (
					@op4 = @Contains
					AND PanelMember LIKE '%' + @PanelMember + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND PanelMember NOT LIKE '%' + @PanelMember + '%'
					)
				OR (
					@op4 = @StartsWith
					AND PanelMember LIKE '' + @PanelMember + '%'
					)
				OR (
					@op4 = @EndsWith
					AND PanelMember LIKE '%' + @PanelMember + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND [State] = @State
					)
				OR (
					@op5 = @IsNotEqualTo
					AND [State] <> @State
					)
				OR (
					@op5 = @IsLessThan
					AND [State] < @State
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND [State] >= @State
					)
				OR (
					@op5 = @IsGreaterThan
					AND [State] > @State
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND [State] >= @State
					)
				OR (
					@op5 = @Contains
					AND [State] LIKE '%' + @State + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND [State] NOT LIKE '%' + @State + '%'
					)
				OR (
					@op5 = @StartsWith
					AND [State] LIKE '' + @State + '%'
					)
				OR (
					@op5 = @EndsWith
					AND [State] LIKE '%' + @State + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND Reason = @Reason
					)
				OR (
					@op6 = @IsNotEqualTo
					AND Reason <> @Reason
					)
				OR (
					@op6 = @IsLessThan
					AND Reason < @Reason
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND Reason >= @Reason
					)
				OR (
					@op6 = @IsGreaterThan
					AND Reason > @Reason
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND Reason >= @Reason
					)
				OR (
					@op6 = @Contains
					AND Reason LIKE '%' + @Reason + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND Reason NOT LIKE '%' + @Reason + '%'
					)
				OR (
					@op6 = @StartsWith
					AND Reason LIKE '' + @Reason + '%'
					)
				OR (
					@op6 = @EndsWith
					AND Reason LIKE '%' + @Reason + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND Comments = @Comment
					)
				OR (
					@op7 = @IsNotEqualTo
					AND Comments <> @Comment
					)
				OR (
					@op7 = @IsLessThan
					AND Comments < @Comment
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND Comments >= @Comment
					)
				OR (
					@op7 = @IsGreaterThan
					AND Comments > @Comment
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND Comments >= @Comment
					)
				OR (
					@op7 = @Contains
					AND Comments LIKE '%' + @Comment + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND Comments NOT LIKE '%' + @Comment + '%'
					)
				OR (
					@op7 = @StartsWith
					AND Comments LIKE '' + @Comment + '%'
					)
				OR (
					@op7 = @EndsWith
					AND Comments LIKE '%' + @Comment + ''
					)
				)
			AND (
				(@op8 IS NULL)
				OR (
					@op8 = @IsEqualTo
					AND ModifiedBy = @ModifiedBy
					)
				OR (
					@op8 = @IsNotEqualTo
					AND ModifiedBy <> @ModifiedBy
					)
				OR (
					@op8 = @IsLessThan
					AND ModifiedBy < @ModifiedBy
					)
				OR (
					@op8 = @IsLessThanOrEqualTo
					AND ModifiedBy >= @ModifiedBy
					)
				OR (
					@op8 = @IsGreaterThan
					AND ModifiedBy > @ModifiedBy
					)
				OR (
					@op8 = @IsGreaterThanOrEqualTo
					AND ModifiedBy >= @ModifiedBy
					)
				OR (
					@op8 = @Contains
					AND ModifiedBy LIKE '%' + @ModifiedBy + '%'
					)
				OR (
					@op8 = @DoesNotContain
					AND ModifiedBy NOT LIKE '%' + @ModifiedBy + '%'
					)
				OR (
					@op8 = @StartsWith
					AND ModifiedBy LIKE '' + @ModifiedBy + '%'
					)
				OR (
					@op8 = @EndsWith
					AND ModifiedBy LIKE '%' + @ModifiedBy + ''
					)
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'TransitionDate'
				AND @pOrderType = 'asc'
				THEN TransitionDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'TransitionDate'
				AND @pOrderType = 'desc'
				THEN TransitionDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'TimeInSeconds'
				AND @pOrderType = 'asc'
				THEN TransitionTime
			END ASC
		,CASE 
			WHEN @pOrderBy = 'TimeInSeconds'
				AND @pOrderType = 'desc'
				THEN TransitionTime
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Location'
				AND @pOrderType = 'asc'
				THEN TransitionTime
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Location'
				AND @pOrderType = 'desc'
				THEN TransitionTime
			END DESC
		,CASE 
			WHEN @pOrderBy = 'PanelMember'
				AND @pOrderType = 'asc'
				THEN PanelMember
			END ASC
		,CASE 
			WHEN @pOrderBy = 'PanelMember'
				AND @pOrderType = 'desc'
				THEN PanelMember
			END DESC
		,CASE 
			WHEN @pOrderBy = 'State'
				AND @pOrderType = 'asc'
				THEN [State]
			END ASC
		,CASE 
			WHEN @pOrderBy = 'State'
				AND @pOrderType = 'desc'
				THEN [State]
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Reason'
				AND @pOrderType = 'asc'
				THEN PanelMember
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Reason'
				AND @pOrderType = 'desc'
				THEN Reason
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Comment'
				AND @pOrderType = 'asc'
				THEN Comments
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Comment'
				AND @pOrderType = 'desc'
				THEN Comments
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ModifiedBy'
				AND @pOrderType = 'asc'
				THEN Comments
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ModifiedBy'
				AND @pOrderType = 'desc'
				THEN ModifiedBy
			END DESC OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)
END