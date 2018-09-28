/*##########################################################################
-- Name		    : AllOrderListQuery
-- Date             : 2015-04-26
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
       @pIndividualId VARCHAR(20) -- Individual Id of type varchar
       @pCultureCode int  - Culture Code of type int
	   @pGPSUser VARCHAR(100) - Logged user
	   @pOrderBy VARCHAR(100)
	   @pOrderType VARCHAR(10)
	   @pPageNumber INT = 1
	   @pPageSize INT = 100
	   @pdays NVARCHAR(10)
	   @pIsExport BIT = 0
	   @pParametersTable dbo.GridParametersTable readonly
-- Sample Execution :
		declare @p8 dbo.GridParametersTable
		--insert into @p8 values(N'BusinessId',N'0001-01',N'IsNotEqualTo',NULL,NULL,NULL)
		--insert into @p8 values(N'CreationTimeStamp',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
		--insert into @p8 values(N'Points',N'100',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
		--insert into @p8 values(N'DiaryDateFull',N'2006.7.4',N'IsEqualTo',NULL,NULL,NULL)
		--insert into @p8 values(N'BusinessId',N'10257901-01',N'IsEqualTo',NULL,NULL,NULL)
		exec AllOrderListQuery '70387977-88F8-40C4-BCD0-1173F1AAFFC4',2057,null,'asc',1,100,'40',0,@p8
##########################################################################
-- version  user						date        change 
-- 1.0  Jagadeesh Boddu				  2015-04-26   Initial
##########################################################################*/

CREATE PROCEDURE [dbo].[AllOrderListQuery]

(

  @pOrdersFilter VARCHAR(256)

 ,@pCountryId UNIQUEIDENTIFIER

 ,@pCultureCode INT = 2057

 ,@pOrderBy VARCHAR(100)

 ,@pOrderType VARCHAR(10)

 ,@pPageNumber INT = 1

 ,@pPageSize INT = 100

 ,@pIsExport BIT = 0

 ,@pParametersTable dbo.GridParametersTable readonly

)

AS

BEGIN

 

declare @DynamicRoleId uniqueidentifier

select @DynamicRoleId=dr.dynamicroleid

from DynamicRole dr inner join Translation t on dr.Translation_Id=t.TranslationId

where dr.country_id=@pCountryId

and T.keyname='MainContactRoleName'



CREATE TABLE #OrdersList

(

 [Id] BIGINT,

 CountryOrderId BIGINT,

 Location NVARCHAR(Max),

 GroupId NVARCHAR(Max),

 HousewifeName NVARCHAR(Max),

 TypeAssetName NVARCHAR(Max),

 DeliveryContent  NVARCHAR(Max),

 [State] NVARCHAR(Max),

 Region NVARCHAR(Max),

 CreationTimeStamp DATETIME,

 DeliveredOn DATETIME,

 SendBy NVARCHAR(Max),

 Comments NVARCHAR(Max),

 IsLastState BIT,

 IsReadyToSend BIT,

 [Reason] NVARCHAR(MAX),

 IndividualBussinesId NVARCHAR(256) ,
 PickUpdate DATETIME,
 FromHours int,
 ToHours int

)


IF (@pOrdersFilter='ToBeSentOrderListQuery')

