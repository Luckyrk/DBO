/*##########################################################################

-- Name             : GetSelectedPanelCard.sql
-- Date             : 2014-10-10
-- Author           : Teena Areti
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure is used to get the PanelCard Information
-- Usage            :
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
				@pPanelistId UNIQUEIDENTIFIER  --  GUID of Panelist
				,@pScopeReferenceId UNIQUEIDENTIFIER -- GUID of Individual
				,@pCountryId UNIQUEIDENTIFIER  --Guid of Country
				,@pCultureCode INT -- CultureCode
				,@pIsAdmin BIT  -- To determinine if user is admin
      
-- Sample Execution :

 EXEC [GetSelectedPanelCard] '393a4058-de6c-49cd-8452-dfb2a9826cdb', 'e5ea84a2-d43b-4660-846a-7d81fdec1d75','3558a18e-cceb-cadc-cb8c-08cf81794a86',1028,1

##########################################################################
-- ver  user               date        change 
-- 1.0  Teena Areti     2014-10-10		initial
-- 1.1  Ramana		    2014-11-25
-- 1.2  Teena Areti		2014-11-27		Altered logic for fetching dynamicroles
-- 1.3  Ramana          2014-12-03      
-- 1.4  Ramana,Durga,Gopi 2015-01-04     Removed the @plRefusalState  logic     
##########################################################################*/
CREATE PROCEDURE [dbo].[GetSelectedPanelCard] @pPanelistId UNIQUEIDENTIFIER
	,@pScopeReferenceId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pIsAdmin BIT
