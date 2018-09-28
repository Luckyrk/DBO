CREATE VIEW [dbo].[FullGroups]
AS
SELECT DISTINCT can.GUIDReference
	,dbo.Country.CountryISO2A
	,dbo.Collective.Sequence GroupId
	,can.Comments
	,(
		SELECT TOP 1 kit.NAME
		FROM dbo.Panelist pst
		LEFT JOIN dbo.StockKit kit ON pst.ExpectedKit_Id = Kit.GUIDReference
		LEFT JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
		WHERE pst.PanelMember_Id = can.GUIDReference
		ORDER BY pan.Panels_Order
		) KitType
	,ind.IndividualId AS GroupContact
	,Roles.HeadOfHousehold
	,Roles.MainShopper
	,Roles.ChiefIncomeEarner
	,Roles.MainContact
	,geo.Code GeographicAreaCode
	,dbo.Collective.CreationTimeStamp AS SignupDate
	,max(sdh.CreationDate) AS TerminatedDate
	,max(sdhduplicate.CreationDate) AS DuplicatedDate
	,dbo.Collective.GPSUser
	,dbo.Collective.CreationTimeStamp
	,dbo.Collective.GPSUpdateTimestamp
FROM dbo.Collective
INNER JOIN dbo.Candidate can ON dbo.Collective.GUIDReference = can.GUIDReference
LEFT JOIN statedefinition sd ON sd.id = can.candidatestatus
	AND sd.Code IN (
		'GroupTerminated'
		,'GroupDuplicate'
		)
LEFT JOIN statedefinitionhistory sdh ON sdh.To_Id = sd.id
	AND sdh.candidate_id = can.guidreference
	AND sd.code = 'GroupTerminated'
LEFT JOIN statedefinitionhistory sdhduplicate ON sdhduplicate.to_id = sd.id
	AND sdhduplicate.candidate_id = can.guidreference
	AND sd.code = 'GroupDuplicate'
INNER JOIN dbo.Country ON can.Country_ID = dbo.Country.CountryId
LEFT JOIN dbo.GeographicArea geo ON geo.GUIDReference = can.GeographicArea_Id
LEFT JOIN dbo.Individual ind ON ind.GuidReference = dbo.Collective.GroupContact_Id
LEFT JOIN (
	SELECT t.Group_Id
		,max(iif(t.Code = 1, IndividualId, NULL)) AS HeadOfHousehold
		,max(iif(t.Code = 2, IndividualId, NULL)) AS MainShopper
		,max(iif(t.Code = 3, IndividualId, NULL)) AS MainContact
		,max(iif(t.Code = 4, IndividualId, NULL)) AS ChiefIncomeEarner
	FROM (
		SELECT Hoh.IndividualId
			,draHH.Group_Id
			,drHH.Code
		FROM dbo.Individual AS Hoh
		INNER JOIN dbo.DynamicRoleAssignment draHH ON draHH.Candidate_Id = Hoh.GUIDReference
		INNER JOIN dbo.DynamicRole drHH ON drHH.DynamicRoleId = draHH.DynamicRole_Id
		INNER JOIN dbo.DynamicRoleAssignmentHistory dhaHH ON dhaHH.DynamicRoleAssignment_Id = draHH.DynamicRoleAssignmentId
		--WHERE dhaHH.DateTo IS NULL
		
		UNION
		
		SELECT Hoh2.IndividualId
			,draHH2.Group_Id
			,drHH2.Code
		FROM dbo.Individual AS Hoh2
		INNER JOIN dbo.DynamicRoleAssignment draHH2 ON draHH2.Candidate_Id = Hoh2.GUIDReference
		INNER JOIN dbo.DynamicRole drHH2 ON drHH2.DynamicRoleId = draHH2.DynamicRole_Id
		WHERE NOT EXISTS (
				SELECT ''
				FROM dbo.DynamicRoleAssignmentHistory a
				WHERE a.DynamicRoleAssignment_Id = draHH2.DynamicRoleAssignmentId
				)
		) t
	GROUP BY t.Group_Id
	) AS Roles ON dbo.Collective.GUIDReference = Roles.Group_Id
GROUP BY can.GUIDReference
	,dbo.Country.CountryISO2A
	,dbo.Collective.Sequence
	,can.Comments
	,ind.IndividualId
	,Roles.HeadOfHousehold
	,Roles.MainShopper
	,Roles.ChiefIncomeEarner
	,Roles.MainContact
	,geo.Code
	,dbo.Collective.CreationTimeStamp
	,dbo.Collective.GPSUser
	,dbo.Collective.GPSUpdateTimestamp