BEGIN

	INSERT INTO #OrdersList(Location, GroupId, HousewifeName, [Id],CountryOrderId,Comments,DeliveredOn,CreationTimeStamp,SendBy,[State],[TypeAssetName],[Reason],IsReadyToSend,IsLastState,Region,DeliveryContent,IndividualBussinesId,PickUpdate,FromHours,ToHours)

	select 

		 isnull(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+isnull(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','')+'('+i.IndividualId+'
)' as Location,
         
		 I.IndividualId as GroupId,

		 ISNULL(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+ISNULL(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+ISNULL(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','') as HousewifeName,

		 O.OrderId as [Id],

		 O.CountryOrderId,

		 O.Comments,

		 CONVERT(VARCHAR(20),O.DispatchedDate,20) as DeliveredOn,

		 CONVERT(VARCHAR(20),O.CreationTimeStamp,20) as CreationTimeStamp,

		 IIF(sd.Code='OrderSentState', O.GPSUser,'') as SendBy,

		 dbo.GetTranslationValue(sd.Label_Id,@pCultureCode) as [State],

		 dbo.GetTranslationValue(OT.Description_Id,@pCultureCode) as [TypeAssetName],

		 dbo.GetTranslationValue(ROT.Description_Id,@pCultureCode) as [Reason],

		 dbo.fn_GetOrderIsReadyToSend(O.OrderId) as IsReadyToSend,

		 (CASE WHEN TB.[Type]='FinalTransitionBehavior' THEN 1 ELSE 0 END) AS IsLastState,

		  COALESCE((CASE WHEN ED.Translation_Id IS NULL THEN NULL ELSE ED.Value+'-'+dbo.GetTranslationValue(ED.Translation_Id,2057) END),
		 (CASE WHEN RED.Translation_Id IS NULL THEN NULL ELSE RED.Value+'-'+dbo.GetTranslationValue(RED.Translation_Id,2057) END)) as Region,

		 dbo.fn_GetOrderItems(O.OrderId) as DeliveryContent,

		 i.IndividualId as IndividualBussinesId,
		 O.PickUpdate,
		 O.FromHours,
		 o.ToHours

	from [Order] O 	

	INNER JOIN StateDefinition sd ON O.State_Id=sd.Id

	INNER JOIN TransitionBehavior TB ON TB.GUIDReference=sd.StateDefinitionBehavior_Id

	INNER JOIN [OrderType] OT ON O.[Type_Id]=OT.Id

	LEFT OUTER JOIN [ReasonForOrderType] ROT ON O.Reason_Id=ROT.Id

	INNER JOIN StockPanelistLocation spl ON o.Location_Id = spl.GUIDReference

	INNER JOIN Panelist p on p.GUIDReference=spl.Panelist_Id

	INNER JOIN individual i on p.PanelMember_Id=i.GUIDReference

	INNER JOIN Candidate ci ON ci.GUIDReference = i.GUIDReference

	INNER JOIN CollectiveMembership CM ON CM.Individual_Id = i.GUIDReference

	INNER JOIN Collective C ON CM.Group_Id = C.GUIDReference

	INNER JOIN PersonalIdentification PID ON i.PersonalIdentificationId=PID.PersonalIdentificationId

	LEFT JOIN Attribute A ON A.[Key] = 'H503' AND A.Country_Id = @pCountryId

	LEFT JOIN AttributeValue AV ON AV.CandidateId = C.GUIDReference AND AV.DemographicId = A.GUIDReference

	LEFT JOIN EnumDefinition ED ON AV.EnumDefinition_Id = ED.Id

	LEFT JOIN GeographicArea ga ON ga.GUIDReference = ci.GeographicArea_Id

	LEFT JOIN Attribute RA ON RA.[Key] = 'Region' AND RA.Country_Id = @pCountryId

	LEFT JOIN AttributeValue RAV ON RAV.RespondentId = ga.GUIDReference AND RAV.DemographicId = RA.GUIDReference

	LEFT JOIN EnumDefinition RED ON RAV.EnumDefinition_Id = RED.Id

	WHERE O.Country_Id=@pCountryId AND sd.Code IN ('OrderToBeSentState') AND OT.Code != 4 --DO NOT SHOW Return For Replacement

		AND EXISTS (SELECT 1 FROM OrderItem oi WHERE oi.order_id=OrderId)

	union all

	select 

		 isnull(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+isnull(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','')+'('+cast(c.sequence 
as varchar)+')' as Location,

		 I.IndividualId as GroupId,

		 isnull(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+isnull(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','') as HousewifeName,
		 
		 O.OrderId as [Id],

		 O.CountryOrderId,

		 O.Comments,

		 CONVERT(VARCHAR(20),O.DispatchedDate,20) as DeliveredOn,

		 CONVERT(VARCHAR(20),O.CreationTimeStamp,20) as CreationTimeStamp,

		 IIF(sd.Code='OrderSentState', O.GPSUser,'') as SendBy,

		 dbo.GetTranslationValue(sd.Label_Id,@pCultureCode) as [State],

		 dbo.GetTranslationValue(OT.Description_Id,@pCultureCode) as [TypeAssetName],

		 dbo.GetTranslationValue(ROT.Description_Id,@pCultureCode) as [Reason],

		 dbo.fn_GetOrderIsReadyToSend(O.OrderId) as IsReadyToSend,

		 (CASE WHEN TB.[Type]='FinalTransitionBehavior' THEN 1 ELSE 0 END) AS IsLastState,

		  COALESCE((CASE WHEN ED.Translation_Id IS NULL THEN NULL ELSE ED.Value+'-'+dbo.GetTranslationValue(ED.Translation_Id,2057) END),
		 (CASE WHEN RED.Translation_Id IS NULL THEN NULL ELSE RED.Value+'-'+dbo.GetTranslationValue(RED.Translation_Id,2057) END)) as Region,

		 dbo.fn_GetOrderItems(O.OrderId) as DeliveryContent,

		 i.IndividualId as IndividualBussinesId,
		 o.PickUpdate,
	     o.FromHours,
	     o.ToHours

	from [Order] O	

	INNER JOIN StateDefinition sd ON O.State_Id=sd.Id

	INNER JOIN TransitionBehavior TB ON TB.GUIDReference=sd.StateDefinitionBehavior_Id

	INNER JOIN [OrderType] OT ON O.[Type_Id]=OT.Id

	LEFT OUTER JOIN [ReasonForOrderType] ROT ON O.Reason_Id=ROT.Id

	INNER JOIN StockPanelistLocation spl ON o.Location_Id = spl.GUIDReference

	INNER JOIN Panelist p on p.GUIDReference=spl.Panelist_Id

	INNER JOIN collective c on p.PanelMember_Id=c.GUIDReference

	INNER JOIN Candidate CC ON CC.GUIDReference = C.GUIDReference

	LEFT OUTER JOIN [DynamicRoleAssignment] DRA ON DRA.Panelist_Id=p.GUIDReference and dra.DynamicRole_Id=@DynamicRoleId

	LEFT OUTER JOIN individual i on DRA.Candidate_Id=i.GUIDReference

	LEFT OUTER JOIN PersonalIdentification PID ON i.PersonalIdentificationId=PID.PersonalIdentificationId

	LEFT JOIN Attribute A ON A.[Key] = 'H503' AND A.Country_Id = @pCountryId

	LEFT JOIN AttributeValue AV ON AV.CandidateId = C.GUIDReference AND AV.DemographicId = A.GUIDReference

	LEFT JOIN EnumDefinition ED ON AV.EnumDefinition_Id = ED.Id

	LEFT JOIN GeographicArea ga ON ga.GUIDReference = CC.GeographicArea_Id

	LEFT JOIN Attribute RA ON RA.[Key] = 'Region' AND RA.Country_Id = @pCountryId

	LEFT JOIN AttributeValue RAV ON RAV.RespondentId = ga.GUIDReference AND RAV.DemographicId = RA.GUIDReference

	LEFT JOIN EnumDefinition RED ON RAV.EnumDefinition_Id = RED.Id

	WHERE O.Country_Id=@pCountryId AND sd.Code IN ('OrderToBeSentState') AND OT.Code != 4 --DO NOT SHOW Return For Replacement

		AND EXISTS (SELECT 1 FROM OrderItem oi WHERE oi.order_id=OrderId)

END

ELSE

BEGIN

	IF(@pOrderBy IS NULL)

	SET @pOrderBy = 'CountryOrderId'

	IF(@pOrderType IS NULL)

	SET @pOrderType='DESC'

	INSERT INTO #OrdersList(Location,GroupId, HousewifeName,[Id],CountryOrderId,Comments,DeliveredOn,CreationTimeStamp,SendBy,[State],[TypeAssetName],[Reason],IsReadyToSend,IsLastState,Region,DeliveryContent,IndividualBussinesId,PickUpdate,FromHours,ToHours)

	select 

		 isnull(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+isnull(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','')+'('+i.IndividualId+
')' as Location,
         
		 i.IndividualId as GroupId,

		 isnull(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+isnull(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','') as HousewifeName,

		 O.OrderId as [Id],

		 O.CountryOrderId,

		 O.Comments,

		 CONVERT(VARCHAR(20),O.DispatchedDate,20) as DeliveredOn,

		 CONVERT(VARCHAR(20),O.CreationTimeStamp,20) as CreationTimeStamp,

		 IIF(sd.Code='OrderSentState', O.GPSUser,'') as SendBy,

		 dbo.GetTranslationValue(sd.Label_Id,@pCultureCode) as [State],

		 dbo.GetTranslationValue(OT.Description_Id,@pCultureCode) as [TypeAssetName],

		 dbo.GetTranslationValue(ROT.Description_Id,@pCultureCode) as [Reason],

		 dbo.fn_GetOrderIsReadyToSend(O.OrderId) as IsReadyToSend,

		 (CASE WHEN TB.[Type]='FinalTransitionBehavior' THEN 1 ELSE 0 END) AS IsLastState,

		  COALESCE((CASE WHEN ED.Translation_Id IS NULL THEN NULL ELSE ED.Value+'-'+dbo.GetTranslationValue(ED.Translation_Id,2057) END),
		 (CASE WHEN RED.Translation_Id IS NULL THEN NULL ELSE RED.Value+'-'+dbo.GetTranslationValue(RED.Translation_Id,2057) END)) as Region,

		 dbo.fn_GetOrderItems(O.OrderId) as DeliveryContent,

		 i.IndividualId as IndividualBussinesId,
		 o.PickUpdate,

	o.FromHours,
	o.ToHours
	from [Order] O 

	INNER JOIN StateDefinition sd ON O.State_Id=sd.Id

	INNER JOIN TransitionBehavior TB ON TB.GUIDReference=sd.StateDefinitionBehavior_Id

	INNER JOIN [OrderType] OT ON O.[Type_Id]=OT.Id

	LEFT OUTER JOIN [ReasonForOrderType] ROT ON O.Reason_Id=ROT.Id

	INNER JOIN StockPanelistLocation spl ON o.Location_Id = spl.GUIDReference

	INNER JOIN Panelist p on p.GUIDReference=spl.Panelist_Id

	INNER JOIN individual i on p.PanelMember_Id=i.GUIDReference

	INNER JOIN Candidate ci ON ci.GUIDReference = i.GUIDReference

	INNER JOIN CollectiveMembership CM ON CM.Individual_Id = i.GUIDReference

	INNER JOIN Collective C ON CM.Group_Id = C.GUIDReference

	INNER JOIN PersonalIdentification PID ON i.PersonalIdentificationId=PID.PersonalIdentificationId

	LEFT JOIN Attribute A ON A.[Key] = 'H503' AND A.Country_Id = @pCountryId

	LEFT JOIN AttributeValue AV ON AV.CandidateId = C.GUIDReference AND AV.DemographicId = A.GUIDReference

	LEFT JOIN EnumDefinition ED ON AV.EnumDefinition_Id = ED.Id

	LEFT JOIN GeographicArea ga ON ga.GUIDReference = ci.GeographicArea_Id

	LEFT JOIN Attribute RA ON RA.[Key] = 'Region' AND RA.Country_Id = @pCountryId

	LEFT JOIN AttributeValue RAV ON RAV.RespondentId = ga.GUIDReference AND RAV.DemographicId = RA.GUIDReference

	LEFT JOIN EnumDefinition RED ON RAV.EnumDefinition_Id = RED.Id

	WHERE O.Country_Id=@pCountryId AND OT.Code != 4 --DO NOT SHOW Return For Replacement

	union all

	select 

		 isnull(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+isnull(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','')+'('+cast(c.sequence 
as varchar)+')' as Location,

		 cast(c.sequence as varchar) as GroupId,

		 ISNULL(pid.FirstOrderedName,'') +IIF(pid.FirstOrderedName is not null,' ','')+ISNULL(pid.MiddleOrderedName,'')+IIF(pid.MiddleOrderedName is not null,' ','')+isnull(pid.LastOrderedName,'')+IIF(pid.LastOrderedName is not null,' ','') as HousewifeName,

		 O.OrderId as [Id],

		 O.CountryOrderId,

		 O.Comments,

		 CONVERT(VARCHAR(20),O.DispatchedDate,20) as DeliveredOn,

		 CONVERT(VARCHAR(20),O.CreationTimeStamp,20) as CreationTimeStamp,

		 IIF(sd.Code='OrderSentState', O.GPSUser,'') as SendBy,

		 dbo.GetTranslationValue(sd.Label_Id,@pCultureCode) as [State],

		 dbo.GetTranslationValue(OT.Description_Id,@pCultureCode) as [TypeAssetName],

		 dbo.GetTranslationValue(ROT.Description_Id,@pCultureCode) as [Reason],

		 dbo.fn_GetOrderIsReadyToSend(O.OrderId) as IsReadyToSend,

		 (CASE WHEN TB.[Type]='FinalTransitionBehavior' THEN 1 ELSE 0 END) AS IsLastState,

		  COALESCE((CASE WHEN ED.Translation_Id IS NULL THEN NULL ELSE ED.Value+'-'+dbo.GetTranslationValue(ED.Translation_Id,2057) END),
		 (CASE WHEN RED.Translation_Id IS NULL THEN NULL ELSE RED.Value+'-'+dbo.GetTranslationValue(RED.Translation_Id,2057) END)) as Region,

		 dbo.fn_GetOrderItems(O.OrderId) as DeliveryContent,

		 i.IndividualId as IndividualBussinesId,
		 o.PickUpdate,
         o.FromHours,
	     o.ToHours
	from [Order] O

	INNER JOIN StateDefinition sd ON O.State_Id=sd.Id

	INNER JOIN TransitionBehavior TB ON TB.GUIDReference=sd.StateDefinitionBehavior_Id

	INNER JOIN [OrderType] OT ON O.[Type_Id]=OT.Id

	LEFT OUTER JOIN [ReasonForOrderType] ROT ON O.Reason_Id=ROT.Id

	INNER JOIN StockPanelistLocation spl ON o.Location_Id = spl.GUIDReference

	INNER JOIN Panelist p on p.GUIDReference=spl.Panelist_Id

	INNER JOIN collective c on p.PanelMember_Id=c.GUIDReference

	INNER JOIN Candidate CC ON CC.GUIDReference = C.GUIDReference

	LEFT OUTER JOIN [DynamicRoleAssignment] DRA ON DRA.Panelist_Id=p.GUIDReference and dra.DynamicRole_Id=@DynamicRoleId

	LEFT OUTER JOIN individual i on DRA.Candidate_Id=i.GUIDReference

	LEFT OUTER JOIN PersonalIdentification PID ON i.PersonalIdentificationId=PID.PersonalIdentificationId

	LEFT JOIN Attribute A ON A.[Key] = 'H503' AND A.Country_Id = @pCountryId

	LEFT JOIN AttributeValue AV ON AV.CandidateId = C.GUIDReference AND AV.DemographicId = A.GUIDReference

	LEFT JOIN EnumDefinition ED ON AV.EnumDefinition_Id = ED.Id

	LEFT JOIN GeographicArea ga ON ga.GUIDReference = CC.GeographicArea_Id

	LEFT JOIN Attribute RA ON RA.[Key] = 'Region' AND RA.Country_Id = @pCountryId

	LEFT JOIN AttributeValue RAV ON RAV.RespondentId = ga.GUIDReference AND RAV.DemographicId = RA.GUIDReference

	LEFT JOIN EnumDefinition RED ON RAV.EnumDefinition_Id = RED.Id

	WHERE O.Country_Id=@pCountryId AND OT.Code != 4 --DO NOT SHOW Return For Replacement

END



DECLARE @Code INT

DECLARE @Location NVARCHAR(max)

DECLARE @GroupId NVARCHAR(max)

DECLARE @HousewifeName NVARCHAR(max)

DECLARE @Type NVARCHAR(max)

DECLARE @DeliveryContent NVARCHAR(max)

DECLARE @Status VARCHAR(256)

DECLARE @Region VARCHAR(256)

DECLARE @OrderedDate DATETIME

DECLARE @DispatchDate DATETIME

DECLARE @SentBy NVARCHAR(max)

DECLARE @Reason NVARCHAR(max)

DECLARE @Comment NVARCHAR(max)



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
	

DECLARE @SecondOrderedDate7 DATETIME

DECLARE @LogicalOperator7 VARCHAR(5)

DECLARE @SecondOperator7 VARCHAR(5)



DECLARE @SecondDispatchDate8 DATETIME

DECLARE @LogicalOperator8 VARCHAR(5)

DECLARE @SecondOperator8 VARCHAR(5)





SELECT @op1 = Opertor ,@Code = CAST(ParameterValue AS INT) FROM @pParametersTable WHERE ParameterName = 'CountryOrderId'

SELECT @op2 = Opertor ,@Location = ParameterValue FROM @pParametersTable WHERE ParameterName = 'Location'

SELECT @op3 = Opertor ,@Type = ParameterValue FROM @pParametersTable WHERE ParameterName = 'TypeAssetName'

SELECT @op4 = Opertor ,@DeliveryContent = ParameterValue FROM @pParametersTable WHERE ParameterName = 'DeliveryContent'

SELECT @op5 = Opertor ,@Status = ParameterValue FROM @pParametersTable WHERE ParameterName = 'State'

SELECT @op6 = Opertor ,@Region = ParameterValue FROM @pParametersTable WHERE ParameterName = 'Region'


SELECT @op7 = Opertor ,@OrderedDate = CAST(ParameterValue AS DATETIME)

	,@SecondOperator7 = SecondParameterOperator,@SecondOrderedDate7 = CAST(SecondParameterValue AS DATETIME),@LogicalOperator7 = LogicalOperator

 FROM @pParametersTable WHERE ParameterName = 'CreationTimeStamp'


SELECT @op8 = Opertor ,@DispatchDate = CAST(ParameterValue AS DATETIME) 

,@SecondOperator8 = SecondParameterOperator,@SecondDispatchDate8 = CAST(SecondParameterValue AS DATETIME),@LogicalOperator8 = LogicalOperator

FROM @pParametersTable WHERE ParameterName = 'DeliveredOn'


SELECT @op9 = Opertor ,@SentBy = ParameterValue FROM @pParametersTable WHERE ParameterName = 'SendBy'

SELECT @op10 = Opertor ,@Reason = ParameterValue FROM @pParametersTable WHERE ParameterName = 'Reason'

SELECT @op11 = Opertor ,@Comment = ParameterValue FROM @pParametersTable WHERE ParameterName = 'Comments'

SELECT @op12 = Opertor ,@GroupId = ParameterValue FROM @pParametersTable WHERE ParameterName = 'GroupId'

SELECT @op13 = Opertor ,@HousewifeName = ParameterValue FROM @pParametersTable WHERE ParameterName = 'HousewifeName'


DECLARE @OrderedDateVarchar VARCHAR(100) = CAST(@OrderedDate AS VARCHAR) ,@SecondOrderedDate7Varchar VARCHAR(100) = CAST(@SecondOrderedDate7 AS VARCHAR)

DECLARE @DispatchDateVarchar VARCHAR(100) = CAST(@DispatchDate AS VARCHAR) ,@SecondDispatchDate8Varchar VARCHAR(100) = CAST(@SecondDispatchDate8 AS VARCHAR)







DECLARE @WhereParameter VARCHAR(MAX),@pOrderByParameter VARCHAR(MAX) = NULL

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

		SET @pPageSize = 15000;



	IF (@pIsExport = 0)

	BEGIN

	

		SELECT COUNT(0) AS TotlaRows

	FROM #OrdersList

	WHERE 

	(

		(@op1 IS NULL)

		OR (

			@op1 = @IsEqualTo

			AND CountryOrderId = @Code

			)

		OR (

			@op1 = @IsNotEqualTo

			AND CountryOrderId <> @Code

			)

		OR (

			@op1 = @IsLessThan

			AND CountryOrderId < @Code

			)

		OR (

			@op1 = @IsLessThanOrEqualTo

			AND CountryOrderId <= @Code

			)

		OR (

			@op1 = @IsGreaterThan

			AND CountryOrderId > @Code

			)

		OR (

			@op1 = @IsGreaterThanOrEqualTo

			AND CountryOrderId >= @Code

			)

		--OR (

		--	@op1 = @Contains

		--	AND CountryOrderId LIKE '%' + @Code + '%'

		--	)

		--OR (

		--	@op1 = @DoesNotContain

		--	AND CountryOrderId NOT LIKE '%' + @Code + '%'

		--	)

		--OR (

		--	@op1 = @StartsWith

		--	AND CountryOrderId LIKE '' + @Code + '%'

		--	)

		--OR (

		--	@op1 = @EndsWith

		--	AND CountryOrderId LIKE '%' + @Code + ''

		--	)

		)

		AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND Location = @Location

					)

				OR (

					@op2 = @IsNotEqualTo

					AND Location <> @Location

					)

				OR (

					@op2 = @IsLessThan

					AND Location < @Location

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND Location <= @Location

					)

				OR (

					@op2 = @IsGreaterThan

					AND Location > @Location

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND Location >= @Location

					)

				OR (

					@op2 = @Contains

					AND Location LIKE '%' + @Location + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND Location NOT LIKE '%' + @Location + '%'

					)

				OR (

					@op2 = @StartsWith

					AND Location LIKE '' + @Location + '%'

					)

				OR (

					@op2 = @EndsWith

					AND Location LIKE '%' + @Location + ''

					)

			)

			AND (

				(@op3 IS NULL)

				OR (

					@op3 = @IsEqualTo

					AND TypeAssetName = @Type

					)

				OR (

					@op3 = @IsNotEqualTo

					AND TypeAssetName <> @Type

					)

				OR (

					@op3 = @IsLessThan

					AND TypeAssetName < @Type

					)

				OR (

					@op3 = @IsLessThanOrEqualTo

					AND TypeAssetName <= @Type

					)

				OR (

					@op3 = @IsGreaterThan

					AND TypeAssetName > @Type

					)

				OR (

					@op3 = @IsGreaterThanOrEqualTo

					AND TypeAssetName >= @Type

					)

				OR (

					@op3 = @Contains

					AND TypeAssetName LIKE '%' + @Type + '%'

					)

				OR (

					@op3 = @DoesNotContain

					AND TypeAssetName NOT LIKE '%' + @Type + '%'

					)

				OR (

					@op3 = @StartsWith

					AND TypeAssetName LIKE '' + @Type + '%'

					)

				OR (

					@op3 = @EndsWith

					AND TypeAssetName LIKE '%' + @Type + ''

					)

			)

			AND (

				(@op4 IS NULL)

				OR (

					@op4 = @IsEqualTo

					AND DeliveryContent = @DeliveryContent

					)

				OR (

					@op4 = @IsNotEqualTo

					AND DeliveryContent <> @DeliveryContent

					)

				OR (

					@op4 = @IsLessThan

					AND DeliveryContent < @DeliveryContent

					)

				OR (

					@op4 = @IsLessThanOrEqualTo

					AND DeliveryContent <= @DeliveryContent

					)

				OR (

					@op4 = @IsGreaterThan

					AND DeliveryContent > @DeliveryContent

					)

				OR (

					@op4 = @IsGreaterThanOrEqualTo

					AND DeliveryContent >= @DeliveryContent

					)

				OR (

					@op4 = @Contains

					AND DeliveryContent LIKE '%' + @DeliveryContent + '%'

					)

				OR (

					@op4 = @DoesNotContain

					AND DeliveryContent NOT LIKE '%' + @DeliveryContent + '%'

					)

				OR (

					@op4 = @StartsWith

					AND DeliveryContent LIKE '' + @DeliveryContent + '%'

					)

				OR (

					@op4 = @EndsWith

					AND DeliveryContent LIKE '%' + @DeliveryContent + ''

					)

			)

			AND (

				(@op5 IS NULL)

				OR (

					@op5 = @IsEqualTo

					AND [State] = @Status

					)

				OR (

					@op5 = @IsNotEqualTo

					AND [State] <> @Status

					)

				OR (

					@op5 = @IsLessThan

					AND [State] < @Status

					)

				OR (

					@op5 = @IsLessThanOrEqualTo

					AND [State] <= @Status

					)

				OR (

					@op5 = @IsGreaterThan

					AND [State] > @Status

					)

				OR (

					@op5 = @IsGreaterThanOrEqualTo

					AND [State] >= @Status

					)

				OR (

					@op5 = @Contains

					AND [State] LIKE '%' + @Status + '%'

					)

				OR (

					@op5 = @DoesNotContain

					AND [State] NOT LIKE '%' + @Status + '%'

					)

				OR (

					@op5 = @StartsWith

					AND [State] LIKE '' + @Status + '%'

					)

				OR (

					@op5 = @EndsWith

					AND [State] LIKE '%' + @Status + ''

					)

			)

			AND (

				(@op6 IS NULL)

				OR (

					@op6 = @IsEqualTo

					AND Region = @Region

					)

				OR (

					@op6 = @IsNotEqualTo

					AND Region <> @Region

					)

				OR (

					@op6 = @IsLessThan

					AND Region < @Region

					)

				OR (

					@op6 = @IsLessThanOrEqualTo

					AND Region <= @Region

					)

				OR (

					@op6 = @IsGreaterThan

					AND Region > @Region

					)

				OR (

					@op6 = @IsGreaterThanOrEqualTo

					AND Region >= @Region

					)

				OR (

					@op6 = @Contains

					AND Region LIKE '%' + @Region + '%'

					)

				OR (

					@op6 = @DoesNotContain

					AND Region NOT LIKE '%' + @Region + '%'

					)

				OR (

					@op6 = @StartsWith

					AND Region LIKE '' + @Region + '%'

					)

				OR (

					@op6 = @EndsWith

					AND Region LIKE '%' + @Region + ''

					)

			)



			/*-------------Date Part - Start -------------*/



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

								AND CreationTimeStamp = @OrderedDate

								)

							OR (

								@op7 = @IsNotEqualTo

								AND CreationTimeStamp <> @OrderedDate

								)

							OR (

								@op7 = @IsLessThan

								AND CreationTimeStamp < @OrderedDate

								)

							OR (

								@op7 = @IsLessThanOrEqualTo

								AND CreationTimeStamp <= @OrderedDate

								)

							OR (

								@op7 = @IsGreaterThan

								AND CreationTimeStamp > @OrderedDate

								)

							OR (

								@op7 = @IsGreaterThanOrEqualTo

								AND CreationTimeStamp >= @OrderedDate

								)

							OR (

								@op7 = @Contains

								AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + '%'

								)

							OR (

								@op7 = @DoesNotContain

								AND CreationTimeStamp NOT LIKE '%' + @OrderedDateVarchar + '%'

								)

							OR (

								@op7 = @StartsWith

								AND CreationTimeStamp LIKE '' + @OrderedDateVarchar + '%'

								)

							OR (

								@op7 = @EndsWith

								AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + ''

								)

							)

						OR (

							(

								@SecondOperator7 = @IsEqualTo

								AND CreationTimeStamp = @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsNotEqualTo

								AND CreationTimeStamp <> @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsLessThan

								AND CreationTimeStamp < @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsLessThanOrEqualTo

								AND CreationTimeStamp <= @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsGreaterThan

								AND CreationTimeStamp > @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsGreaterThanOrEqualTo

								AND CreationTimeStamp >= @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @Contains

								AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + '%'

								)

							OR (

								@SecondOperator7 = @DoesNotContain

								AND CreationTimeStamp NOT LIKE '%' + @SecondOrderedDate7Varchar + '%'

								)

							OR (

								@SecondOperator7 = @StartsWith

								AND CreationTimeStamp LIKE '' + @SecondOrderedDate7Varchar + '%'

								)

							OR (

								@SecondOperator7 = @EndsWith

								AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + ''

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

								AND CreationTimeStamp = @OrderedDate

								)

							OR (

								@op7 = @IsNotEqualTo

								AND CreationTimeStamp <> @OrderedDate

								)

							OR (

								@op7 = @IsLessThan

								AND CreationTimeStamp < @OrderedDate

								)

							OR (

								@op7 = @IsLessThanOrEqualTo

								AND CreationTimeStamp <= @OrderedDate

								)

							OR (

								@op7 = @IsGreaterThan

								AND CreationTimeStamp > @OrderedDate

								)

							OR (

								@op7 = @IsGreaterThanOrEqualTo

								AND CreationTimeStamp >= @OrderedDate

								)

							OR (

								@op7 = @Contains

								AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + '%'

								)

							OR (

								@op7 = @DoesNotContain

								AND CreationTimeStamp NOT LIKE '%' + @OrderedDateVarchar + '%'

								)

							OR (

								@op7 = @StartsWith

								AND CreationTimeStamp LIKE '' + @OrderedDateVarchar + '%'

								)

							OR (

								@op7 = @EndsWith

								AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + ''

								)

							)

						AND (

							(

								@SecondOperator7 = @IsEqualTo

								AND CreationTimeStamp = @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsNotEqualTo

								AND CreationTimeStamp <> @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsLessThan

								AND CreationTimeStamp < @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsLessThanOrEqualTo

								AND CreationTimeStamp <= @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsGreaterThan

								AND CreationTimeStamp > @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @IsGreaterThanOrEqualTo

								AND CreationTimeStamp >= @SecondOrderedDate7

								)

							OR (

								@SecondOperator7 = @Contains

								AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + '%'

								)

							OR (

								@SecondOperator7 = @DoesNotContain

								AND CreationTimeStamp NOT LIKE '%' + @SecondOrderedDate7Varchar + '%'

								)

							OR (

								@SecondOperator7 = @StartsWith

								AND CreationTimeStamp LIKE '' + @SecondOrderedDate7Varchar + '%'

								)

							OR (

								@SecondOperator7 = @EndsWith

								AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + ''

								)

							)

						)

					)

				

				--------

					OR (

                            @op7 = @IsEqualTo AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp = @OrderedDate

                            )

                    OR (

                            @op7 = @IsNotEqualTo AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp <> @OrderedDate

                            )

                    OR (

                            @op7 = @IsLessThan AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp < @OrderedDate

                            )

                    OR (

                            @op7 = @IsLessThanOrEqualTo AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp <= @OrderedDate

                            )

                    OR (

                            @op7 = @IsGreaterThan AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp > @OrderedDate

                            )

                    OR (

                            @op7 = @IsGreaterThanOrEqualTo AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp >= @OrderedDate

                            )

                    OR (

                            @op7 = @Contains AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + '%'

                            )

                    OR (

                            @op7 = @DoesNotContain AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp NOT LIKE '%' + @OrderedDateVarchar + '%'

                            )

                    OR (

                            @op7 = @StartsWith AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp LIKE '' + @OrderedDateVarchar + '%'

                            )

                    OR (

                            @op7 = @EndsWith AND @SecondOperator7 IS NULL

                            AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + ''

                            )

                    )

				--------



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

								AND DeliveredOn = @DispatchDate

								)

							OR (

								@op8 = @IsNotEqualTo

								AND DeliveredOn <> @DispatchDate

								)

							OR (

								@op8 = @IsLessThan

								AND DeliveredOn < @DispatchDate

								)

							OR (

								@op8 = @IsLessThanOrEqualTo

								AND DeliveredOn <= @DispatchDate

								)

							OR (

								@op8 = @IsGreaterThan

								AND DeliveredOn > @DispatchDate

								)

							OR (

								@op8 = @IsGreaterThanOrEqualTo

								AND DeliveredOn >= @DispatchDate

								)

							OR (

								@op8 = @Contains

								AND DeliveredOn LIKE '%' + @DispatchDateVarchar + '%'

								)

							OR (

								@op8 = @DoesNotContain

								AND DeliveredOn NOT LIKE '%' + @DispatchDateVarchar + '%'

								)

							OR (

								@op8 = @StartsWith

								AND DeliveredOn LIKE '' + @DispatchDateVarchar + '%'

								)

							OR (

								@op8 = @EndsWith

								AND DeliveredOn LIKE '%' + @DispatchDateVarchar + ''

								)

							)

						OR (

							(

								@SecondOperator8 = @IsEqualTo

								AND DeliveredOn = @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsNotEqualTo

								AND DeliveredOn <> @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsLessThan

								AND DeliveredOn < @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsLessThanOrEqualTo

								AND DeliveredOn <= @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsGreaterThan

								AND DeliveredOn > @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsGreaterThanOrEqualTo

								AND DeliveredOn >= @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @Contains

								AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + '%'

								)

							OR (

								@SecondOperator8 = @DoesNotContain

								AND DeliveredOn NOT LIKE '%' + @SecondDispatchDate8Varchar + '%'

								)

							OR (

								@SecondOperator8 = @StartsWith

								AND DeliveredOn LIKE '' + @SecondDispatchDate8Varchar + '%'

								)

							OR (

								@SecondOperator8 = @EndsWith

								AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + ''

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

								AND DeliveredOn = @DispatchDate

								)

							OR (

								@op8 = @IsNotEqualTo

								AND DeliveredOn <> @DispatchDate

								)

							OR (

								@op8 = @IsLessThan

								AND DeliveredOn < @DispatchDate

								)

							OR (

								@op8 = @IsLessThanOrEqualTo

								AND DeliveredOn <= @DispatchDate

								)

							OR (

								@op8 = @IsGreaterThan

								AND DeliveredOn > @DispatchDate

								)

							OR (

								@op8 = @IsGreaterThanOrEqualTo

								AND DeliveredOn >= @DispatchDate

								)

							OR (

								@op8 = @Contains

								AND DeliveredOn LIKE '%' + @DispatchDateVarchar + '%'

								)

							OR (

								@op8 = @DoesNotContain

								AND DeliveredOn NOT LIKE '%' + @DispatchDateVarchar + '%'

								)

							OR (

								@op8 = @StartsWith

								AND DeliveredOn LIKE '' + @DispatchDateVarchar + '%'

								)

							OR (

								@op8 = @EndsWith

								AND DeliveredOn LIKE '%' + @DispatchDateVarchar + ''

								)

							)

						AND (

							(

								@SecondOperator8 = @IsEqualTo

								AND DeliveredOn = @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsNotEqualTo

								AND DeliveredOn <> @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsLessThan

								AND DeliveredOn < @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsLessThanOrEqualTo

								AND DeliveredOn <= @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsGreaterThan

								AND DeliveredOn > @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @IsGreaterThanOrEqualTo

								AND DeliveredOn >= @SecondDispatchDate8

								)

							OR (

								@SecondOperator8 = @Contains

								AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + '%'

								)

							OR (

								@SecondOperator8 = @DoesNotContain

								AND DeliveredOn NOT LIKE '%' + @SecondDispatchDate8Varchar + '%'

								)

							OR (

								@SecondOperator8 = @StartsWith

								AND DeliveredOn LIKE '' + @SecondDispatchDate8Varchar + '%'

								)

							OR (

								@SecondOperator8 = @EndsWith

								AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + ''

								)

							)

						)

					)



					---------

					OR (

                            @op8 = @IsEqualTo AND @SecondOperator8 IS NULL

                            AND DeliveredOn = @DispatchDate

                            )

                    OR (

                            @op8 = @IsNotEqualTo AND @SecondOperator8 IS NULL

                            AND DeliveredOn <> @DispatchDate

                            )

                    OR (

                            @op8 = @IsLessThan AND @SecondOperator8 IS NULL

                            AND DeliveredOn < @DispatchDate

                            )

                    OR (

                            @op8 = @IsLessThanOrEqualTo AND @SecondOperator8 IS NULL

                            AND DeliveredOn <= @DispatchDate

                            )

                    OR (

                            @op8 = @IsGreaterThan AND @SecondOperator8 IS NULL

                            AND DeliveredOn > @DispatchDate

                            )

                    OR (

                            @op8 = @IsGreaterThanOrEqualTo AND @SecondOperator8 IS NULL

                            AND DeliveredOn >= @DispatchDate

                            )

                    OR (

                            @op8 = @Contains AND @SecondOperator8 IS NULL

                            AND DeliveredOn LIKE '%' + @DispatchDateVarchar + '%'

                            )

                    OR (

                            @op8 = @DoesNotContain AND @SecondOperator8 IS NULL

                            AND DeliveredOn NOT LIKE '%' + @DispatchDateVarchar + '%'

                            )

                    OR (

                            @op8 = @StartsWith AND @SecondOperator8 IS NULL

                            AND DeliveredOn LIKE '' + @DispatchDateVarchar + '%'

                            )

                    OR (

                            @op8 = @EndsWith AND @SecondOperator8 IS NULL

                            AND DeliveredOn LIKE '%' + @DispatchDateVarchar + ''

                            )

                    )

					---------



			/*-------------Date Part - End ---------------*/



			AND (

				(@op9 IS NULL)

				OR (

					@op9 = @IsEqualTo

					AND SendBy = @SentBy

					)

				OR (

					@op9 = @IsNotEqualTo

					AND SendBy <> @SentBy

					)

				OR (

					@op9 = @IsLessThan

					AND SendBy < @SentBy

					)

				OR (

					@op9 = @IsLessThanOrEqualTo

					AND SendBy <= @SentBy

					)

				OR (

					@op9 = @IsGreaterThan

					AND SendBy > @SentBy

					)

				OR (

					@op9 = @IsGreaterThanOrEqualTo

					AND SendBy >= @SentBy

					)

				OR (

					@op9 = @Contains

					AND SendBy LIKE '%' + @SentBy + '%'

					)

				OR (

					@op9 = @DoesNotContain

					AND SendBy NOT LIKE '%' + @SentBy + '%'

					)

				OR (

					@op9 = @StartsWith

					AND SendBy LIKE '' + @SentBy + '%'

					)

				OR (

					@op9 = @EndsWith

					AND SendBy LIKE '%' + @SentBy + ''

					)

			)

			AND (

				(@op10 IS NULL)

				OR (

					@op10 = @IsEqualTo

					AND Reason = @Reason

					)

				OR (

					@op10 = @IsNotEqualTo

					AND Reason <> @Reason

					)

				OR (

					@op10 = @IsLessThan

					AND Reason < @Reason

					)

				OR (

					@op10 = @IsLessThanOrEqualTo

					AND Reason <= @Reason

					)

				OR (

					@op10 = @IsGreaterThan

					AND Reason > @Reason

					)

				OR (

					@op10 = @IsGreaterThanOrEqualTo

					AND Reason >= @Reason

					)

				OR (

					@op10 = @Contains

					AND Reason LIKE '%' + @Reason + '%'

					)

				OR (

					@op10 = @DoesNotContain

					AND Reason NOT LIKE '%' + @Reason + '%'

					)

				OR (

					@op10 = @StartsWith

					AND Reason LIKE '' + @Reason + '%'

					)

				OR (

					@op10 = @EndsWith

					AND Reason LIKE '%' + @Reason + ''

					)

			)

			AND (

				(@op11 IS NULL)

				OR (

					@op11 = @IsEqualTo

					AND Comments = @Comment

					)

				OR (

					@op11 = @IsNotEqualTo

					AND Comments <> @Comment

					)

				OR (

					@op11 = @IsLessThan

					AND Comments < @Comment

					)

				OR (

					@op11 = @IsLessThanOrEqualTo

					AND Comments <= @Comment

					)

				OR (

					@op11 = @IsGreaterThan

					AND Comments > @Comment

					)

				OR (

					@op11 = @IsGreaterThanOrEqualTo

					AND Comments >= @Comment

					)

				OR (

					@op11 = @Contains

					AND Comments LIKE '%' + @Comment + '%'

					)

				OR (

					@op11 = @DoesNotContain

					AND Comments NOT LIKE '%' + @Comment + '%'

					)

				OR (

					@op11 = @StartsWith

					AND Comments LIKE '' + @Comment + '%'

					)

				OR (

					@op11 = @EndsWith

					AND Comments LIKE '%' + @Comment + ''

					)

			)

	END


	SELECT 

		 [Id],

		 CountryOrderId,

		 Location,

		 GroupId,

		 HousewifeName,

		 TypeAssetName,

		 DeliveryContent,

		 [State],

		 Region,

		 CreationTimeStamp,

		 DeliveredOn,

		 SendBy,

		 Comments,

		 IndividualBussinesId,

		 IsLastState,

		 IsReadyToSend,

		 [Reason],

		 PickUpdate,
		 isnull(cast(nullif(FromHours, 0) as varchar(10)),'') as FromHours,
		 isnull(cast(nullif(ToHours, 0) as varchar(10)),'') as ToHours

	FROM #OrdersList

	WHERE 

	(

		(@op1 IS NULL)

		OR (

			@op1 = @IsEqualTo

			AND CountryOrderId = @Code

			)

		OR (

			@op1 = @IsNotEqualTo

			AND CountryOrderId <> @Code

			)

		OR (

			@op1 = @IsLessThan

			AND CountryOrderId < @Code

			)

		OR (

			@op1 = @IsLessThanOrEqualTo

			AND CountryOrderId <= @Code

			)

		OR (

			@op1 = @IsGreaterThan

			AND CountryOrderId > @Code

			)

		OR (

			@op1 = @IsGreaterThanOrEqualTo

			AND CountryOrderId >= @Code

			)

		--OR (

		--	@op1 = @Contains

		--	AND CountryOrderId LIKE '%' + @Code + '%'

		--	)

		--OR (

		--	@op1 = @DoesNotContain

		--	AND CountryOrderId NOT LIKE '%' + @Code + '%'

		--	)

		--OR (

		--	@op1 = @StartsWith

		--	AND CountryOrderId LIKE '' + @Code + '%'

		--	)

		--OR (

		--	@op1 = @EndsWith

		--	AND CountryOrderId LIKE '%' + @Code + ''

		--	)

		)

		AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND Location = @Location

					)

				OR (

					@op2 = @IsNotEqualTo

					AND Location <> @Location

					)

				OR (

					@op2 = @IsLessThan

					AND Location < @Location

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND Location <= @Location

					)

				OR (

					@op2 = @IsGreaterThan

					AND Location > @Location

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND Location >= @Location

					)

				OR (

					@op2 = @Contains

					AND Location LIKE '%' + @Location + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND Location NOT LIKE '%' + @Location + '%'

					)

				OR (

					@op2 = @StartsWith

					AND Location LIKE '' + @Location + '%'

					)

				OR (

					@op2 = @EndsWith

					AND Location LIKE '%' + @Location + ''

					)

			)

			AND (

				(@op3 IS NULL)

				OR (

					@op3 = @IsEqualTo

					AND TypeAssetName = @Type

					)

				OR (

					@op3 = @IsNotEqualTo

					AND TypeAssetName <> @Type

					)

				OR (

					@op3 = @IsLessThan

					AND TypeAssetName < @Type

					)

				OR (

					@op3 = @IsLessThanOrEqualTo

					AND TypeAssetName <= @Type

					)

				OR (

					@op3 = @IsGreaterThan

					AND TypeAssetName > @Type

					)

				OR (

					@op3 = @IsGreaterThanOrEqualTo

					AND TypeAssetName >= @Type

					)

				OR (

					@op3 = @Contains

					AND TypeAssetName LIKE '%' + @Type + '%'

					)

				OR (

					@op3 = @DoesNotContain

					AND TypeAssetName NOT LIKE '%' + @Type + '%'

					)

				OR (

					@op3 = @StartsWith

					AND TypeAssetName LIKE '' + @Type + '%'

					)

				OR (

					@op3 = @EndsWith

					AND TypeAssetName LIKE '%' + @Type + ''

					)

			)

			AND (

				(@op4 IS NULL)

				OR (

					@op4 = @IsEqualTo

					AND DeliveryContent = @DeliveryContent

					)

				OR (

					@op4 = @IsNotEqualTo

					AND DeliveryContent <> @DeliveryContent

					)

				OR (

					@op4 = @IsLessThan

					AND DeliveryContent < @DeliveryContent

					)

				OR (

					@op4 = @IsLessThanOrEqualTo

					AND DeliveryContent <= @DeliveryContent

					)

				OR (

					@op4 = @IsGreaterThan

					AND DeliveryContent > @DeliveryContent

					)

				OR (

					@op4 = @IsGreaterThanOrEqualTo

					AND DeliveryContent >= @DeliveryContent

					)

				OR (

					@op4 = @Contains

					AND DeliveryContent LIKE '%' + @DeliveryContent + '%'

					)

				OR (

					@op4 = @DoesNotContain

					AND DeliveryContent NOT LIKE '%' + @DeliveryContent + '%'

					)

				OR (

					@op4 = @StartsWith

					AND DeliveryContent LIKE '' + @DeliveryContent + '%'

					)

				OR (

					@op4 = @EndsWith

					AND DeliveryContent LIKE '%' + @DeliveryContent + ''

					)

			)

			AND (

				(@op5 IS NULL)

				OR (

					@op5 = @IsEqualTo

					AND [State] = @Status

					)

				OR (

					@op5 = @IsNotEqualTo

					AND [State] <> @Status

					)

				OR (

					@op5 = @IsLessThan

					AND [State] < @Status

					)

				OR (

					@op5 = @IsLessThanOrEqualTo

					AND [State] <= @Status

					)

				OR (

					@op5 = @IsGreaterThan

					AND [State] > @Status

					)

				OR (

					@op5 = @IsGreaterThanOrEqualTo

					AND [State] >= @Status

					)

				OR (

					@op5 = @Contains

					AND [State] LIKE '%' + @Status + '%'

					)

				OR (

					@op5 = @DoesNotContain

					AND [State] NOT LIKE '%' + @Status + '%'

					)

				OR (

					@op5 = @StartsWith

					AND [State] LIKE '' + @Status + '%'

					)

				OR (

					@op5 = @EndsWith

					AND [State] LIKE '%' + @Status + ''

					)

			)

			AND (

				(@op6 IS NULL)

				OR (

					@op6 = @IsEqualTo

					AND Region = @Region

					)

				OR (

					@op6 = @IsNotEqualTo

					AND Region <> @Region

					)

				OR (

					@op6 = @IsLessThan

					AND Region < @Region

					)

				OR (

					@op6 = @IsLessThanOrEqualTo

					AND Region <= @Region

					)

				OR (

					@op6 = @IsGreaterThan

					AND Region > @Region

					)

				OR (

					@op6 = @IsGreaterThanOrEqualTo

					AND Region >= @Region

					)

				OR (

					@op6 = @Contains

					AND Region LIKE '%' + @Region + '%'

					)

				OR (

					@op6 = @DoesNotContain

					AND Region NOT LIKE '%' + @Region + '%'

					)

				OR (

					@op6 = @StartsWith

					AND Region LIKE '' + @Region + '%'

					)

				OR (

					@op6 = @EndsWith

					AND Region LIKE '%' + @Region + ''

					)

			)



			/*-------------Date Part - Start -------------*/



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

                                            AND CreationTimeStamp = @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsNotEqualTo

                                            AND CreationTimeStamp <> @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsLessThan

                                            AND CreationTimeStamp < @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsLessThanOrEqualTo

                                            AND CreationTimeStamp <= @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsGreaterThan

                                            AND CreationTimeStamp > @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsGreaterThanOrEqualTo

                                            AND CreationTimeStamp >= @OrderedDate

                                            )

                                    OR (

                                            @op7 = @Contains

                                            AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + '%'

                            )

                                    OR (

                                            @op7 = @DoesNotContain

                                            AND CreationTimeStamp NOT LIKE '%' + @OrderedDateVarchar + '%'

                                            )

                                    OR (

                                            @op7 = @StartsWith

                                            AND CreationTimeStamp LIKE '' + @OrderedDateVarchar + '%'

                                            )

                                    OR (

                                            @op7 = @EndsWith

                                            AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + ''

                                            )

                                    )

                                OR (

                                    (

                                            @SecondOperator7 = @IsEqualTo

                                            AND CreationTimeStamp = @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsNotEqualTo

                                            AND CreationTimeStamp <> @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsLessThan

                                            AND CreationTimeStamp < @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsLessThanOrEqualTo

                                            AND CreationTimeStamp <= @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsGreaterThan

                                            AND CreationTimeStamp > @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsGreaterThanOrEqualTo

                                            AND CreationTimeStamp >= @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @Contains

                                            AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator7 = @DoesNotContain

                                            AND CreationTimeStamp NOT LIKE '%' + @SecondOrderedDate7Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator7 = @StartsWith

                                            AND CreationTimeStamp LIKE '' + @SecondOrderedDate7Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator7 = @EndsWith

                                            AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + ''

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

                                            AND CreationTimeStamp = @OrderedDate

      )

                                    OR (

                                            @op7 = @IsNotEqualTo

                                            AND CreationTimeStamp <> @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsLessThan

                                            AND CreationTimeStamp < @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsLessThanOrEqualTo

                                            AND CreationTimeStamp <= @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsGreaterThan

                                            AND CreationTimeStamp > @OrderedDate

                                            )

                                    OR (

                                            @op7 = @IsGreaterThanOrEqualTo

                                            AND CreationTimeStamp >= @OrderedDate

                                            )

                                    OR (

                                            @op7 = @Contains

                                            AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + '%'

                                            )

                                    OR (

                                            @op7 = @DoesNotContain

                                            AND CreationTimeStamp NOT LIKE '%' + @OrderedDateVarchar + '%'

                                            )

                                    OR (

                                            @op7 = @StartsWith

                                            AND CreationTimeStamp LIKE '' + @OrderedDateVarchar + '%'

                                            )

                                    OR (

                                            @op7 = @EndsWith

                                            AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + ''

                                            )

                                    )

                                AND (

                                    (

                                            @SecondOperator7 = @IsEqualTo

                                            AND CreationTimeStamp = @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsNotEqualTo

                                            AND CreationTimeStamp <> @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsLessThan

                                            AND CreationTimeStamp < @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsLessThanOrEqualTo

                                            AND CreationTimeStamp <= @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsGreaterThan

                                            AND CreationTimeStamp > @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @IsGreaterThanOrEqualTo

                                            AND CreationTimeStamp >= @SecondOrderedDate7

                                            )

                                    OR (

                                            @SecondOperator7 = @Contains

                              AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator7 = @DoesNotContain

                                            AND CreationTimeStamp NOT LIKE '%' + @SecondOrderedDate7Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator7 = @StartsWith

                                            AND CreationTimeStamp LIKE '' + @SecondOrderedDate7Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator7 = @EndsWith

                                            AND CreationTimeStamp LIKE '%' + @SecondOrderedDate7Varchar + ''

                                            )

                                    )

                                )

                        )

                OR (

                        @op7 = @IsEqualTo AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp = @OrderedDate

                        )

                OR (

                        @op7 = @IsNotEqualTo AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp <> @OrderedDate

                        )

                OR (

                        @op7 = @IsLessThan AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp < @OrderedDate

                        )

                OR (

                        @op7 = @IsLessThanOrEqualTo AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp <= @OrderedDate

                        )

                OR (

                        @op7 = @IsGreaterThan AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp > @OrderedDate

                        )

                OR (

                        @op7 = @IsGreaterThanOrEqualTo AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp >= @OrderedDate

                        )

                OR (

                        @op7 = @Contains AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + '%'

                        )

                OR (

                        @op7 = @DoesNotContain AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp NOT LIKE '%' + @OrderedDateVarchar + '%'

                        )

                OR (

                        @op7 = @StartsWith AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp LIKE '' + @OrderedDateVarchar + '%'

                        )

                OR (

                        @op7 = @EndsWith AND @SecondOperator7 IS NULL

                        AND CreationTimeStamp LIKE '%' + @OrderedDateVarchar + ''

                        )

                )



				--------



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

                                            AND DeliveredOn = @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsNotEqualTo

                                            AND DeliveredOn <> @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsLessThan

               AND DeliveredOn < @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsLessThanOrEqualTo

                                            AND DeliveredOn <= @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsGreaterThan

                                            AND DeliveredOn > @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsGreaterThanOrEqualTo

                                            AND DeliveredOn >= @DispatchDate

                                            )

                                    OR (

                                            @op8 = @Contains

                                            AND DeliveredOn LIKE '%' + @DispatchDateVarchar + '%'

                                            )

                                    OR (

                                            @op8 = @DoesNotContain

                                            AND DeliveredOn NOT LIKE '%' + @DispatchDateVarchar + '%'

                                            )

                                    OR (

                                            @op8 = @StartsWith

                                            AND DeliveredOn LIKE '' + @DispatchDateVarchar + '%'

                                            )

                                    OR (

                                            @op8 = @EndsWith

                                            AND DeliveredOn LIKE '%' + @DispatchDateVarchar + ''

                                            )

                                    )

                                OR (

                                    (

                                            @SecondOperator8 = @IsEqualTo

                                            AND DeliveredOn = @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsNotEqualTo

                                            AND DeliveredOn <> @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsLessThan

                                            AND DeliveredOn < @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsLessThanOrEqualTo

                                            AND DeliveredOn <= @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsGreaterThan

                                            AND DeliveredOn > @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsGreaterThanOrEqualTo

                                            AND DeliveredOn >= @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @Contains

                                            AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator8 = @DoesNotContain

                                            AND DeliveredOn NOT LIKE '%' + @SecondDispatchDate8Varchar + '%'

                                            )

 OR (

                                            @SecondOperator8 = @StartsWith

                                            AND DeliveredOn LIKE '' + @SecondDispatchDate8Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator8 = @EndsWith

                                            AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + ''

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

                                            AND DeliveredOn = @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsNotEqualTo

                                            AND DeliveredOn <> @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsLessThan

                                            AND DeliveredOn < @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsLessThanOrEqualTo

                                            AND DeliveredOn <= @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsGreaterThan

                                            AND DeliveredOn > @DispatchDate

                                            )

                                    OR (

                                            @op8 = @IsGreaterThanOrEqualTo

                                            AND DeliveredOn >= @DispatchDate

                                            )

                                    OR (

                                            @op8 = @Contains

                                            AND DeliveredOn LIKE '%' + @DispatchDateVarchar + '%'

                                            )

                                    OR (

                                            @op8 = @DoesNotContain

                                            AND DeliveredOn NOT LIKE '%' + @DispatchDateVarchar + '%'

                                            )

                                    OR (

                                            @op8 = @StartsWith

                                            AND DeliveredOn LIKE '' + @DispatchDateVarchar + '%'

                                            )

                                    OR (

                                            @op8 = @EndsWith

                                            AND DeliveredOn LIKE '%' + @DispatchDateVarchar + ''

                                            )

                                    )

                                AND (

                                    (

                                            @SecondOperator8 = @IsEqualTo

                                            AND DeliveredOn = @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsNotEqualTo

                                            AND DeliveredOn <> @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsLessThan

                                            AND DeliveredOn < @SecondDispatchDate8

                                            )

                  OR (

                                            @SecondOperator8 = @IsLessThanOrEqualTo

                                            AND DeliveredOn <= @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsGreaterThan

                                            AND DeliveredOn > @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @IsGreaterThanOrEqualTo

                                            AND DeliveredOn >= @SecondDispatchDate8

                                            )

                                    OR (

                                            @SecondOperator8 = @Contains

                                            AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator8 = @DoesNotContain

                                            AND DeliveredOn NOT LIKE '%' + @SecondDispatchDate8Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator8 = @StartsWith

                                            AND DeliveredOn LIKE '' + @SecondDispatchDate8Varchar + '%'

                                            )

                                    OR (

                                            @SecondOperator8 = @EndsWith

                                            AND DeliveredOn LIKE '%' + @SecondDispatchDate8Varchar + ''

                                            )

                                    )

                                )

                        )

                OR (

                        @op8 = @IsEqualTo AND @SecondOperator8 IS NULL

                        AND DeliveredOn = @DispatchDate

                        )

                OR (

                        @op8 = @IsNotEqualTo AND @SecondOperator8 IS NULL

                        AND DeliveredOn <> @DispatchDate

                        )

                OR (

                        @op8 = @IsLessThan AND @SecondOperator8 IS NULL

                        AND DeliveredOn < @DispatchDate

                        )

                OR (

                        @op8 = @IsLessThanOrEqualTo AND @SecondOperator8 IS NULL

                        AND DeliveredOn <= @DispatchDate

                        )

                OR (

                        @op8 = @IsGreaterThan AND @SecondOperator8 IS NULL

                        AND DeliveredOn > @DispatchDate

                        )

                OR (

                        @op8 = @IsGreaterThanOrEqualTo AND @SecondOperator8 IS NULL

                        AND DeliveredOn >= @DispatchDate

                        )

                OR (

                        @op8 = @Contains AND @SecondOperator8 IS NULL

                        AND DeliveredOn LIKE '%' + @DispatchDateVarchar + '%'

                        )

                OR (

                        @op8 = @DoesNotContain AND @SecondOperator8 IS NULL

                        AND DeliveredOn NOT LIKE '%' + @DispatchDateVarchar + '%'

                        )

                OR (

                        @op8 = @StartsWith AND @SecondOperator8 IS NULL

                        AND DeliveredOn LIKE '' + @DispatchDateVarchar + '%'

                        )

                OR (

                        @op8 = @EndsWith AND @SecondOperator8 IS NULL

                        AND DeliveredOn LIKE '%' + @DispatchDateVarchar + ''

                        )

                )



			/*-------------Date Part - End ---------------*/



			AND (

				(@op9 IS NULL)

				OR (

					@op9 = @IsEqualTo

					AND SendBy = @SentBy

					)

				OR (

					@op9 = @IsNotEqualTo

					AND SendBy <> @SentBy

					)

				OR (

					@op9 = @IsLessThan

					AND SendBy < @SentBy

					)

				OR (

					@op9 = @IsLessThanOrEqualTo

					AND SendBy <= @SentBy

					)

				OR (

					@op9 = @IsGreaterThan

					AND SendBy > @SentBy

					)

				OR (

					@op9 = @IsGreaterThanOrEqualTo

					AND SendBy >= @SentBy

					)

				OR (

					@op9 = @Contains

					AND SendBy LIKE '%' + @SentBy + '%'

					)

				OR (

					@op9 = @DoesNotContain

					AND SendBy NOT LIKE '%' + @SentBy + '%'

					)

				OR (

					@op9 = @StartsWith

					AND SendBy LIKE '' + @SentBy + '%'

					)

				OR (

					@op9 = @EndsWith

					AND SendBy LIKE '%' + @SentBy + ''

					)

			)

			AND (

				(@op10 IS NULL)

				OR (

					@op10 = @IsEqualTo

					AND Reason = @Reason

					)

				OR (

					@op10 = @IsNotEqualTo

					AND Reason <> @Reason

					)

				OR (

					@op10 = @IsLessThan

					AND Reason < @Reason

					)

				OR (

					@op10 = @IsLessThanOrEqualTo

					AND Reason <= @Reason

					)

				OR (

					@op10 = @IsGreaterThan

					AND Reason > @Reason

					)

				OR (

					@op10 = @IsGreaterThanOrEqualTo

					AND Reason >= @Reason

					)

				OR (

					@op10 = @Contains

					AND Reason LIKE '%' + @Reason + '%'

					)

				OR (

					@op10 = @DoesNotContain

					AND Reason NOT LIKE '%' + @Reason + '%'

					)

				OR (

					@op10 = @StartsWith

					AND Reason LIKE '' + @Reason + '%'

					)

				OR (

					@op10 = @EndsWith

					AND Reason LIKE '%' + @Reason + ''

					)

			)

			AND (

				(@op11 IS NULL)

				OR (

					@op11 = @IsEqualTo

					AND Comments = @Comment

					)

				OR (

					@op11 = @IsNotEqualTo

					AND Comments <> @Comment

					)

				OR (

					@op11 = @IsLessThan

					AND Comments < @Comment

					)

				OR (

					@op11 = @IsLessThanOrEqualTo

					AND Comments <= @Comment

					)

				OR (

					@op11 = @IsGreaterThan

					AND Comments > @Comment

					)

				OR (

					@op11 = @IsGreaterThanOrEqualTo

					AND Comments >= @Comment

					)

				OR (

					@op11 = @Contains

					AND Comments LIKE '%' + @Comment + '%'

					)

				OR (

					@op11 = @DoesNotContain

					AND Comments NOT LIKE '%' + @Comment + '%'

					)

				OR (

					@op11 = @StartsWith

					AND Comments LIKE '' + @Comment + '%'

					)

				OR (

					@op11 = @EndsWith

					AND Comments LIKE '%' + @Comment + ''

					)

			)
			
			AND ( 

			   (@op12 IS NULL)
			
			OR (

				@op12 = @IsEqualTo

				AND GroupId = @GroupId

				)

			OR (

				@op12 = @IsNotEqualTo

				AND GroupId <> @GroupId

				)

			OR (

				@op12 = @IsLessThan

				AND GroupId < @GroupId

				)

			OR (

				@op12 = @IsLessThanOrEqualTo

				AND GroupId <= @GroupId

				)

			OR (

				@op12 = @IsGreaterThan

				AND GroupId > @GroupId

				)

			OR (

				@op12 = @IsGreaterThanOrEqualTo

				AND GroupId >= @GroupId

				)

			OR (

				@op12 = @Contains

				AND GroupId LIKE '%' + @GroupId + '%'

				)

			OR (

				@op12 = @DoesNotContain

				AND GroupId NOT LIKE '%' + @GroupId + '%'

				)

			OR (

				@op12 = @StartsWith

				AND GroupId LIKE '' + @GroupId + '%'

				)

			OR (

				@op12 = @EndsWith

				AND GroupId LIKE '%' + @GroupId + ''

				)
			)

			AND (

				(@op13 IS NULL)

				OR (

					@op13 = @IsEqualTo

					AND HousewifeName = @HousewifeName

					)

				OR (

					@op13 = @IsNotEqualTo

					AND HousewifeName <> @HousewifeName

					)

				OR (

					@op13 = @IsLessThan

					AND HousewifeName < @HousewifeName

					)

				OR (

					@op13 = @IsLessThanOrEqualTo

					AND HousewifeName <= @HousewifeName

					)

				OR (

					@op13 = @IsGreaterThan

					AND HousewifeName > @HousewifeName

					)

				OR (

					@op13 = @IsGreaterThanOrEqualTo

					AND HousewifeName >= @HousewifeName

					)

				OR (

					@op13 = @Contains

					AND HousewifeName LIKE '%' + @HousewifeName + '%'

					)

				OR (

					@op13 = @DoesNotContain

					AND HousewifeName NOT LIKE '%' + @HousewifeName + '%'

					)

				OR (

					@op13 = @StartsWith

					AND HousewifeName LIKE '' + @HousewifeName + '%'

					)

				OR (

					@op13 = @EndsWith

					AND HousewifeName LIKE '%' + @HousewifeName + ''

					)

				)			


			ORDER BY CASE 

					WHEN @pOrderBy = 'CountryOrderId'

						AND @pOrderType = 'ASC'

						THEN CountryOrderId

					END ASC

				,CASE 

					WHEN @pOrderBy = 'CountryOrderId'

						AND @pOrderType = 'DESC'

						THEN CountryOrderId

					END DESC

				,CASE 

					WHEN @pOrderBy = 'Location'

						AND @pOrderType = 'ASC'

						THEN Location

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Location'

						AND @pOrderType = 'DESC'

						THEN Location

					END DESC

				,CASE 

					WHEN @pOrderBy = 'GroupId'

					AND @pOrderType = 'ASC'

					THEN GroupId

					END ASC
					
				,CASE 

					WHEN @pOrderBy = 'GroupId'

						AND @pOrderType = 'DESC'

						THEN GroupId

						END DESC
				,CASE 

					WHEN @pOrderBy = 'TypeAssetName'

						AND @pOrderType = 'ASC'

						THEN TypeAssetName

					END ASC

				,CASE 

					WHEN @pOrderBy = 'TypeAssetName'

						AND @pOrderType = 'DESC'

						THEN TypeAssetName

					END DESC

				,CASE 

					WHEN @pOrderBy = 'DeliveryContent'

						AND @pOrderType = 'ASC'

						THEN DeliveryContent

					END ASC

				,CASE 

					WHEN @pOrderBy = 'DeliveryContent'

						AND @pOrderType = 'DESC'

						THEN DeliveryContent

					END DESC

				,CASE 

					WHEN @pOrderBy = 'State'

						AND @pOrderType = 'ASC'

						THEN [State]

					END ASC

				,CASE 

					WHEN @pOrderBy = 'State'

						AND @pOrderType = 'DESC'

						THEN [State]

					END DESC

				,CASE 

					WHEN @pOrderBy = 'Region'

						AND @pOrderType = 'ASC'

						THEN Region

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Region'

						AND @pOrderType = 'DESC'

						THEN Region

					END DESC



				/********* Date Part - Start **********/



				,CASE 

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

					WHEN @pOrderBy = 'DeliveredOn'

						AND @pOrderType = 'ASC'

						THEN DeliveredOn

					END ASC

				,CASE 

					WHEN @pOrderBy = 'DeliveredOn'

						AND @pOrderType = 'DESC'

						THEN DeliveredOn

					END DESC 





			/********* Date Part - End **********/



				,CASE 

					WHEN @pOrderBy = 'SendBy'

						AND @pOrderType = 'ASC'

						THEN SendBy

					END ASC

				,CASE 

					WHEN @pOrderBy = 'SendBy'

						AND @pOrderType = 'DESC'

						THEN SendBy

					END DESC

				,CASE 

					WHEN @pOrderBy = 'Reason'

						AND @pOrderType = 'ASC'

						THEN [Reason]

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Reason'

						AND @pOrderType = 'DESC'

						THEN [Reason]

					END DESC

				,CASE 

					WHEN @pOrderBy = 'Comments'

						AND @pOrderType = 'ASC'

						THEN Comments

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Comments'

						AND @pOrderType = 'DESC'

						THEN Comments

					END DESC OFFSET @OFFSETRows ROWS



			FETCH NEXT @pPageSize ROWS ONLY

			OPTION (RECOMPILE)

END


