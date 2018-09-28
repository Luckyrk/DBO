GO
CREATE VIEW [dbo].[FullMainShoppersAE]
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
	AND Ct.CountryISO2A = 'AE'

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
	AND Ct.CountryISO2A = 'AE'


GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainShopperId  - For Countries using Main Shopper at Panel Level. This column holds the BusinessID for the Main Shopper on the Panel eg: 123456-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'MainShopperId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DateOfBirth  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'DateOfBirth'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexCode  - Holds the GenderID for the Individual. 1 = Male, 2 = Female and 3 = Unknown.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'SexCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexDescription  - Holds the Gender for the Individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'SexDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TitleDescription  - Holds the Title of an Individual, where specified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'TitleDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'FirstOrderedName  - Holds the first name of an Individual. Some countries may not use this value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'FirstOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelCode  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanelCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelName  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanelName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanellistState  - a Panellist can have many different states during their life time eg: Interested, Live, dropped off. Holds the current state fo the panellist.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanellistState'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SignupDate  - the date a Panellist joined KWP and became eligible to join panels. SOme countires may have different definitions on this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'SignupDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LiveDate  - the date a Panellist joined the Panel, and started returning data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'LiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'Holds details of the associated Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Holds details of the Business Area of data in the View.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=NULL , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullMainShoppersAE'
GO

--GRANT SELECT ON FullMainShoppersAE TO GPSBusiness

--GO