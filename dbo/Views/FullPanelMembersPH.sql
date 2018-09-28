
CREATE VIEW [dbo].[FullPanelMembersPH]
AS
SELECT ct.CountryISO2A
	,ind.IndividualId
	,pi.DateOfBirth
	,isx.Code SexCode
	,sex.KeyName SexDescription
	,tit.KeyName TitleDescription
	,pi.FirstOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,stat.Code PanellistState
	,Ind.IndividualId AS MainShopperId
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
LEFT JOIN (
	SELECT Country_Id
		,Panelist_Id
		,MAX(CreationDate) DroppedOffDate
	FROM dbo.StateDefinitionHistory HIST2
	WHERE HIST2.To_Id = (
			SELECT ID
			FROM dbo.StateDefinition LIVESTATE2
			WHERE LIVESTATE2.Code = 'PanelistDroppedOffState'
				AND LIVESTATE2.Country_Id = HIST2.Country_Id
			)
	GROUP BY Country_Id
		,Panelist_Id
	) AS DROPDATE ON DROPDATE.Country_Id = ct.CountryId
	AND DROPDATE.Panelist_Id = pst.GUIDReference
WHERE stat.Code IN (
		'PanelistLiveState'
		,'PanelistInterestedState'
		,'PanelistPreLiveState'
		)
	AND DROPDATE.DroppedOffDate IS NULL
	AND Ct.CountryISO2A = 'PH'

UNION ALL

SELECT ct.CountryISO2A
	,ind.IndividualId
	,pi.DateOfBirth
	,isx.Code SexCode
	,sex.KeyName SexDescription
	,tit.KeyName TitleDescription
	,pi.FirstOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,stat.Code PanellistState
	,MainSh.IndividualId AS MainShopperId
	,pst.CreationDate AS SignupDate
	,LIVEDATE.LiveDate
FROM dbo.Individual ind
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
LEFT JOIN (
	SELECT Country_Id
		,Panelist_Id
		,MAX(CreationDate) DroppedOffDate
	FROM dbo.StateDefinitionHistory HIST2
	WHERE HIST2.To_Id = (
			SELECT ID
			FROM dbo.StateDefinition LIVESTATE2
			WHERE LIVESTATE2.Code = 'PanelistDroppedOffState'
				AND LIVESTATE2.Country_Id = HIST2.Country_Id
			)
	GROUP BY Country_Id
		,Panelist_Id
	) AS DROPDATE ON DROPDATE.Country_Id = ct.CountryId
	AND DROPDATE.Panelist_Id = pst.GUIDReference
LEFT JOIN (
	SELECT MSh.IndividualId
		,draMS.Panelist_Id
	FROM dbo.Individual AS MSh
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	WHERE drMS.Code = 2
	) AS MainSh ON pst.GUIDReference = MainSh.Panelist_Id
WHERE stat.Code IN (
		'PanelistLiveState'
		,'PanelistInterestedState'
		,'PanelistPreLiveState'
		)
	AND DROPDATE.DroppedOffDate IS NULL
	AND Ct.CountryISO2A = 'PH'