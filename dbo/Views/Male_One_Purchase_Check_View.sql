
CREATE VIEW [dbo].[Male_One_Purchase_Check_View]
AS
SELECT k.*
	,mt.FirstOrderedName AS MainshopperName
	,p.StateCode
	,Convert(VARCHAR(10), p.SignupDate, 111) AS SignupDate
	,Convert(VARCHAR(10), p.InterestedDate, 111) AS InterestedDate
	,Convert(VARCHAR(10), p.LiveDate, 111) AS LiveDate
	,Convert(VARCHAR(10), p.DroppedOffDate, 111) AS DroppedOffDate
	,alias.[Alias] --,startEndPeriod
FROM (
	SELECT [MainShopper]
		,Count(0) AS [COUNT]
		,PanelCode
		,CategoryCode
		,SummaryCount
		,YearPeriodValue
	FROM (
		SELECT (cpd.yearPeriodValue * 100) + cpd.periodPeriodValue AS YearPeriodValue
			,cnt.[CountryISO2A]
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
		FROM dbo.PanelistSummaryCount a
		INNER JOIN dbo.Country cnt ON cnt.CountryId = a.Country_Id
		INNER JOIN dbo.Panel pan ON pan.GUIDReference = a.Panel_Id
		INNER JOIN dbo.Panelist pst ON pst.GUIDReference = a.PanelistId
		LEFT JOIN dbo.individual ind ON ind.GUIDReference = pst.PanelMember_Id
		LEFT JOIN dbo.collective col ON col.GUIDReference = pst.PanelMember_Id
		LEFT JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = pst.PanelMember_Id
		INNER JOIN dbo.Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
		INNER JOIN dbo.CalendarDenorm cpd ON cpd.CalendarId = a.CalendarPeriod_CalendarId
			AND cpd.weekPeriodID = a.CalendarPeriod_PeriodId
		LEFT JOIN dbo.CollaborationMethodology cm ON cm.GUIDReference = a.CollaborationMethodology_Id
		LEFT JOIN (
			SELECT MSh.IndividualId
				,draMS.Group_Id
				,draMS.Panelist_Id
			FROM dbo.Individual AS MSh
			INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
			INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
			INNER JOIN dbo.DynamicRoleAssignmentHistory dhMS ON dhMS.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
			INNER JOIN Country cnt ON cnt.CountryId = drMS.Country_Id
			WHERE drMS.Code = 2
				AND dhMS.DateTo IS NULL
			
			UNION
			
			SELECT MSh2.IndividualId
				,draMS2.Group_Id
				,draMS2.Panelist_Id
			FROM dbo.Individual AS MSh2
			INNER JOIN dbo.DynamicRoleAssignment draMS2 ON draMS2.Candidate_Id = MSh2.GUIDReference
			INNER JOIN dbo.DynamicRole drMS2 ON drMS2.DynamicRoleId = draMS2.DynamicRole_Id
			WHERE drMS2.Code = 2
				AND NOT EXISTS (
					SELECT ''
					FROM dbo.DynamicRoleAssignmentHistory b
					WHERE b.DynamicRoleAssignment_Id = draMS2.DynamicRoleAssignmentId
					)
			) AS MainSh ON MainSh.Panelist_Id = pst.GUIDReference
		) AS a
	GROUP BY MainShopper
		,PanelCode
		,CategoryCode
		,SummaryCount
		,YearPeriodValue
	) k
INNER JOIN MainShoppersTW mt ON k.MainShopper = mt.MainShopperid
INNER JOIN PanellistSet p ON p.PanLevelMainShopper = k.MainShopper
INNER JOIN [IndividualAliasAsRows] ALIAS ON k.MainShopper = ALIAS.[IndividualID]
WHERE SummaryCount = 1
	AND CategoryCode = 'S_COMALI'
	AND ALIAS.[Context] = 'QBu_ID_MP'