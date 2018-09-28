CREATE  PROCEDURE [dbo].[GetSelectedPanelCardLeftContent] @pPanelistId UNIQUEIDENTIFIER

	,@pScopeReferenceId UNIQUEIDENTIFIER

	,@pCountryId UNIQUEIDENTIFIER

	,@pCultureCode INT

	,@pIsAdmin BIT

AS

BEGIN
BEGIN TRY

	DECLARE @PnlId UNIQUEIDENTIFIER

	DECLARE @Scope VARCHAR(50)

	DECLARE @belongcount INT = 0

	DECLARE @candidateGuid UNIQUEIDENTIFIER

	DECLARE @businessId NVARCHAR(100)

	DECLARE @CMId UNIQUEIDENTIFIER

	DECLARE @ExpectedKitId UNIQUEIDENTIFIER

	DECLARE @StateId UNIQUEIDENTIFIER

	DECLARE @PnlMemberId UNIQUEIDENTIFIER

	DECLARE @PnlCreatedDate DATETIME

	DECLARE @PnlName VARCHAR(100)

	DECLARE @CalendarPeriod NVARCHAR(100)

	DECLARE @IncentiveLevelId UNIQUEIDENTIFIER

	DECLARE @IncentiveLevelDescription NVARCHAR(100)

	DECLARE @PetrolLink NVARCHAR(100)
	DECLARE @PetrolMaintenanceLink NVARCHAR(100)
	DECLARE @PurchaseLink NVARCHAR(100)

	DECLARE @TeenDemo NVARCHAR(50)
	DECLARE @TeenDemoValue NVARCHAR(50)
	DECLARE @TeenDemoValueKey NVARCHAR(50)

	DECLARE @CounsumerPusleLink NVARCHAR(200)
	DECLARE @TillReceiptLink NVARCHAR(200)

	DECLARE @ShopAndScanLink NVARCHAR(200)



	

	SELECT @pnlId = PL.Panel_Id

		,@Scope = P.[Type]

		,@CMId = pl.CollaborationMethodology_Id

		,@ExpectedKitId = pl.ExpectedKit_Id

		,@StateId = pl.State_Id

		,@PnlName = p.[Name]

		,@PnlMemberId = pl.PanelMember_Id

		,@PnlCreatedDate = pl.CreationDate

		,@IncentiveLevelId = IL.GUIDReference

		,@IncentiveLevelDescription = IL.[Description]

	FROM Panelist PL

	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id

	LEFT JOIN IncentiveLevel IL ON IL.GUIDReference = PL.IncentiveLevel_Id

	WHERE PL.GUIDReference = @pPanelistId


	SELECT @PetrolLink = PetrolLinkValue.Value, @PetrolMaintenanceLink = PetrolMaintenanceValue.Value
	FROM KeyAppSetting PetrolKey
	JOIN KeyValueAppSetting PetrolValue ON PetrolValue.KeyAppSetting_Id = PetrolKey.GUIDReference AND Country_Id = @pCountryId
	LEFT JOIN KeyAppSetting PetrolLinkKey ON PetrolLinkKey.KeyName = 'PetrolLink'
	LEFT JOIN KeyValueAppSetting PetrolLinkValue ON PetrolLinkValue.KeyAppSetting_Id = PetrolLinkKey.GUIDReference AND PetrolLinkValue.Country_Id = @pCountryId
	LEFT JOIN KeyAppSetting PetrolMaintenanceKey ON PetrolMaintenanceKey.KeyName = 'PetrolMaintenanceLink'
	LEFT JOIN KeyValueAppSetting PetrolMaintenanceValue ON PetrolMaintenanceValue.KeyAppSetting_Id = PetrolMaintenanceKey.GUIDReference AND PetrolMaintenanceValue.Country_Id = @pCountryId
	WHERE PetrolKey.KeyName = 'PanelCodeForPetrolLink' AND PetrolValue.Value = @PnlName

	SELECT @CounsumerPusleLink = ConsumerPulseLinkValue.Value
	FROM KeyAppSetting ConsumerPulseKey
	JOIN KeyValueAppSetting ConsumerPulseValue ON ConsumerPulseValue.KeyAppSetting_Id = ConsumerPulseKey.GUIDReference AND Country_Id = @pCountryId
	LEFT JOIN KeyAppSetting ConsumerPulseLinkKey ON ConsumerPulseLinkKey.KeyName = 'ConsumerPulseLink'
	LEFT JOIN KeyValueAppSetting ConsumerPulseLinkValue ON ConsumerPulseLinkValue.KeyAppSetting_Id = ConsumerPulseLinkKey.GUIDReference AND ConsumerPulseLinkValue.Country_Id = @pCountryId
	WHERE ConsumerPulseKey.KeyName = 'PanelCodeForTeenAccount' AND ConsumerPulseValue.Value = @PnlName

	SELECT @TillReceiptLink = ConsumerPulseLinkValue.Value
	FROM KeyAppSetting ConsumerPulseKey
	JOIN KeyValueAppSetting ConsumerPulseValue ON ConsumerPulseValue.KeyAppSetting_Id = ConsumerPulseKey.GUIDReference AND Country_Id = @pCountryId
	LEFT JOIN KeyAppSetting ConsumerPulseLinkKey ON ConsumerPulseLinkKey.KeyName = 'TillReceiptLink'
	LEFT JOIN KeyValueAppSetting ConsumerPulseLinkValue ON ConsumerPulseLinkValue.KeyAppSetting_Id = ConsumerPulseLinkKey.GUIDReference AND ConsumerPulseLinkValue.Country_Id = @pCountryId
	WHERE ConsumerPulseKey.KeyName = 'PanelCodeForTillReceipt' AND ConsumerPulseValue.Value = @PnlName 

	SELECT @PurchaseLink = PurchaseLinkValue.Value
	FROM KeyAppSetting PurchaseKey
	JOIN KeyValueAppSetting PurchaseValue ON PurchaseValue.KeyAppSetting_Id = PurchaseKey.GUIDReference AND Country_Id = @pCountryId
	LEFT JOIN KeyAppSetting PurchaseLinkKey ON PurchaseLinkKey.KeyName = 'PurchaseLink'
	LEFT JOIN KeyValueAppSetting PurchaseLinkValue ON PurchaseLinkValue.KeyAppSetting_Id = PurchaseLinkKey.GUIDReference AND PurchaseLinkValue.Country_Id = @pCountryId
	WHERE PurchaseKey.KeyName = 'PanelCodeForPurchaseLink' AND PurchaseValue.Value = @PnlName

	
	SELECT @ShopAndScanLink = ShopAndScanLinkValue.Value
	FROM KeyAppSetting ShopAndScanKey
	JOIN KeyValueAppSetting ShopAndScanValue ON ShopAndScanValue.KeyAppSetting_Id = ShopAndScanKey.GUIDReference AND Country_Id = @pCountryId
	LEFT JOIN KeyAppSetting ShopAndScanLinkKey ON ShopAndScanLinkKey.KeyName = 'ShopAndScanLinkUrl'
	LEFT JOIN KeyValueAppSetting ShopAndScanLinkValue ON ShopAndScanLinkValue.KeyAppSetting_Id = ShopAndScanLinkKey.GUIDReference AND ShopAndScanLinkValue.Country_Id = @pCountryId
	WHERE ShopAndScanKey.KeyName = 'ShopAndScanForPurchaseLink' AND ShopAndScanValue.Value = @PnlName

	SELECT @candidateGuid = GUIDReference

		,@businessId = IndividualId

	FROM Individual

	WHERE GUIDReference = @pScopeReferenceId

	SELECT @TeenDemo = TTK.Value, @TeenDemoValueKey = TT.KeyName, @TeenDemoValue = TTV.Value
	FROM Country CN
	JOIN KeyAppSetting KAS ON KAS.KeyName = 'PanelCodeForTeenAccount'
	JOIN KeyValueAppSetting KVAS ON KVAS.KeyAppSetting_Id = KAS.GUIDReference AND KVAS.Country_Id = CN.CountryId
	JOIN CountryConfiguration CC ON CN.Configuration_Id = CC.Id
	JOIN Attribute TeenDemo ON CC.TeenAccountAttributeId = TeenDemo.GUIDReference
	JOIN EnumDefinition EnumDef ON EnumDef.Demographic_Id = TeenDemo.GUIDReference
	JOIN TranslationTerm TTK ON TTK.Translation_Id = TeenDemo.Translation_Id AND TTK.CultureCode = @pCultureCode
	LEFT JOIN Individual i ON i.GUIDReference=@candidateGuid
	LEFT JOIN AttributeValue TeenDemoValue ON TeenDemoValue.DemographicId = TeenDemo.GUIDReference AND TeenDemoValue.CandidateId = @candidateGuid
	--LEFT JOIN EnumAttributeValue EnumValue ON EnumValue.GUIDReference = TeenDemoValue.GUIDReference
	LEFT JOIN Translation TT ON TT.TranslationId = EnumDef.Translation_Id
	LEFT JOIN TranslationTerm TTV ON TTV.Translation_Id = TT.TranslationId AND TTV.CultureCode = @pCultureCode
	WHERE KVAS.Value = @PnlName AND CN.CountryId = @pCountryId AND (
		(TeenDemoValue.GUIDReference IS NOT NULL AND EnumDef.Id = TeenDemoValue.EnumDefinition_Id) OR
		(TeenDemoValue.GUIDReference IS NULL AND EnumDef.Value = 1) /* DEFAULT VALUE */
	) AND (ISNULL(i.IsAnonymized, 0) = 0 OR TeenDemo.MustAnonymize=0)



	DECLARE @isIndividual BIT = 0



	/*IndividualMembershipDtos*/

	DECLARE @ShowCalendarFormatDates BIT

		,@CurrentDevicesCount INT

		,@CollaborationMethodologyName NVARCHAR(100)

		,@LastMethodologyDate DATETIME



	SELECT @ShowCalendarFormatDates = CC.ShowCalendarFormatDates

	FROM CountryConfiguration CC

	INNER JOIN [ConfigurationSet] CS ON CS.PanelManagementCountryConfiguration_Id = CC.Id

	WHERE CS.PanelId = @pnlId



	SELECT @CurrentDevicesCount = COUNT(st.GUIDReference)

	FROM StockItem st

	LEFT JOIN StockLocation b ON st.Location_Id = b.GUIDReference

	LEFT JOIN StockPanelistLocation A ON A.GUIDReference = b.GUIDReference

	INNER JOIN StockType STY ON st.Type_Id = STY.GUIDReference

	INNER JOIN StockBehavior sb ON sb.GUIDReference = sty.Behavior_Id

	INNER JOIN StateDefinition sd ON st.State_Id = sd.Id

	WHERE (st.Panelist_Id = @pPanelistId OR A.Panelist_Id = @pPanelistId)

		AND sb.IsTrackable = 1 AND sd.Code NOT IN ('AssetLost', 'AssetScrapped', 'AssetReturned')



	SELECT @CollaborationMethodologyName = dbo.GetTranslationValue(CM.TranslationId, @pCultureCode)

	FROM CollaborationMethodology CM

	WHERE CM.GUIDReference = @CMId



	SELECT TOP 1 @LastMethodologyDate = CLH.[Date]

	FROM CollaborationMethodologyHistory CLH

	WHERE CLH.Panelist_Id = @pPanelistId

	ORDER BY CLH.Date DESC



	DECLARE @MainContact UNIQUEIDENTIFIER

		--,@IncentiveLevelId UNIQUEIDENTIFIER

		--,@IncentiveLevelDescription NVARCHAR(100)



	SELECT @MainContact = DRA.Candidate_Id

	FROM DynamicRoleAssignment DRA

	INNER JOIN DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id

	WHERE DRA.Panelist_Id = @pPanelistId

		AND dr.Code = 3



	--SELECT @IncentiveLevelId = IL.GUIDReference

	--	,@IncentiveLevelDescription = [Description]

	--FROM IncentiveLevel IL

	--WHERE IL.Panel_Id = @pnlId

	--	AND Code = 3