AS
BEGIN
BEGIN TRY
	DECLARE @PnlId UNIQUEIDENTIFIER
	DECLARE @Scope NVARCHAR(50)
	DECLARE @belongcount INT = 0
	DECLARE @candidateGuid UNIQUEIDENTIFIER
	DECLARE @businessId NVARCHAR(100)
	DECLARE @CMId UNIQUEIDENTIFIER
	DECLARE @ExpectedKitId UNIQUEIDENTIFIER
	DECLARE @StateId UNIQUEIDENTIFIER
	DECLARE @DefGUID UNIQUEIDENTIFIER
	DECLARE @PnlMemberId UNIQUEIDENTIFIER
	DECLARE @PnlCreatedDate DATETIME
	DECLARE @PnlName NVARCHAR(100)
	DECLARE @CalendarPeriod NVARCHAR(100)
	DECLARE @IncentiveLevelId UNIQUEIDENTIFIER
	DECLARE @IncentiveLevelDescription NVARCHAR(100)

	SET @DefGUID = '00000000-0000-0000-0000-000000000000'

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

	SELECT @candidateGuid = GUIDReference
		,@businessId = IndividualId
	FROM Individual
	WHERE GUIDReference = @pScopeReferenceId

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
	INNER JOIN StockLocation b ON st.Location_Id = b.GUIDReference
	LEFT JOIN StockPanelistLocation A ON A.GUIDReference = b.GUIDReference
	INNER JOIN StockType STY ON st.Type_Id = STY.GUIDReference
	INNER JOIN StockBehavior sb ON sb.GUIDReference = sty.Behavior_Id
	WHERE (	A.Panelist_Id = @pPanelistId
		OR st.Panelist_Id = @pPanelistId ) 
		AND sb.IsTrackable = 1

	SELECT @CollaborationMethodologyName = dbo.GetTranslationValue(CM.TranslationId, @pCultureCode)
	FROM CollaborationMethodology CM
	WHERE CM.GUIDReference = @CMId

	SELECT TOP 1 @LastMethodologyDate = CLH.[Date]
	FROM CollaborationMethodologyHistory CLH
	WHERE CLH.Panelist_Id = @pPanelistId
	ORDER BY CLH.DATE DESC

	DECLARE @MainContact UNIQUEIDENTIFIER

	SELECT @MainContact = DRA.Candidate_Id
	FROM DynamicRoleAssignment DRA
	INNER JOIN DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id
	WHERE DRA.Candidate_Id = @candidateGuid
		AND dr.Code = 3

	SELECT @CalendarPeriod = [dbo].[GetPanelCalendarPeriod](@pCountryId, @pnlId, @PnlCreatedDate) --4

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

	--IndividualMembershipTabContentDto
	SELECT I2.GUIDReference AS Id
		,I.IndividualId AS BusinessId
		,PIdentity.PersonalIdentificationId AS [PersonalIdentificationId]
		,PIdentity.DateOfBirth AS [DateOfBirth]
		,PIdentity.LastOrderedName AS [LastName]
		,PIdentity.MiddleOrderedName AS MiddleName
		,PIdentity.FirstOrderedName AS [FirstName]
		,IT.Code AS Code
		,dbo.[GetTranslationValue](IT.Translation_Id, @pCultureCode) AS NAME
		,INS.Code AS SexCode
		,dbo.[GetTranslationValue](INS.Translation_Id, @pCultureCode) AS SexName
	FROM Individual I
	INNER JOIN Collective C ON C.GroupContact_Id = I.GUIDReference
	INNER JOIN CollectiveMembership CM ON CM.Group_Id = C.GUIDReference
	INNER JOIN StateDefinition SD ON SD.Id = CM.State_Id
	INNER JOIN Individual I2 ON I2.GUIDReference = CM.Individual_Id
	INNER JOIN PersonalIdentification PIdentity ON PIdentity.PersonalIdentificationId = i2.PersonalIdentificationId
	INNER JOIN IndividualTitle IT ON IT.GUIDReference = PIdentity.TitleId
	INNER JOIN IndividualSex INS ON INS.GUIDReference = IT.Sex_Id
	WHERE @PnlMemberId = (
			CASE 
				WHEN @Scope = 'Individual'
					THEN @PnlMemberId
				ELSE CM.Group_Id
				END
			)
		AND @pScopeReferenceId = (
			CASE 
				WHEN @Scope = 'Individual'
					THEN CM.Individual_Id
				ELSE @pScopeReferenceId
				END
			)
		AND SD.InactiveBehavior = 0
		AND SD.Code <> 'GroupMembershipNonResident'

	SELECT dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS NAME
		,sd.Code AS [Key]
		,sd.Id AS NextStepId
		,sd.Id AS CurrentStateId
		,sd.TrafficLightBehavior AS DisplayBehavior
	FROM StateDefinition sd
	WHERE sd.Id = @StateId

	--StateChangeTransitionDTO
	SELECT st.ToState_Id AS StateToId
		,dbo.GetTranslationValue(sd2.Label_Id, @pCultureCode) AS StateToName
	FROM Panelist pl
	INNER JOIN StateDefinition sd ON sd.Id = pl.State_Id
	INNER JOIN StateDefinitionsTransitions sdt ON sd.Id = sdt.StateDefinition_Id
	INNER JOIN StateTransition st ON sdt.AvailableTransition_Id = st.Id
	INNER JOIN StateDefinition Sd2 ON Sd2.Id = St.ToState_Id
	WHERE pl.GUIDReference = @PPANELISTID
		AND st.IsAdmin <> (
			CASE 
				WHEN ISNULL(@pIsAdmin, 0) = 0
					THEN 1
				ELSE 2
				END
			)

	--PanelAliasContext
	DECLARE @mytable TABLE (
		Id UNIQUEIDENTIFIER
		,NAME NVARCHAR(100)
		)

	INSERT INTO @mytable (
		Id
		,NAME
		)
	SELECT NAC.NamedAliasContextId AS Id
		,NAC.NAME AS NAME
	FROM NamedAliasContext NAC
	WHERE NAC.Panel_Id = @pnlId

	SELECT *
	FROM @mytable

	--select NamedAliasId
	SELECT NA.NamedAliasId AS Id
		,NA.[Key] AS [Key]
		,NA.AliasContext_Id AS AliasContextId
	FROM NamedAlias NA
	INNER JOIN @mytable myt ON NA.AliasContext_Id = myt.Id

	/*StateDefinitionHistory*/
	DECLARE @StateDefinitionChangeDate DATETIME

	SET @StateDefinitionChangeDate = (
			SELECT TOP 1 CreationDate
			FROM StateDefinitionHistory SDH
			INNER JOIN StateDefinition SD ON SD.Id = SDH.From_Id
			INNER JOIN StateDefinition SDTo ON SDTo.Id = SDH.To_Id
			--WHERE Candidate_Id = @pScopeReferenceId
			--ORDER BY CreationDate DESC
			where SDH.Panelist_Id = @pPanelistId
			AND (
				SD.Code LIKE 'Panelist%'
				OR SDTo.Code LIKE 'Panelist%'
				)
			ORDER BY SDH.CreationDate DESC
			)

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
		,(
			SELECT [dbo].[GetPanelCalendarPeriod](@pCountryId, @pnlId, SDH.CreationDate)
			) AS CalendarChangedDate
	FROM StateDefinitionHistory SDH
	INNER JOIN StateDefinition SD ON SD.Id = SDH.From_Id
	INNER JOIN StateDefinition SDTo ON SDTo.Id = SDH.To_Id
	INNER JOIN StateModel SM ON SD.StateModel_Id = SM.GUIDReference AND SM.[Type] = 'Domain.PanelManagement.Candidates.Panelist'
	LEFT JOIN ReasonForChangeState RCS ON RCS.Id = SDH.ReasonForchangeState_Id
	WHERE SDH.Panelist_Id = @pPanelistId
	ORDER BY SDH.CreationDate DESC

	/*Incentive levels*/
	SELECT GUIDReference AS Id
		,[Description]
	FROM IncentiveLevel IL
	WHERE Panel_Id = @pnlid

	SELECT DISTINCT St.GUIDReference AS Id
		,st.Code AS Code
		,st.NAME AS NAME
		,c.GUIDReference
		,indv.IndividualId AS MainContact
	FROM Panelist PL
	INNER JOIN StockKit ST ON PL.ExpectedKit_Id = ST.GUIDReference
	INNER JOIN StockKitItem SI ON ST.GUIDReference = SI.StockKit_Id
	INNER JOIN DynamicRoleAssignment DRA ON DRA.Panelist_Id = pl.GUIDReference
	INNER JOIN DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id
	INNER JOIN Candidate c ON C.GUIDReference = DRA.Candidate_Id
	INNER JOIN Individual indv ON indv.GUIDReference = c.GUIDReference
	WHERE PL.GUIDReference = @pPanelistId
		AND dr.Code = 3

	/*Stock Items*/
	DECLARE @ConectivityAttributeId UNIQUEIDENTIFIER
	DECLARE @SoftwareVersionAttributeId UNIQUEIDENTIFIER
	DECLARE @ModelAttributeId UNIQUEIDENTIFIER
	DECLARE @PhotoAttributeId UNIQUEIDENTIFIER

	SELECT @ConectivityAttributeId = at.GUIDReference
	FROM Attribute at
	WHERE at.Country_Id = @pCountryId
		AND at.[Key] = 'Connectivity'

	SELECT @SoftwareVersionAttributeId = at.GUIDReference
	FROM Attribute at
	WHERE at.Country_Id = @pCountryId
		AND at.[Key] = 'SoftwareVersion'

	SELECT TOP 1 @ModelAttributeId = at.GUIDReference
	FROM Attribute at
	INNER JOIN Translation t ON at.Translation_Id = t.TranslationId
	LEFT JOIN TranslationTerm tt ON t.TranslationId = tt.Translation_Id
		AND tt.CultureCode = @pCultureCode
	WHERE tt.Value = 'Model'
		AND at.Country_Id = @pCountryId

	SELECT TOP 1 @PhotoAttributeId = at.GUIDReference
	FROM Attribute at
	INNER JOIN Translation t ON at.Translation_Id = t.TranslationId
	LEFT JOIN TranslationTerm tt ON t.TranslationId = tt.Translation_Id
		AND tt.CultureCode = @pCultureCode
	WHERE tt.Value = 'Photo'
		AND at.Country_Id = @pCountryId

	SELECT t1.Id AS Id
		,AssetCategoryName
		,AssetTypeName
		,AssetConectivity
		,AssetModel
		,AssetPhoto
		,AssetSoftwareVersion
		,AssetCategoryCode
		,IsTrackeable
	FROM (
		SELECT DISTINCT sitems.GUIDReference AS Id
			,[dbo].[GetTranslationValue](sc.Translation_Id, @pCultureCode) AS AssetCategoryName
			,st.NAME AS AssetTypeName
			,(
				CASE 
					WHEN av.DemographicId = @ModelAttributeId
						THEN sav.Value
					ELSE NULL
					END
				) AS AssetModel
			,(
				CASE 
					WHEN avp.DemographicId = @PhotoAttributeId
						THEN savp.Value
					ELSE NULL
					END
				) AS AssetPhoto
			,sc.Code AS AssetCategoryCode
			,sb.IsTrackable AS IsTrackeable
		FROM Panelist pl
		INNER JOIN StockKit sk ON pl.ExpectedKit_Id = sk.GUIDReference
		INNER JOIN StockKitItem sitems ON sitems.StockKit_Id = sk.GUIDReference
		INNER JOIN StockType st ON sitems.StockType_Id = st.GUIDReference
		INNER JOIN StockCategory sc ON sc.GUIDReference = st.Category_Id
		INNER JOIN StockBehavior sb ON sb.GUIDReference = st.Behavior_Id
		INNER JOIN Respondent r ON r.GUIDReference = st.GUIDReference
		LEFT JOIN AttributeValue av ON av.RespondentId = r.GUIDReference
			AND av.DemographicId = @ModelAttributeId
		LEFT JOIN StringAttributeValue sav ON sav.GUIDReference = av.GUIDReference
		LEFT JOIN AttributeValue avp ON avp.RespondentId = r.GUIDReference
			AND avp.DemographicId = @PhotoAttributeId
		LEFT JOIN StringAttributeValue savp ON savp.GUIDReference = avp.GUIDReference
		WHERE pl.GUIDReference = @pPanelistId
		) t1
	LEFT JOIN (
		SELECT sitems.GUIDReference AS Id
			,(
				CASE 
					WHEN avc.DemographicId = @ConectivityAttributeId
						THEN [dbo].[GetTranslationValue](ed.Translation_Id, @pCultureCode)
					ELSE NULL
					END
				) AS AssetConectivity
		FROM Panelist pl
		INNER JOIN StockKit sk ON pl.ExpectedKit_Id = sk.GUIDReference
		INNER JOIN StockKitItem sitems ON sitems.StockKit_Id = sk.GUIDReference
		INNER JOIN StockType st ON sitems.StockType_Id = st.GUIDReference
		INNER JOIN StockCategory sc ON sc.GUIDReference = st.Category_Id
		INNER JOIN StockBehavior sb ON sb.GUIDReference = st.Behavior_Id
		INNER JOIN Respondent r ON r.GUIDReference = st.GUIDReference
		INNER JOIN AttributeValue avc ON avc.RespondentId = r.GUIDReference
		INNER JOIN EnumAttributeValue ev ON ev.GUIDReference = avc.GUIDReference
			AND avc.DemographicId = @ConectivityAttributeId
		INNER JOIN EnumDefinition ed ON ed.Demographic_Id = @ConectivityAttributeId
			AND ed.Id = ev.Value_Id
		WHERE pl.GUIDReference = @pPanelistId
		) t2 ON t1.Id = t2.Id
	LEFT JOIN (
		SELECT sitems.GUIDReference AS Id
			,(
				CASE 
					WHEN avs.DemographicId = @SoftwareVersionAttributeId
						THEN [dbo].[GetTranslationValue](eds.Translation_Id, @pCultureCode)
					ELSE NULL
					END
				) AS AssetSoftwareVersion
		FROM Panelist pl
		INNER JOIN StockKit sk ON pl.ExpectedKit_Id = sk.GUIDReference
		INNER JOIN StockKitItem sitems ON sitems.StockKit_Id = sk.GUIDReference
		INNER JOIN StockType st ON sitems.StockType_Id = st.GUIDReference
		INNER JOIN StockCategory sc ON sc.GUIDReference = st.Category_Id
		INNER JOIN StockBehavior sb ON sb.GUIDReference = st.Behavior_Id
		INNER JOIN Respondent r ON r.GUIDReference = st.GUIDReference
		INNER JOIN AttributeValue avs ON avs.RespondentId = r.GUIDReference
		INNER JOIN EnumAttributeValue evs ON evs.GUIDReference = avs.GUIDReference
			AND avs.DemographicId = @SoftwareVersionAttributeId
		INNER JOIN EnumDefinition eds ON eds.Demographic_Id = @SoftwareVersionAttributeId
			AND eds.Id = evs.Value_Id
		WHERE pl.GUIDReference = @pPanelistId
		) t3 ON t1.Id = t3.Id

	/* Collabaration Methodologies*/
	SELECT CM.GUIDReference AS Id
		,T.KeyName AS TranslationKeyName
		,dbo.GetTranslationValue(CM.TranslationId, @pCultureCode) AS NAME
	FROM CollaborationMethodology CM
	LEFT JOIN Translation T ON CM.TranslationId = T.TranslationId
	WHERE CM.Country_Id = @pCountryId
		

	SELECT CM.GUIDReference AS Id
		,T.KeyName AS TranslationKeyName
		,dbo.GetTranslationValue(CM.TranslationId, @pCultureCode) AS NAME
	FROM CollaborationMethodology CM
	LEFT JOIN Translation T ON CM.TranslationId = T.TranslationId
	WHERE CM.GUIDReference = @CMId

	/*IndividualRoleDtos*/
	--DECLARE @plRefusalState UNIQUEIDENTIFIER --Version 1.4
	--SET @plRefusalState = (
	--		SELECT TOP 1 TranslationId
	--		FROM Translation
	--		WHERE keyname = 'PanelistRefusalState'
	--		)
	SELECT DISTINCT D.Code
		,dbo.GetTranslationValue(D.Translation_Id, @pCultureCode) AS NAME
		,DRC.[Order]
		--,(
		--	CASE 
		--		WHEN t.TranslationId = @plRefusalState
		--			THEN @DefGUID
		--		ELSE ISNULL(DA.Candidate_Id, @DefGUID)
		--		END
		--	) AS Individual
		,ISNULL(DA.Candidate_Id, @DefGUID) AS Individual
	FROM ConfigurationSet CS
	INNER JOIN Panel P ON CS.PanelId = P.GUIDReference
	INNER JOIN Panelist PL ON PL.Panel_Id = P.GUIDReference
	INNER JOIN DynamicRoleConfiguration DRC ON CS.ConfigurationSetId = DRC.ConfigurationSetId
	INNER JOIN DynamicRole D ON D.DynamicRoleId = DRC.DynamicRoleId
	LEFT JOIN DynamicRoleAssignment DA ON DA.Panelist_Id = @pPanelistId
		AND D.DynamicRoleId = DA.DynamicRole_Id
	INNER JOIN StateDefinition SD ON sd.Id = PL.State_Id
	INNER JOIN Translation T ON t.TranslationId = sd.Label_Id
	WHERE CS.Type = 'Panel'
		AND PL.GUIDReference = @pPanelistId
	ORDER BY NAME

	/* PanelTasks*/
	SELECT SurveyTsk.NAME AS NAME
		,SurveyParticipationTaskId AS Id
		,PanTsk.Active
	FROM PanelSurveyParticipationTask PnlSurvey
	INNER JOIN SurveyParticipationTask SurveyTsk ON SurveyTsk.SurveyParticipationTaskId = PnlSurvey.Task_Id
	INNER JOIN PartyPanelSurveyParticipationTask PanTsk ON PanTsk.PanelTaskAssociation_Id = PnlSurvey.PanelSurveyParticipationTaskId
	INNER JOIN Panel ON Panel.GUIDReference = PnlSurvey.Panel_Id
	WHERE PnlSurvey.Panel_Id = @pnlId
		AND PanTsk.Panelist_Id = @pPanelistId

	--Demographics 
	EXEC GetPanelDemographics @pnlId
		,@pScopeReferenceId
		,@pCountryId
		,@pCultureCode

	SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'PurchaseCountHistory', 0)
			) AS IsCountryVisible

	EXEC GetKeyValueAppSetting 'PurchaseHistoryReport'
		,@pCountryId

	SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'ShowPanellisttripInfoUrl', 1)
			) AS IsPanelistTripInfoUrlVisible

	SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'DiaryHistory', 0)
			) AS IsDiaryHistoryVisible

	--SELECT (
	--		SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsPurchasePanelUrlVisible', 0)
	--		) AS IsPurchasePanelUrlVisible
		SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsPanelistCollabarationHistoryAndTaskHistoryBtnVisible', 0)
			) AS IsPanelistCollabarationHistoryAndTaskHistoryBtnVisible


			SELECT (



			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsSelectedPanelCardCollaborationRequired', 0)



			) AS IsPanelCardCollaborationRequired


				SELECT (

			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsTaskVisible', 0)



			) AS IsTaskVisible

			SELECT (



			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsIncentiveLevel', 0)



			) AS IsIncentiveLevelVisible
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
GO

