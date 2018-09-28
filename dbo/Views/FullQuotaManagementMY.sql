
CREATE VIEW [dbo].[FullQuotaManagementMY]
AS
SELECT DISTINCT A.CountryISO2A
	,A.GroupId
	,A.MainShopperId
	,A.DateOfBirth
	,A.PanelCode
	,A.PanelName
	,A.CollaborationMethodology
	,A.PanellistState
	,A.SignupDate
	,fga.Value AS Region
	,fga2.Value AS Habitat
	,gra.Value AS HouseholdSizeNew
	,gra1.Value AS LifeStageNew
	,gra2.Value AS FamilyMonthlyIncome
	,ina.Value AS Occupation
FROM (
	SELECT ct.CountryISO2A
		,spl.GroupId
		,ind.IndividualId AS MainShopperId
		,pi.DateOfBirth
		,pan.PanelCode
		,pan.NAME PanelName
		,cmem.Code CollaborationMethodology
		,stat.Code PanellistState
		,pst.CreationDate AS SignupDate
		,geo.Code
	FROM dbo.Individual ind
	INNER JOIN dbo.IndividualIdSplitter spl ON ind.IndividualId = spl.IndividualId
	INNER JOIN dbo.Candidate can ON can.GUIDReference = ind.GUIDReference
	INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
	INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = ind.GUIDReference
	INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
	INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
	INNER JOIN dbo.GeographicArea geo ON geo.GUIDReference = can.GeographicArea_Id
	LEFT JOIN CollaborationMethodology cmem ON cmem.GUIDReference = pst.CollaborationMethodology_Id
	INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
	WHERE stat.Code IN (
			'PanelistLiveState'
			,'PanelistInterestedState'
			,'PanelistPreLiveState'
			)
		AND Ct.CountryISO2A = 'MY'
	
	UNION ALL
	
	SELECT DISTINCT ct.CountryISO2A
		,col.Sequence GroupId
		,ind.IndividualId AS MainShopperId
		,pi.DateOfBirth
		,pan.PanelCode
		,pan.NAME PanelName
		,meth.Code CollaborationMethodology
		,stat.Code PanellistState
		,pst.CreationDate AS SignupDate
		,geo.Code
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
	INNER JOIN dbo.Candidate can ON can.GUIDReference = ind.GUIDReference
	INNER JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = ind.GUIDReference
	INNER JOIN dbo.Collective col ON col.GUIDReference = cmem.Group_Id
	INNER JOIN dbo.PersonalIdentification pi ON pi.PersonalIdentificationId = ind.PersonalIdentificationId
	INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = cmem.Group_Id
	INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
	INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
	INNER JOIN dbo.GeographicArea geo ON geo.GUIDReference = can.GeographicArea_Id
	LEFT JOIN CollaborationMethodology meth ON meth.GUIDReference = pst.CollaborationMethodology_Id
	INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
	WHERE stat.Code IN (
			'PanelistLiveState'
			,'PanelistInterestedState'
			,'PanelistPreLiveState'
			)
		AND Ct.CountryISO2A = 'MY'
	) A
LEFT JOIN dbo.FullGeographicAreaAttributesAsRows fga ON fga.Code = A.Code
	AND fga.CountryISO2A = A.CountryISO2A
	AND fga.[Key] = 'GeographicArea_Region'
LEFT JOIN dbo.FullGeographicAreaAttributesAsRows fga2 ON fga2.Code = A.Code
	AND fga2.CountryISO2A = A.CountryISO2A
	AND fga2.[Key] = 'GeographicArea_Habitat_code'
LEFT JOIN dbo.FullGroupIntAttributesAsRows gra ON gra.GroupId = A.GroupId
	AND gra.CountryISO2A = A.CountryISO2A
	AND gra.[Key] = 'Householdsize_New'
LEFT JOIN dbo.FullGroupEnumAttributesAsRows gra1 ON gra1.GroupId = A.GroupId
	AND gra1.CountryISO2A = A.CountryISO2A
	AND gra1.[Key] = 'Lifestagenew'
LEFT JOIN dbo.FullGroupEnumAttributesAsRows gra2 ON gra2.GroupId = A.GroupId
	AND gra2.CountryISO2A = A.CountryISO2A
	AND gra2.[Key] = 'Familymonthlyincome'
LEFT JOIN dbo.FullIndividualEnumAttributesAsRows ina ON ina.IndividualId = A.MainShopperId
	AND ina.CountryISO2A = A.CountryISO2A
	AND ina.[Key] = 'Occupationalcode'