SELECT @CalendarPeriod=[dbo].[GetPanelCalendarPeriod](@pCountryId, @pnlId,@PnlCreatedDate) --4



	SELECT @pPanelistId AS Id

		,@businessId AS BusinessId

		,@pScopeReferenceId AS IndividualId

		,@PnlMemberId AS CandidateId

		,@pnlId AS PanelId

		,@Scope AS PanelType

		,@PnlName AS PanelName

		,@PnlCreatedDate AS SignUpDate

		,@CalendarPeriod AS CalendarSignUpDate

		,@MainContact AS MainContact

		,@belongcount AS BelongingQuantity

		,@IncentiveLevelId AS IncentiveLevelId

		,@IncentiveLevelDescription AS IncentiveLevelDescription

		,@CurrentDevicesCount AS CurrentDevicesCount

		,@CollaborationMethodologyName AS CollaborationMethodologyName

		,@LastMethodologyDate AS LastMethodologyDate

		,@ShowCalendarFormatDates AS ShowCalendarFormatDates

		,@PetrolLink AS PetrolLink

		,@PetrolMaintenanceLink AS PetrolMaintenanceLink

		,@PurchaseLink AS PurchaseLink

		,@TeenDemo AS TeenDemoLabel

		,@TeenDemoValue AS TeenDemoValue,

		@TeenDemoValueKey AS TeenDemoValueKey,
		@CounsumerPusleLink AS ConsumerPulseLink
		,@TillReceiptLink AS TillReceiptLink
		,@ShopAndScanLink AS ShopAndScanLink



	SELECT dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS NAME

		,sd.Code AS [Key]

		,sd.Id AS NextStepId

		,sd.TrafficLightBehavior AS DisplayBehavior

	FROM StateDefinition sd

	WHERE sd.Id = @StateId



	/*StateDefinitionHistory*/
			DECLARE  @StateDefinitionChangeDate DATETIME
	SET @StateDefinitionChangeDate=(Select top 1 CreationDate from StateDefinitionHistory where Candidate_Id =@pScopeReferenceId ORDER BY  CreationDate desc)
	SELECT SDH.GUIDReference

		,SDH.GPSUser

		,SDH.CreationDate

		,SDH.GPSUpdateTimestamp

		,SDH.CreationTimeStamp

		,Comments

		,CollaborateInFuture

		,From_Id

		,To_Id

		,ReasonForchangeState_Id

		,SDH.Country_Id

		,Candidate_Id

		,GroupMembership_Id

		,Belonging_Id

		,Panelist_Id

		,Order_Id

		,Order_Country_Id

		,Package_Id

		,ImportFile_Id

		,ImportFilePendingRecord_Id

		,Action_Id

		,dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS OldStatus

		,To_Id AS NewStatusId

		,dbo.GetTranslationValue(SDTo.Label_Id, @pCultureCode) AS NewStatus

		,RCS.Code AS ReasonForChangeStateCode

		,dbo.GetTranslationValue(RCS.Description_Id, @pCultureCode) AS ReasonForChangeStateDescription
		,SDH.CreationDate AS ChangedDate

		,(SELECT [dbo].[GetPanelCalendarPeriod](@pCountryId, @pnlId,SDH.CreationDate)) AS CalendarChangedDate

	FROM StateDefinitionHistory SDH

	INNER JOIN StateDefinition SD ON SD.Id = SDH.From_Id

	INNER JOIN StateDefinition SDTo ON SDTo.Id = SDH.To_Id

	LEFT JOIN ReasonForChangeState RCS ON RCS.Id = SDH.ReasonForchangeState_Id

	WHERE SDH.Panelist_Id = @pPanelistId AND (SD.Code LIKE 'Panelist%' OR SDTo.Code LIKE 'Panelist%')

	ORDER BY SDH.GPSUpdateTimestamp DESC

		DECLARE @IsFieldRequired BIT=0

	SELECT (

			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'PurchaseCountHistory', 0)

			) AS IsCountryVisible



	EXEC GetKeyValueAppSetting 'PurchaseHistoryReport'

		,@pCountryId



	declare @keyId as int

