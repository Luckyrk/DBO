
CREATE VIEW [dbo].[FullLivePanelMembers]
AS
SELECT ct.CountryISO2A
	,col.Sequence AS GroupId
	,ind.IndividualId
	,pi.DateOfBirth
	,isx.Code SexCode
	,sex.KeyName SexDescription
	,tit.KeyName TitleDescription
	,pi.FirstOrderedName
	,pi.LastOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,pst.CreationDate AS SignupDate
	,StatusDATE.LiveDate
	,StatusDATE.DroppedOffDate
FROM dbo.CollectiveMembership cmem
INNER JOIN dbo.Individual ind ON ind.GUIDReference = cmem.Individual_Id
INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
LEFT JOIN dbo.IndividualTitle it ON it.GUIDReference = pi.TitleId
LEFT JOIN dbo.translation tit ON tit.TranslationId = it.Translation_Id
LEFT JOIN dbo.IndividualSex isx ON isx.GUIDReference = ind.Sex_Id
LEFT JOIN dbo.translation sex ON sex.TranslationId = isx.Translation_Id
INNER JOIN dbo.Collective col ON col.GUIDReference = cmem.Group_Id
INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = cmem.Individual_Id
INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
INNER JOIN dbo.StateDefinition memstat ON memstat.Id = cmem.State_Id
LEFT JOIN (
	SELECT HIST1.Country_Id
		,Panelist_Id
		,MAX(iif(LIVESTATE.Code = 'PanelistLiveState', CreationDate, NULL)) LiveDate
		,MAX(iif(LIVESTATE.Code = 'PanelistDroppedOffState', CreationDate, NULL)) DroppedOffDate
	FROM dbo.StateDefinitionHistory HIST1
	INNER JOIN dbo.StateDefinition LIVESTATE ON HIST1.To_Id = LIVESTATE.id
		AND HIST1.Country_Id = Livestate.Country_Id
		AND LIVESTATE.code IN (
			'PanelistLiveState'
			,'PanelistDroppedOffState'
			)
	GROUP BY HIST1.Country_Id
		,Panelist_Id
	) AS StatusDATE ON StatusDATE.Country_Id = ct.CountryId
	AND StatusDATE.Panelist_Id = pst.GUIDReference
WHERE stat.Code = 'PanelistLiveState'
	AND memstat.Code = 'GroupMembershipResident'
	AND StatusDATE.DroppedOffDate IS NULL