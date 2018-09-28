
CREATE VIEW [dbo].[FullMainShoppersMY]
AS
SELECT ct.CountryISO2A
	,ind.IndividualId AS MainShopperId
	,SUBSTRING(ind.IndividualId,0, CHARINDEX('-',ind.IndividualId,0)) as GroupId
	,pi.DateOfBirth
	,isx.Code SexCode
	,sex.KeyName SexDescription
	,tit.KeyName TitleDescription
	,pi.FirstOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,stat.Code PanellistState
	,pst.CreationDate AS SignupDate
	,LIVEDATE.LiveDate
FROM dbo.Individual ind
INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
LEFT JOIN dbo.IndividualTitle it ON it.GUIDReference = pi.TitleId
LEFT JOIN dbo.translation tit ON tit.TranslationId = it.Translation_Id
LEFT JOIN dbo.IndividualSex isx ON isx.GUIDReference = ind.Sex_Id
LEFT JOIN dbo.translation sex ON sex.TranslationId = isx.Translation_Id
INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = ind.GUIDReference
INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
LEFT JOIN (
	SELECT Country_Id
		,Panelist_Id
		,MAX(CreationDate) LiveDate
	FROM dbo.StateDefinitionHistory HIST1
	WHERE HIST1.To_Id = (
			SELECT ID
			FROM dbo.StateDefinition LIVESTATE1
			WHERE LIVESTATE1.Code = 'PanelistLiveState'
				AND LIVESTATE1.Country_Id = HIST1.Country_Id
			)
	GROUP BY Country_Id
		,Panelist_Id
	) AS LIVEDATE ON LIVEDATE.Country_Id = ct.CountryId
	AND LIVEDATE.Panelist_Id = pst.GUIDReference
WHERE stat.Code IN (
		'PanelistLiveState'
		,'PanelistInterestedState'
		,'PanelistPreLiveState'
		)
	AND Ct.CountryISO2A = 'MY'

UNION ALL

SELECT DISTINCT ct.CountryISO2A
	,ind.IndividualId AS MainShopperId
	,SUBSTRING(ind.IndividualId,0, CHARINDEX('-',ind.IndividualId,0)) as GroupId
	,pi.DateOfBirth
	,isx.Code SexCode
	,sex.KeyName SexDescription
	,tit.KeyName TitleDescription
	,pi.FirstOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,stat.Code PanellistState
	,pst.CreationDate AS SignupDate
	,LIVEDATE.LiveDate
FROM (
	SELECT MSh.IndividualId
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
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = ind.GUIDReference
INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
LEFT JOIN dbo.IndividualTitle it ON it.GUIDReference = pi.TitleId
LEFT JOIN dbo.translation tit ON tit.TranslationId = it.Translation_Id
LEFT JOIN dbo.IndividualSex isx ON isx.GUIDReference = ind.Sex_Id
LEFT JOIN dbo.translation sex ON sex.TranslationId = isx.Translation_Id
INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = cmem.Group_Id
INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
LEFT JOIN (
	SELECT Country_Id
		,Panelist_Id
		,MAX(CreationDate) LiveDate
	FROM dbo.StateDefinitionHistory HIST1
	WHERE HIST1.To_Id = (
			SELECT ID
			FROM dbo.StateDefinition LIVESTATE1
			WHERE LIVESTATE1.Code = 'PanelistLiveState'
				AND LIVESTATE1.Country_Id = HIST1.Country_Id
			)
	GROUP BY Country_Id
		,Panelist_Id
	) AS LIVEDATE ON LIVEDATE.Country_Id = ct.CountryId
	AND LIVEDATE.Panelist_Id = pst.GUIDReference
WHERE stat.Code IN (
		'PanelistLiveState'
		,'PanelistInterestedState'
		,'PanelistPreLiveState'
		)
	AND Ct.CountryISO2A = 'MY'