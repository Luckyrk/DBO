
CREATE VIEW [dbo].[FullSummaryCount_TW_Linn]
	WITH schemabinding
AS
SELECT cnt.[CountryISO2A]
	,pan.[PanelCode]
	,pan.NAME AS [PanelName]
	,cm.Code AS CollaborationMethodology
	,scat.Code AS [CategoryCode]
	,scat.Description [CategoryDescription]
	,[SummaryCount]
	,cast(cpd.yearPeriodValue AS NVARCHAR) + '.' + cast(cpd.periodPeriodValue AS NVARCHAR) + '.' + cast(cpd.weekPeriodValue AS NVARCHAR) AS [FullPeriod]
	,cpd.yearPeriodValue AS [Year]
	,cpd.periodPeriodValue AS [Period]
	,cpd.weekPeriodValue AS [Week]
	,NULL AS [PeriodLevelFour]
	,CASE 
		WHEN ind.IndividualId IS NULL
			THEN cast(col.sequence AS NVARCHAR)
		ELSE ind.IndividualId
		END AS [PanelistId]
	,MainSh.IndividualId AS [MainShopper]
	,a.CalendarPeriod_CalendarId AS [CalendarId]
	,a.CalendarPeriod_PeriodId AS [CalendarTypePeriodId]
	,a.GPSUser
	,a.CreationTimeStamp
	,a.GPSUpdateTimestamp
FROM dbo.PanelistSummaryCount a
INNER JOIN dbo.Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = a.Panel_Id
INNER JOIN dbo.Panelist pst ON pst.GUIDReference = a.PanelistId
LEFT JOIN dbo.individual ind ON ind.GUIDReference = pst.PanelMember_Id
LEFT JOIN dbo.collective col ON col.GUIDReference = pst.PanelMember_Id
LEFT JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = pst.PanelMember_Id
INNER JOIN dbo.Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
	AND (
		scat.Code NOT IN (
			'P_DPEALI'
			,'P_DPRALI'
			)
		)
INNER JOIN dbo.CalendarDenorm cpd ON cpd.CalendarId = a.CalendarPeriod_CalendarId
	AND cpd.weekPeriodID = a.CalendarPeriod_PeriodId
LEFT JOIN dbo.CollaborationMethodology cm ON cm.GUIDReference = pst.CollaborationMethodology_Id
LEFT JOIN (
	SELECT GUIDReference
		,IndividualID
		,Panelist_Id
	FROM dbo.Individual MSh
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	INNER JOIN dbo.Translation t ON drMS.Translation_Id = t.TranslationId
	WHERE Keyname = 'MainShopperRoleName'
		AND NOT EXISTS (
			SELECT ''
			FROM dbo.DynamicRoleAssignmentHistory b
			WHERE b.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
			)
	
	UNION
	
	SELECT Msh2.GUIDReference
		,IndividualID
		,Panelist_Id
	FROM dbo.Individual MSh2
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh2.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	INNER JOIN dbo.DynamicRoleAssignmentHistory dhMS ON dhMS.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
	INNER JOIN dbo.Translation t ON drMS.Translation_Id = t.TranslationId
	WHERE Keyname = 'MainShopperRoleName'
		AND dhMS.DateTo IS NULL
	) MainSh ON a.PanelistID = MainSh.Panelist_Id

UNION

SELECT cnt.[CountryISO2A]
	,pan.[PanelCode]
	,pan.NAME AS [PanelName]
	,cm.Code AS CollaborationMethodology
	,scat.Code AS [CategoryCode]
	,scat.Description [CategoryDescription]
	,[SummaryCount]
	,cast(cpd.yearPeriodValue AS NVARCHAR) + '.' + cast(cpd.periodPeriodValue AS NVARCHAR) AS [FullPeriod]
	,cpd.yearPeriodValue AS [Year]
	,cpd.periodPeriodValue AS [Period]
	,NULL AS [Week]
	,NULL AS [PeriodLevelFour]
	,CASE 
		WHEN ind.IndividualId IS NULL
			THEN cast(col.sequence AS NVARCHAR)
		ELSE ind.IndividualId
		END AS [PanelistId]
	,MainSh.IndividualId AS [MainShopper]
	,a.CalendarPeriod_CalendarId AS [CalendarId]
	,a.CalendarPeriod_PeriodId AS [CalendarTypePeriodId]
	,a.GPSUser
	,a.CreationTimeStamp
	,a.GPSUpdateTimestamp
FROM dbo.PanelistSummaryCount a
INNER JOIN dbo.Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = a.Panel_Id
INNER JOIN dbo.Panelist pst ON pst.GUIDReference = a.PanelistId
LEFT JOIN dbo.individual ind ON ind.GUIDReference = pst.PanelMember_Id
LEFT JOIN dbo.collective col ON col.GUIDReference = pst.PanelMember_Id
LEFT JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = pst.PanelMember_Id
INNER JOIN dbo.Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
	AND (
		scat.Code IN (
			'P_DPEALI'
			,'P_DPRALI'
			,'Monthly_R'
			,'Monthly_P'
			)
		)
INNER JOIN dbo.CalendarDenorm cpd ON cpd.CalendarID = a.CalendarPeriod_CalendarId
	AND cpd.periodPeriodID = a.CalendarPeriod_PeriodId
LEFT JOIN dbo.CollaborationMethodology cm ON cm.GUIDReference = pst.CollaborationMethodology_Id
LEFT JOIN (
	SELECT GUIDReference
		,IndividualID
		,Panelist_Id
	FROM dbo.Individual MSh
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	INNER JOIN dbo.Translation t ON drMS.Translation_Id = t.TranslationId
	WHERE Keyname = 'MainShopperRoleName'
		AND NOT EXISTS (
			SELECT ''
			FROM dbo.DynamicRoleAssignmentHistory b
			WHERE b.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
			)
	
	UNION
	
	SELECT Msh.GUIDReference
		,IndividualID
		,Panelist_Id
	FROM dbo.Individual MSh
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	INNER JOIN dbo.DynamicRoleAssignmentHistory dhMS ON dhMS.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
	INNER JOIN dbo.Translation t ON drMS.Translation_Id = t.TranslationId
	WHERE Keyname = 'MainShopperRoleName'
		AND dhMS.DateTo IS NULL
	) MainSh ON a.PanelistID = MainSh.Panelist_Id