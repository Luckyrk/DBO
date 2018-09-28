
CREATE VIEW [dbo].[QBAuditFullPanellistSet]
AS

Select *
From
(
SELECT dbo.Country.CountryISO2A
	,dbo.Panel.PanelCode
	,dbo.Panel.NAME PanelDesc
	,dbo.Panel.Type
	,PAN.PanelMemberID
	,PAN.GroupID
	,dbo.StockKit.NAME KitType
	,Main.MainContact
	,Main.PanLevelMainShopper
	,HH.IndividualID AS PanLevelHeadOfHousehold
	,Main.IndividualUnderStudy
	,dbo.StateDefinition.Code AS StateCode
	,Panelist.CreationDate AS SignupDate
	,STATUSDATES.InterestedDate
	,STATUSDATES.PreLiveDate
	,STATUSDATES.LiveDate
	,STATUSDATES.DroppedOffDate
	,STATUSDATES.RefusalDate
	,StatusDates.SelectedDate
	,dbo.CollaborationMethodology.Code CollabCode
	,CAST(dbo.Translation.KeyName AS VARCHAR(255)) AS CollabDesc
	,dbo.IncentiveLevel.Code IncentiveCode
	,Panelist.GPSUser
	,Panelist.GPSUpdateTimestamp
	,Panelist.CreationTimeStamp
	,Panelist.AuditOperation
FROM dbo.Panel
INNER JOIN dbo.Country ON dbo.Panel.Country_Id = dbo.Country.CountryId
INNER JOIN [GPS_PM_FRA_Audit].[audit].[Panelist] as Panelist ON dbo.Panel.GUIDReference = Panelist.Panel_Id
LEFT JOIN dbo.CollaborationMethodology ON dbo.CollaborationMethodology.GUIDReference = Panelist.CollaborationMethodology_Id
LEFT JOIN dbo.Translation ON Translation.TranslationId = dbo.CollaborationMethodology.TranslationId
LEFT JOIN dbo.StockKit ON Panelist.ExpectedKit_Id = dbo.StockKit.GUIDReference
INNER JOIN dbo.StateDefinition ON Panelist.State_Id = dbo.StateDefinition.Id
INNER JOIN dbo.Candidate ON Panelist.PanelMember_Id = dbo.Candidate.GUIDReference
	AND Country.CountryId = Candidate.Country_Id
LEFT JOIN dbo.IncentiveLevel ON dbo.IncentiveLevel.GUIDReference = Panelist.IncentiveLevel_Id
INNER JOIN (SELECT GUIDReference,Individual.IndividualId PanelMemberID
		,CONVERT(VARCHAR, PARSENAME(REPLACE(IndividualId, '-', '.'), 2)) AS GroupID
	FROM Individual
	UNION ALL
	SELECT GUIDReference
		,CONVERT(VARCHAR, Sequence) PanelMemberID
		,CONVERT(VARCHAR, Sequence) GroupID
	FROM Collective
	) AS PAN ON PAN.GUIDReference = Panelist.PanelMember_Id
LEFT JOIN (SELECT hist.Country_Id
		,Panelist_Id
		,max(iif(LIVESTATE.Code = 'PanelistInterestedState', CreationDate, NULL)) AS InterestedDate
		,max(iif(LIVESTATE.Code = 'PanelistPreLiveState', CreationDate, NULL)) AS PreLiveDate
		,max(iif(LIVESTATE.Code = 'PanelistLiveState', CreationDate, NULL)) AS LiveDate
		,max(iif(LIVESTATE.Code = 'PanelistDroppedOffState', CreationDate, NULL)) AS DroppedOffDate
		,max(iif(LIVESTATE.Code = 'PanelistRefusalState', CreationDate, NULL)) AS RefusalDate
		,max(iif(LiveState.code='PanelistSelectedState',CreationDate,Null)) as SelectedDate
	FROM dbo.StateDefinitionHistory HIST
	INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id
		AND HIST.Country_Id = Livestate.Country_Id
	GROUP BY hist.Country_Id
		,Panelist_Id
	) AS STATUSDATES ON STATUSDATES.Panelist_Id = Panelist.GUIDReference
LEFT JOIN (
	SELECT min(MCn.IndividualId) AS IndividualId
		,draMC.Panelist_Id
		,max(iif(drMC.code = 3, MCn.IndividualId, NULL)) AS MainContact
		,max(iif(drMC.code = 2, MCn.IndividualId, NULL)) AS PanLevelMainShopper
		--,max(iif(drMC.code = 1, MCn.IndividualId, NULL)) AS PanLevelHeadOfHousehold
		,max(iif(drMC.code = 4, MCn.IndividualId, NULL)) AS IndividualUnderStudy
	FROM dbo.Individual AS MCn
	INNER JOIN dbo.DynamicRoleAssignment draMC ON draMC.Candidate_Id = MCn.GUIDReference
	INNER JOIN dbo.DynamicRole drMC ON drMC.DynamicRoleId = draMC.DynamicRole_Id
	WHERE drMC.Code IN (
			2
			,3
			,4
			)
	GROUP BY draMC.Panelist_Id
	) AS Main ON Panelist.GUIDReference = Main.Panelist_Id
LEFT JOIN --Get the Group Level role Head of Household
	(
		SELECT 	c.Sequence, i.IndividualID, c.CountryId 
		FROM dbo.Individual i
			INNER JOIN dbo.DynamicRoleAssignment draHH ON draHH.Candidate_Id = i.GUIDReference
			INNER JOIN dbo.DynamicRole drMC ON drMC.DynamicRoleId = draHH.DynamicRole_Id
			INNER JOIN Collective c ON draHH.Group_ID = c.GUIDReference
		WHERE drMC.Code = 1
	) HH ON hh.Sequence = pan.GroupID AND hh.CountryId = Panelist.Country_Id
	) a
where a.GPSUser in ('QBImport','QBFRImport')
 and a.AuditOperation in ('I', 'N')

 GO


 EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelCode  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'PanelCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelDesc  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'PanelDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Type  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelMemberID  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'PanelMemberID'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupID  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'GroupID'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'KitType  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'KitType'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainContact  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'MainContact'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanLevelMainShopper  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'PanLevelMainShopper'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanLevelHeadOfHousehold  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'PanLevelHeadOfHousehold'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'IndividualUnderStudy  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'IndividualUnderStudy'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'StateCode  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'StateCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SignupDate  - the date a Panellist joined KWP and became eligible to join panels. SOme countires may have different definitions on this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'SignupDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'InterestedDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'InterestedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PreLiveDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'PreLiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LiveDate  - the date a Panellist joined the Panel, and started returning data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'LiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DroppedOffDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'DroppedOffDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'RefusalDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'RefusalDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SelectedDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'SelectedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CollabCode  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'CollabCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CollabDesc  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'CollabDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'IncentiveCode  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'IncentiveCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUser  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'GPSUser'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUpdateTimestamp  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'GPSUpdateTimestamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CreationTimeStamp  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'CreationTimeStamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AuditOperation  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet', @level2type=N'COLUMN',@level2name=N'AuditOperation'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'QBAuditFullPanellistSet, PanellistSet,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Panellists' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Questback users changes. Includes all country data. Provides a comprehensive list of Panellist state dates and state history for Interested, PreLive, Live, dropped off and refusal states, as well as Group and Panel level roles and collaboration method.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullPanellistSet'
GO