declare @keyPanel as uniqueidentifier

set @keyId=(	SELECT (

			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'ShowPanellisttripInfoUrl', 1)

			))

if(@keyId=1)

begin

set @keyPanel= (SELECT P.GUIDReference FROM KeyAppSetting KS

JOIN KeyValueAppSetting KVA ON KS.GUIDReference=KVA.KeyAppSetting_Id

JOIN Panel P ON P.Name=KVA.Value

WHERE KS.KeyName='GroceriesPael'

AND KVA.Country_Id=@pCountryId)

		end

		if(@pnlId=@keyPanel)

		begin

		SET @IsFieldRequired=1

		select @IsFieldRequired AS IsPanelistTripInfoUrlVisible 

		end

		else

			begin

			SET @IsFieldRequired=0

select @IsFieldRequired AS IsPanelistTripInfoUrlVisible 

	

		end
		SELECT (

			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'DiaryHistory', 0)

			) AS IsDiaryHistoryVisible


------------------------------------------------------
	declare @panelcode nvarchar(600)

	       declare @keyPolldateDevicesId as int

          declare @keyPolldateDevicesvalue as nvarchar(600)
		  	DECLARE @IsLastPollDaterequired BIT=0

set @keyPolldateDevicesId=(	SELECT (

			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'LastPolldateDevicesCheck', 1)

			))

