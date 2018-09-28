
CREATE VIEW [dbo].[FullLiveMainShoppers]
AS
SELECT ct.CountryISO2A
	,col.Sequence AS GroupId
	,MS.IndividualId
	,pi.DateOfBirth
	,isx.Code SexCode
	,sex.KeyName SexDescription
	,tit.KeyName TitleDescription
	,pi.FirstOrderedName
	,pi.LastOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,pst.CreationDate AS SignupDate
	,STATUSDATES.LiveDate
	,STATUSDATES.DroppedOffDate
FROM (SELECT MSh.IndividualId
		,MSh.GUIDReference
		,draMS.Group_Id
	FROM dbo.Individual AS MSh
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	INNER JOIN dbo.DynamicRoleAssignmentHistory dhMS ON dhMS.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
	WHERE drMS.Code = 2
		AND dhMS.DateTo IS NULL
	
	UNION ALL
	
	SELECT MSh2.IndividualId
		,MSh2.GUIDReference
		,draMS2.Group_Id
	FROM dbo.Individual AS MSh2
	INNER JOIN dbo.DynamicRoleAssignment draMS2 ON draMS2.Candidate_Id = MSh2.GUIDReference
	INNER JOIN dbo.DynamicRole drMS2 ON drMS2.DynamicRoleId = draMS2.DynamicRole_Id
	WHERE drMS2.Code = 2
		AND NOT EXISTS (
			SELECT ''
			FROM dbo.DynamicRoleAssignmentHistory b
			WHERE b.DynamicRoleAssignment_Id = draMS2.DynamicRoleAssignmentId
			)
	) AS MS
INNER JOIN dbo.Individual ind ON ind.GUIDReference = MS.GUIDReference
INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
LEFT JOIN dbo.IndividualTitle it ON it.GUIDReference = pi.TitleId
LEFT JOIN dbo.translation tit ON tit.TranslationId = it.Translation_Id
LEFT JOIN dbo.IndividualSex isx ON isx.GUIDReference = ind.Sex_Id
LEFT JOIN dbo.translation sex ON sex.TranslationId = isx.Translation_Id
INNER JOIN dbo.Collective col ON col.GUIDReference = MS.Group_Id
INNER JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = MS.GUIDReference
INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = MS.Group_Id
INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
INNER JOIN dbo.StateDefinition memstat ON memstat.Id = cmem.State_Id
LEFT JOIN (
	SELECT hist.Country_Id
		,Panelist_Id
		,max(iif(LIVESTATE.Code = 'PanelistLiveState', CreationDate, NULL)) AS LiveDate
		,max(iif(LIVESTATE.Code = 'PanelistDroppedOffState', CreationDate, NULL)) AS DroppedOffDate
	FROM dbo.StateDefinitionHistory HIST
	INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id
		AND HIST.Country_Id = Livestate.Country_Id
		AND LIVESTATE.code IN (
			'PanelistLiveState'
			,'PanelistDroppedOffState'
			)
	GROUP BY hist.Country_Id
		,Panelist_Id
	) AS STATUSDATES ON STATUSDATES.Panelist_Id = pst.GUIDReference
WHERE stat.Code = 'PanelistLiveState'
	AND memstat.Code = 'GroupMembershipResident'
	AND STATUSDATES.DroppedOffDate IS NULL