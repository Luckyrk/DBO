/*##########################################################################
-- Name				: GetAvalibalePanelists
-- Date             : 2014-11-20
-- Author           : GPS Developer
-- Company          : Cognizant Technology Solution
-- Purpose          : This SP fetches the GRoupTab details for given groupmembershipId
-- PARAM Definitions
	 @pGroupMembershipId UNIQUEIDENTIFIER  --Guid of GroupMembership
	,@pCultureCode INT -- CultureCode
-- Sample Execution :
	EXEC [GetGroupTabDetails] '576918e8-d621-4f69-93d8-ada96f28e7a5',2057
##########################################################################
-- ver  user			 date        change 
-- 1.0  GPSDeveloper	2014-11-20	 initial
-- 1.1  GPSDeveloper	2014-12-01	 Added history
-- 1.2	FernandezMat	2015-09-07	 Added support for reserved ids
##########################################################################*/
CREATE PROCEDURE [dbo].[GetGroupTabDetails] (
	@pGroupMembershipId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CollectiveMembershipStateId UNIQUEIDENTIFIER
	DECLARE @StateModelId UNIQUEIDENTIFIER
	DECLARE @BusinessId NVARCHAR(20)
	DECLARE @PresetedStateDefinitionId UNIQUEIDENTIFIER
	DECLARE @CountryId UNIQUEIDENTIFIER
	DECLARE @IndvidualId UNIQUEIDENTIFIER
	DECLARE @GroupId UNIQUEIDENTIFIER
	DECLARE @GroupMembershipStateChanged DATETIME
	DECLARE @EmptyGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	DECLARE @GroupDynamicRolesQuantity INT

	DECLARE @GetDate DATETIME
	

	-- Get Collective Membership Id,Individual_Id,Group_Id,Sequence
	SELECT @CollectiveMembershipStateId = State_Id
		,@IndvidualId = Individual_Id
		,@GroupId = Group_Id
	FROM CollectiveMembership cmp
	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference
	WHERE CollectiveMembershipId = @pGroupMembershipId

	SET @BusinessId = (
			SELECT IndividualId
			FROM Individual
			WHERE GUIDReference = @IndvidualId
			)

	-- Get the Preseted StateDefinition Id,CountryId 
	SELECT TOP 1 @StateModelId = StateModel_Id
		,@CountryId = Country_Id
	FROM StateDefinition
	WHERE Id = @CollectiveMembershipStateId

	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

	SELECT @PresetedStateDefinitionId = sdm.Id
	FROM StateDefinition sdm
	INNER JOIN TransitionBehavior tb ON sdm.StateDefinitionBehavior_Id = tb.GUIDReference
	WHERE sdm.StateModel_Id = @StateModelId
		AND tb.[Type] = 'PresetedTransitionBehavior'

	----Result set 1 for groupMembership
	SELECT @CollectiveMembershipStateId AS StateId
		,@PresetedStateDefinitionId AS StaeDefId

	--Result set 3  part of tempGroupMemDto     
	SELECT TOP 1 @GroupMembershipStateChanged = (
			CASE 
				WHEN sdh.CreationTimeStamp IS NOT NULL
					THEN sdh.CreationTimeStamp
				ELSE sd.CreationTimeStamp
				END
			)
	FROM CollectiveMembership cms
	INNER JOIN Candidate c ON cms.Individual_Id = c.GUIDReference
	INNER JOIN StateDefinition sd ON sd.Id = cms.State_Id
	LEFT JOIN StateDefinitionHistory sdh ON sdh.GroupMembership_Id = cms.CollectiveMembershipId
	WHERE c.GUIDReference = @IndvidualId
	ORDER BY sdh.CreationTimeStamp DESC

	--Result set 4  part of tempGroupMemDto   
	SELECT grp.Sequence AS GroupSequence
		,cmp.CollectiveMembershipId AS Id
		,grp.GUIDReference AS GroupId
		,cmp.Sequence AS Sequence
		,cmp.SignUpDate AS SignUpDate
		,(
			CASE 
				WHEN REPLICATE('0', CountryConfiguration.GroupBusinessIdDigits - LEN(CONVERT(NVARCHAR, grp.Sequence))) + CONVERT(NVARCHAR, grp.Sequence) IS NULL
					THEN CONVERT(NVARCHAR, grp.Sequence)
				ELSE REPLICATE('0', CountryConfiguration.GroupBusinessIdDigits - LEN(CONVERT(NVARCHAR, grp.Sequence))) + CONVERT(NVARCHAR, grp.Sequence)
				END
			) AS BusinessId
		,cmp.CollectiveMembershipId AS GroupMembershipId
		,(
			CASE 
				WHEN sdt.Id = @PresetedStateDefinitionId
					THEN 1
				ELSE 0
				END
			) AS StatusIsSystemState
		,grp.GroupContact_Id AS GroupContact
		,@GroupMembershipStateChanged AS GroupMembershipStateChanged
		,ind.IndividualId AS IndividualBusinessId
	FROM CollectiveMembership cmp
	INNER JOIN Collective grp ON cmp.Group_Id = grp.GUIDReference
	INNER JOIN Candidate cand ON cand.GUIDReference = grp.GUIDReference
	INNER JOIN Country ON Country.CountryId = cand.Country_Id
	INNER JOIN CountryConfiguration ON CountryConfiguration.Id = Country.Configuration_Id
	INNER JOIN Individual ind ON ind.GUIDReference = cmp.Individual_Id
	INNER JOIN StateDefinition sdt ON sdt.Id = cmp.State_Id
	WHERE cmp.CollectiveMembershipId = @pGroupMembershipId

	SELECT dbo.GetTranslationValue(sdtCandidate.Label_Id, @pCultureCode) AS NAME
		,sdtCandidate.Id AS CurrentStateId
		,sdtCandidate.Id AS NextStepId
		,sdtCandidate.InactiveBehavior AS DisplayWarningBehavior
	FROM CollectiveMembership cmp
	INNER JOIN Collective grp ON cmp.Group_Id = grp.GUIDReference
	INNER JOIN Candidate cand ON cand.GUIDReference = grp.GUIDReference
	INNER JOIN StateDefinition sdtCandidate ON sdtCandidate.Id = cand.CandidateStatus
	WHERE cmp.CollectiveMembershipId = @pGroupMembershipId

	----Result set 5  part of tempGroupMemDto    Group State Available Transitions
	SELECT st.ToState_Id AS StateToId
		,dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS StateToName
		,sd.Code AS StateToCode
	FROM CollectiveMembership cmp
	JOIN Collective grp ON cmp.Group_Id = grp.GUIDReference
	JOIN Candidate cand ON cand.GUIDReference = grp.GUIDReference
	JOIN StateTransition st on st.FromState_Id = cand.CandidateStatus
	JOIN StateDefinition sd on st.ToState_Id = sd.Id
	WHERE cmp.CollectiveMembershipId = @pGroupMembershipId

	----Result set 6  part of tempGroupMemDto ,Group Membership State
	SELECT dbo.GetTranslationValue(sdt.Label_Id, @pCultureCode) AS NAME
		,sdt.Id AS CurrentStateId
		,sdt.Id AS NextStepId
		,sdt.InactiveBehavior AS DisplayWarningBehavior
	FROM CollectiveMembership cmp
	INNER JOIN StateDefinition sdt ON sdt.Id = cmp.State_Id
	WHERE cmp.CollectiveMembershipId = @pGroupMembershipId

	----Result set 7  part of tempGroupMemDto ,Group Membership State Group Membership State Available Transitions
	SELECT st.ToState_Id AS StateToId
		,dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS StateToName
		,sd.Code AS StateToCode
	FROM CollectiveMembership cmp
	JOIN StateTransition st on st.FromState_Id = cmp.State_Id
	JOIN StateDefinition sd on st.ToState_Id = sd.Id
	WHERE cmp.CollectiveMembershipId = @pGroupMembershipId

	----Result set8  Dynamic Roles ASsignment
	SELECT @GroupDynamicRolesQuantity = COUNT(1)
	FROM CountryConfiguration cc
	INNER JOIN Country c ON cc.Id = c.Configuration_Id
	INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = cc.GroupConfigurationSet_Id
	INNER JOIN DynamicRoleConfiguration drc ON drc.ConfigurationSetId = cs.ConfigurationSetId
	WHERE c.CountryId = @CountryId
		AND cs.[Type] = 'group'

	DECLARE @DynamicRolesAsignmentTabel TABLE (
		RoleCode INT
		,CandidateId UNIQUEIDENTIFIER
		)

	INSERT INTO @DynamicRolesAsignmentTabel (
		RoleCode
		,CandidateId
		)
	SELECT dr.Code AS RoleCode
		,MIN(dra.Candidate_Id) AS CandidateId
	FROM CollectiveMembership cmp
	INNER JOIN Collective grp ON cmp.Group_Id = grp.GUIDReference
	INNER JOIN Candidate cand ON cand.GUIDReference = grp.GUIDReference
	INNER JOIN DynamicRoleAssignment dra ON dra.Group_Id = grp.GUIDReference
	INNER JOIN DynamicRole dr ON dr.DynamicRoleId = dra.DynamicRole_Id
	INNER JOIN DynamicRoleConfiguration DynRoleconfig ON DynRoleconfig.DynamicRoleId=dr.DynamicRoleId
    INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = DynRoleconfig.ConfigurationSetId
	INNER JOIN country c ON c.CountryId = cs.CountryID
	WHERE cmp.CollectiveMembershipId = @pGroupMembershipId
	AND 	cs.[type] = 'Group'
	GROUP BY dr.Code
		--AND dr.Code IN (
		--	1
		--	,2
		--	)

	IF @GroupDynamicRolesQuantity > (
			SELECT COUNT(1)
			FROM @DynamicRolesAsignmentTabel
			)
	BEGIN
		SELECT RoleCode
			,CandidateId
		FROM @DynamicRolesAsignmentTabel
		
		UNION
		
		SELECT dr.Code AS RoleCode
			,@EmptyGuid AS CandidateId
		FROM CountryConfiguration cc
		INNER JOIN Country c ON cc.Id = c.Configuration_Id
		INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = cc.GroupConfigurationSet_Id
		INNER JOIN DynamicRoleConfiguration drc ON drc.ConfigurationSetId = cs.ConfigurationSetId
		INNER JOIN DynamicRole dr ON dr.DynamicRoleId = drc.DynamicRoleId
		WHERE c.CountryId = @CountryId
			AND cs.[Type] = 'group'
			AND dr.Code NOT IN (
				SELECT RoleCode
				FROM @DynamicRolesAsignmentTabel
				)
	END
	ELSE
	BEGIN
		SELECT RoleCode
			,CandidateId
		FROM @DynamicRolesAsignmentTabel
	END

	--Result set9 groupMemDto.IndividualMembershipDtos
	SELECT (
			CASE 
				WHEN REPLICATE('0', CountryConfiguration.GroupBusinessIdDigits - LEN(CONVERT(NVARCHAR, c.Sequence))) + CONVERT(NVARCHAR, c.Sequence) IS NULL
					THEN CONVERT(NVARCHAR, c.Sequence)
				ELSE REPLICATE('0', CountryConfiguration.GroupBusinessIdDigits - LEN(CONVERT(NVARCHAR, c.Sequence))) + CONVERT(NVARCHAR, c.Sequence)
				END
			) AS HouseholdBusinessId
		,ind.GUIDReference AS Id
		,IIF(ind.IsAnonymized = 1, 'XXXXXXXXX', p.LastOrderedName)  AS LastName
		,ind.IndividualId AS BusinessId
		,IIF(ind.IsAnonymized = 1, 'XXXXXXXXX', p.MiddleOrderedName) AS MiddleName
		,IIF(ind.IsAnonymized = 1, 'XXXXXXXXX', p.FirstOrderedName) AS FirstName
		,p.DateOfBirth AS DateOfBirth
		,sd.InactiveBehavior AS IsGroupMembershipInactive
		,(
			CASE 
				WHEN sd.Id = @PresetedStateDefinitionId
					THEN 1
				ELSE 0
				END
			) AS StatusIsSystemState
		,dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS GroupMembershipStateName
		,ind.ReservedIndividualId AS ReservedBusinessId
	FROM CollectiveMembership  cmp
	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference
	INNER JOIN Candidate cand ON cand.GUIDReference = c.GUIDReference
	INNER JOIN Country ON Country.CountryId = cand.Country_Id
	INNER JOIN CountryConfiguration ON CountryConfiguration.Id = Country.Configuration_Id
	INNER JOIN Individual ind ON ind.GUIDReference = cmp.Individual_Id
	INNER JOIN PersonalIdentification p ON p.PersonalIdentificationId = ind.PersonalIdentificationId
	INNER JOIN StateDefinition sd ON sd.Id = cmp.State_Id
	WHERE c.GUIDReference = @GroupId

	----Result set10 part of   IndividualInPanelDtos
	SELECT cmp.Individual_Id AS Id
		,p.Name AS PanelName
		,p.Panels_Order AS PanelOrder
		,dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS NAME
		,RIGHT(LEFT(sd.DisplayBehaviorFullyQualifiedTypeName, CHARINDEX('Behavior', sd.DisplayBehaviorFullyQualifiedTypeName) - 1), CHARINDEX('.', REVERSE(LEFT(sd.DisplayBehaviorFullyQualifiedTypeName, CHARINDEX('Behavior', sd.DisplayBehaviorFullyQualifiedTypeName) - 1))) - 1) AS DisplayBehavior
	FROM CollectiveMembership cmp
	INNER JOIN Individual ind ON ind.GUIDReference = cmp.Individual_Id
	INNER JOIN Candidate cANDi ON cANDi.GUIDReference = ind.GUIDReference
	INNER JOIN Panelist pl ON pl.PanelMember_Id = cANDi.GUIDReference
	INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
	INNER JOIN StateDefinition sd ON sd.Id = pl.State_Id
	WHERE cmp.Group_Id = @GroupId
	
	UNION ALL
	
	SELECT cmp.Individual_Id AS Id
		,p.Name AS PanelName
		,p.Panels_Order AS PanelOrder
		,dbo.GetTranslationValue(sd.Label_Id, @pCultureCode) AS NAME
		,RIGHT(LEFT(sd.DisplayBehaviorFullyQualifiedTypeName, CHARINDEX('Behavior', sd.DisplayBehaviorFullyQualifiedTypeName) - 1), CHARINDEX('.', REVERSE(LEFT(sd.DisplayBehaviorFullyQualifiedTypeName, CHARINDEX('Behavior', sd.DisplayBehaviorFullyQualifiedTypeName) - 1))) - 1) AS DisplayBehavior
	FROM CollectiveMembership cmp
	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference
	INNER JOIN Candidate  cANDi ON cANDi.GUIDReference = cmp.Group_Id
	INNER JOIN Panelist pl ON pl.PanelMember_Id = c.GUIDReference
	INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
	INNER JOIN StateDefinition  sd ON sd.Id = pl.State_Id
	WHERE c.GUIDReference = @GroupId

	----resultset 11 getgroupdetails GetCurrentStateForGroup
	SELECT TOP 1 SDH.GUIDReference
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
              ,dbo.GetTranslationValue(SD.Label_Id, @pCultureCode) AS NewStatus
              ,SDH.CreationDate AS ChangedDate

	FROM 
    StateDefinitionHistory SDH
       INNER JOIN StateDefinition SD ON SD.Id = SDH.From_Id
       INNER JOIN StateDefinition SDTo ON SDTo.Id = SDH.To_Id	
	INNER JOIN Country  cntry ON cntry.CountryId = sd.Country_Id
	WHERE SDH.Candidate_Id= @GroupId
	ORDER BY CreationDate DESC

	----resultset 12 getgroupdetails List Aliascontext
	SELECT NamedAliasContextId AS Id
		,Name  AS NAME
	FROM NamedAliasContext 
	WHERE Country_Id = @CountryId

	SELECT AliasContext_Id AS AliasContextId, [Candidate_Id] AS [Guid], [Key] FROM NamedAlias
	WHERE Candidate_Id = @GroupId

	----resultset 13 DynamicRoles
	SELECT Code
		,(
			SELECT dbo.GetTranslationValue(TranslationId, @pCultureCode)
			) AS NAME
	FROM (
		SELECT dr.Code  AS Code
			,dr.Translation_Id AS TranslationId
		FROM DynamicRoleConfiguration DynRoleconfig
		INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = DynRoleconfig.ConfigurationSetId
		INNER JOIN Country c ON c.CountryId = cs.CountryID
		INNER JOIN DynamicRole  dr ON dr.DynamicRoleId = DynRoleconfig.DynamicRoleId
		WHERE (
				DynRoleconfig.ActiveTo IS NULL
				OR DynRoleconfig.ActiveTo >= @GetDate
				)
			AND (
				DynRoleconfig.ActiveFrom IS NULL
				OR DynRoleconfig.ActiveFrom <= @GetDate
				)
			AND cs.CountryID = @CountryId
			AND cs.[Type] = 'Group'
		) AS FinalTable

	--resultset 14 AvailableGroupDemographics
	SELECT A.GUIDReference as AttributeId, TT.Value as AttributeName
	FROM Attribute A
	JOIN [DynamicGroupAttribute] da ON da.attributeKey = a.[Key] and da.Country_Id = a.Country_Id
	JOIN TranslationTerm TT ON A.Translation_Id = TT.Translation_Id AND TT.CultureCode = @pCultureCode
	WHERE A.Country_Id = @CountryId
	
	--resultset 15 DynamicGroupDemographicValues 
	SELECT CM.Individual_Id as CandidateId, A.GUIDReference as AttributeId, ISNULL(TT.Value, '{' + A.[Key] + '}') AS Name, AV.Value AS Value, ISNULL(TTE.Value, '{' + TE.KeyName + '}') AS EValue
	FROM Attribute A
	JOIN [DynamicGroupAttribute] da ON da.[AttributeKey] = A.[Key] AND da.Country_Id = @CountryId
	JOIN CollectiveMembership CM ON CM.Group_Id = @GroupId
	LEFT JOIN AttributeValue AV ON AV.DemographicId = A.GUIDReference AND AV.CandidateId = CM.Individual_Id
	LEFT JOIN TranslationTerm TT ON A.Translation_Id = TT.Translation_Id AND TT.CultureCode = @pCultureCode
	LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
	LEFT JOIN Translation TE ON TE.TranslationId = ED.Translation_Id
	LEFT JOIN TranslationTerm TTE ON TTE.Translation_Id = TE.TranslationId AND TTE.CultureCode = @pCultureCode
	WHERE A.Country_Id = @CountryId
END