if(@keyPolldateDevicesId=1)

begin

set @keyPolldateDevicesvalue= (SELECT KVA.Value FROM KeyAppSetting KS

JOIN KeyValueAppSetting KVA ON KS.GUIDReference=KVA.KeyAppSetting_Id

WHERE KS.KeyName='LastpollingDateDevices'

AND KVA.Country_Id=@pCountryId)
 set @panelcode=(select PanelCode from Panel where GUIDReference=@pnlId and country_Id=@pCountryId)
 print @keyPolldateDevicesvalue
 print @panelcode
if(@keyPolldateDevicesvalue=@panelcode)

		begin

		IF(@Scope='HouseHold')
		BEGIN
			SET @IsLastPollDaterequired=1
		END
		ELSE 
		SET @IsLastPollDaterequired=0

		select @IsLastPollDaterequired AS CheckLastPollingDateVisible 

		end

		else

			begin

			SET @IsLastPollDaterequired=0

select @IsLastPollDaterequired AS CheckLastPollingDateVisible 

	

		end


		end
		else
		begin
		IF(@Scope='HouseHold')
		BEGIN
			SET @IsLastPollDaterequired=1
		END
		ELSE 
		SET @IsLastPollDaterequired=0

select @IsLastPollDaterequired AS CheckLastPollingDateVisible 
		end
		SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsPanelistCollabarationHistoryAndTaskHistoryBtnVisible', 0)

			) AS IsPanelistCollabarationHistoryAndTaskHistoryBtnVisible


	SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsTaskVisible', 0)



			) AS IsTaskVisible
			
	SELECT (



			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsSelectedPanelCardCollaborationRequired', 0)



			) AS IsPanelCardCollaborationRequired

				SELECT (



			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsIncentiveLevel', 0)



			) AS IsIncentiveLevelVisible

			SELECT (



			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'ShopAndScanIsVisible', 0)



			) AS ShopAndScanIsVisible

			END TRY
			BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH 
END
