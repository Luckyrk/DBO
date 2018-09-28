/****** Object:  View [dbo].[FullPanellistSet]    Script Date: 19/01/2016 08:41:38 ******/



CREATE VIEW [dbo].[FullPanellistSet]
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Panel.PanelCode
	,dbo.Panel.NAME PanelDesc
	,dbo.Panel.Type
	,PAN.PanelMemberID
	,PAN.GroupID
	,dbo.StockKit.NAME KitType
	,dbo.StockKit.Code KitCode
	,Main.MainContact
	,Main.PanLevelMainShopper
	,HH.IndividualID AS PanLevelHeadOfHousehold
	,Main.IndividualUnderStudy
	,dbo.StateDefinition.Code AS StateCode
	,dbo.Panelist.CreationDate AS SignupDate
	,STATUSDATES.InterestedDate
	,STATUSDATES.PreLiveDate
	,STATUSDATES.LiveDate
	,STATUSDATES.DroppedOffDate
	,STATUSDATES.RefusalDate
	,StatusDates.SelectedDate
	,dbo.CollaborationMethodology.Code CollabCode
	,CAST(dbo.Translation.KeyName AS VARCHAR(255)) AS CollabDesc
	,dbo.IncentiveLevel.Code IncentiveCode
	,dbo.Panelist.GPSUser
	,dbo.Panelist.GPSUpdateTimestamp
	,dbo.Panelist.CreationTimeStamp
FROM dbo.Panel
INNER JOIN dbo.Country ON dbo.Panel.Country_Id = dbo.Country.CountryId
INNER JOIN dbo.Panelist ON dbo.Panel.GUIDReference = dbo.Panelist.Panel_Id
LEFT JOIN dbo.CollaborationMethodology ON dbo.CollaborationMethodology.GUIDReference = dbo.Panelist.CollaborationMethodology_Id
LEFT JOIN dbo.Translation ON Translation.TranslationId = dbo.CollaborationMethodology.TranslationId
LEFT JOIN dbo.StockKit ON dbo.Panelist.ExpectedKit_Id = dbo.StockKit.GUIDReference
INNER JOIN dbo.StateDefinition ON dbo.Panelist.State_Id = dbo.StateDefinition.Id
INNER JOIN dbo.Candidate ON dbo.Panelist.PanelMember_Id = dbo.Candidate.GUIDReference
	AND Country.CountryId = Candidate.Country_Id
LEFT JOIN dbo.IncentiveLevel ON dbo.IncentiveLevel.GUIDReference = dbo.Panelist.IncentiveLevel_Id
INNER JOIN (SELECT GUIDReference,Individual.IndividualId PanelMemberID
		,CONVERT(VARCHAR, PARSENAME(REPLACE(IndividualId, '-', '.'), 2)) AS GroupID
	FROM Individual
	UNION ALL
	SELECT GUIDReference
		,CONVERT(VARCHAR, Sequence) PanelMemberID
		,CONVERT(VARCHAR, Sequence) GroupID
	FROM Collective
	) AS PAN ON PAN.GUIDReference = dbo.Panelist.PanelMember_Id
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
	) AS STATUSDATES ON STATUSDATES.Panelist_Id = dbo.Panelist.GUIDReference
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
	) AS Main ON dbo.Panelist.GUIDReference = Main.Panelist_Id
LEFT JOIN --Get the Group Level role Head of Household
	(
		SELECT 	c.Sequence, i.IndividualID, c.CountryId 
		FROM dbo.Individual i
			INNER JOIN dbo.DynamicRoleAssignment draHH ON draHH.Candidate_Id = i.GUIDReference
			INNER JOIN dbo.DynamicRole drMC ON drMC.DynamicRoleId = draHH.DynamicRole_Id
			INNER JOIN Collective c ON draHH.Group_ID = c.GUIDReference
		WHERE drMC.Code = 1
	) HH ON hh.Sequence = pan.GroupID AND hh.CountryId = Panelist.Country_Id
GO



