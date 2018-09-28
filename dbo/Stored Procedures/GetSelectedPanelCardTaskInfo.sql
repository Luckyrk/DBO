CREATE PROCEDURE [dbo].[GetSelectedPanelCardTaskInfo] @pPanelistId UNIQUEIDENTIFIER
	,@pScopeReferenceId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pIsAdmin BIT
AS
BEGIN
	DECLARE @PnlId UNIQUEIDENTIFIER
	DECLARE @Scope VARCHAR(50)
	DECLARE @belongcount INT = 0
	DECLARE @candidateGuid UNIQUEIDENTIFIER
	DECLARE @businessId NVARCHAR(100)
	DECLARE @CMId UNIQUEIDENTIFIER
	DECLARE @ExpectedKitId UNIQUEIDENTIFIER
	DECLARE @StateId UNIQUEIDENTIFIER
	DECLARE @DefGUID UNIQUEIDENTIFIER
	DECLARE @PnlMemberId UNIQUEIDENTIFIER
	DECLARE @PnlCreatedDate DATETIME
	DECLARE @PnlName VARCHAR(100)
	DECLARE @CalendarPeriod NVARCHAR(100)

	SET @DefGUID = '00000000-0000-0000-0000-000000000000'

	SELECT @pnlId = PL.Panel_Id
		,@Scope = P.[Type]
		,@CMId = pl.CollaborationMethodology_Id
		,@ExpectedKitId = pl.ExpectedKit_Id
		,@StateId = pl.State_Id
		,@PnlName = p.[Name]
		,@PnlMemberId = pl.PanelMember_Id
		,@PnlCreatedDate = pl.CreationDate
	FROM Panelist PL
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
	WHERE PL.GUIDReference = @pPanelistId

	SELECT @candidateGuid = GUIDReference
		,@businessId = IndividualId
	FROM Individual
	WHERE GUIDReference = @pScopeReferenceId

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
		,NAC.Name AS NAME
	FROM NamedAliasContext NAC
	WHERE NAC.Panel_Id = @pnlId

	SELECT *
	FROM @mytable

	--select NamedAliasId			 
	SELECT NA.NamedAliasId AS Id  
	,NA.[Key] AS [Key]  
	,@pScopeReferenceId as [Guid]  
	,NA.AliasContext_Id AS AliasContextId  
	FROM NamedAlias NA  
	INNER JOIN @mytable myt ON NA.AliasContext_Id = myt.Id and (Candidate_Id=@PnlMemberId OR Candidate_Id=@pScopeReferenceId)

	/* PanelTasks*/
	SELECT SurveyTsk.Name AS NAME
		,SurveyParticipationTaskId AS Id
		,IIF(ValueAppPanel.GUIDReference IS NULL OR ValueAppTask.GUIDReference IS NULL, NULL, REPLACE(ValueAppUrl.Value, '{0}', PanLogon.LogonCode) ) AS PanelistUrlForFoodOnlineLink
		,PanTsk.Active
		,PanTsk.FromDate
		,PanTsk.ToDate
	FROM PanelSurveyParticipationTask PnlSurvey
	JOIN SurveyParticipationTask SurveyTsk ON SurveyTsk.SurveyParticipationTaskId = PnlSurvey.Task_Id
	JOIN PartyPanelSurveyParticipationTask PanTsk ON PanTsk.PanelTaskAssociation_Id = PnlSurvey.PanelSurveyParticipationTaskId
	JOIN Panel ON Panel.GUIDReference = PnlSurvey.Panel_Id
	LEFT JOIN [KeyAppSetting] KeyAppPanel ON KeyAppPanel.KeyName = 'PanelCodeForFoodOnlineLink'
	LEFT JOIN [KeyValueAppSetting] ValueAppPanel ON KeyAppPanel.GUIDReference = ValueAppPanel.KeyAppSetting_Id AND ValueAppPanel.Value = Panel.Name and ValueAppPanel.Country_Id = Panel.Country_Id
	LEFT JOIN [KeyAppSetting] KeyAppTask ON KeyAppTask.KeyName = 'TaskCodeForFoodOnlineLink'
	LEFT JOIN [KeyValueAppSetting] ValueAppTask ON KeyAppTask.GUIDReference = ValueAppTask.KeyAppSetting_Id AND ValueAppTask.Value = SurveyTsk.Name and ValueAppTask.Country_Id = SurveyTsk.Country_Id
	LEFT JOIN [PanelistLogonCode] PanLogon ON PanLogon.[PanelistId] = PanTsk.Panelist_Id
	LEFT JOIN [KeyValueAppSetting] ValueAppUrl ON ValueAppUrl.KeyAppSetting_Id = PanLogon.[KeyAppSettingId] and ValueAppUrl.Country_Id = Panel.Country_Id 
	WHERE PnlSurvey.Panel_Id = @pnlId
		AND PanTsk.Panelist_Id= @pPanelistId

	--Demographics 
	EXEC GetSelectedPanelCardDemographics @pnlId
		,@pScopeReferenceId
		,@pCountryId
		,@pCultureCode

	SELECT CCS.SignalColor AS SignalColor,dbo.GetTranslationValue(CC.Translation_Id,@pCultureCode) AS Value
		,dbo.GetTranslationValue(CC.Translation_Id,null) AS KeyName
		FROM ComplianceCategory CC
		INNER JOIN ComplianceCategoryStatus CCS on CCS.ComplianceCategory_Id = CC.GUIDReference
		WHERE CCS.Panelist_Id = @pPanelistId

END