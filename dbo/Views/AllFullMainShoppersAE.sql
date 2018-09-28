CREATE VIEW [dbo].[AllFullMainShoppersAE]
AS
SELECT ct.CountryISO2A
	,ind.IndividualId AS MainShopperId
	,SUBSTRING(ind.IndividualId,0, CHARINDEX('-',ind.IndividualId,0)) as GroupId
	,pi.FirstOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,stat.Code PanellistState
	,pst.CreationDate AS SignupDate
	,LIVEDATE.LiveDate
	,DroppedOffDate.DropOffDate
FROM dbo.Individual ind
INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
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
		,MAX(CreationDate) DropOffDate
	FROM dbo.StateDefinitionHistory HIST1
	WHERE HIST1.To_Id = (
			SELECT ID
			FROM dbo.StateDefinition DroppedOffDate
			WHERE DroppedOffDate.Code = 'PanelistDroppedOffState'
				AND DroppedOffDate.Country_Id = HIST1.Country_Id
			)
	GROUP BY Country_Id
		,Panelist_Id
	) AS DroppedOffDate ON DroppedOffDate.Country_Id = ct.CountryId
	AND DroppedOffDate.Panelist_Id = pst.GUIDReference
WHERE stat.Code IN (
		'PanelistDroppedOffState',
		'PanelistInterestedState',
		'PanelistInvitedState',
		'PanelistLiveState',
		'PanelistMaterialSentState',
		'PanelistPreLiveState',
		'PanelistPresetedState',
		'PanelistRefusalState',
		'PanelistSelectedState')
	AND Ct.CountryISO2A = 'AE'

UNION ALL

SELECT DISTINCT ct.CountryISO2A
	,ind.IndividualId AS MainShopperId
	,SUBSTRING(ind.IndividualId,0, CHARINDEX('-',ind.IndividualId,0)) as GroupId
	,pi.FirstOrderedName
	,pan.PanelCode
	,pan.NAME PanelName
	,stat.Code PanellistState
	,pst.CreationDate AS SignupDate
	,LIVEDATE.LiveDate
	,DroppedOffDate.DropOffDate
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
		,MAX(CreationDate) DropOffDate
	FROM dbo.StateDefinitionHistory HIST1
	WHERE HIST1.To_Id = (
			SELECT ID
			FROM dbo.StateDefinition DroppedOffDate
			WHERE DroppedOffDate.Code = 'PanelistDroppedOffState'
				AND DroppedOffDate.Country_Id = HIST1.Country_Id
			)
	GROUP BY Country_Id
		,Panelist_Id
	) AS DroppedOffDate ON DroppedOffDate.Country_Id = ct.CountryId
	AND DroppedOffDate.Panelist_Id = pst.GUIDReference
WHERE stat.Code IN (
		'PanelistDroppedOffState',
		'PanelistInterestedState',
		'PanelistInvitedState',
		'PanelistLiveState',
		'PanelistMaterialSentState',
		'PanelistPreLiveState',
		'PanelistPresetedState',
		'PanelistRefusalState',
		'PanelistSelectedState')
	AND Ct.CountryISO2A = 'AE'
--ORDER BY MainShopperID



GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainShopperId  - For Countries using Main Shopper at Panel Level. This column holds the BusinessID for the Main Shopper on the Panel eg: 123456-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'MainShopperId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'FirstOrderedName  - Holds the first name of an Individual. Some countries may not use this value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'FirstOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelCode  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanelCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelName  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanelName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanellistState  - a Panellist can have many different states during their life time eg: Interested, Live, dropped off. Holds the current state fo the panellist.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanellistState'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SignupDate  - the date a Panellist joined KWP and became eligible to join panels. SOme countires may have different definitions on this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'SignupDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LiveDate  - the date a Panellist joined the Panel, and started returning data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'LiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DropOffDate  - the date a Panellist was removed from a Panel.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE', @level2type=N'COLUMN',@level2name=N'DropOffDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'AllFullMainShoppersAE, AllMainShoppersMY,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Panellist roles' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific MY only. Provides a list of the ID''s, names panels, sign up, Live dates and Drop off date if relevant of all Main shoppers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllFullMainShoppersAE'
GO

--GRANT SELECT ON [AllFullMainShoppersAE] TO GPSBusiness

--GO