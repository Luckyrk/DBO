
CREATE VIEW [dbo].[LotteryTW]
AS
SELECT pan.[PanelCode]
	,col.Sequence GroupId
	,MainSh.IndividualId MainShopperId
	,cpyear.PeriodValue AS [Year]
	,cpperiod.PeriodValue AS [Period]
	,(cpyear.PeriodValue * 100) + cpperiod.PeriodValue AS [YP]
FROM [dbo].[PanelistEligibility] pe
INNER JOIN dbo.Panelist pst ON pst.GUIDReference = pe.PanelistId
LEFT JOIN dbo.Individual ind ON ind.GUIDReference = pst.PanelMember_Id
INNER JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = ind.GUIDReference
INNER JOIN dbo.Collective col ON col.GUIDReference = cmem.Group_Id
INNER JOIN dbo.Country cnt ON cnt.CountryId = pe.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pe.Panel_Id
INNER JOIN dbo.CalendarPeriod cpweek ON cpweek.CalendarId = pe.CalendarPeriod_CalendarId
	AND cpweek.PeriodId = pe.CalendarPeriod_PeriodId
INNER JOIN dbo.CalendarPeriodHierarchy cph ON cph.CalendarId = pe.CalendarPeriod_CalendarId
	AND cph.SequenceWithinHierarchy = 1
INNER JOIN dbo.CalendarPeriod cpperiod ON cpperiod.CalendarId = pe.CalendarPeriod_CalendarId
	AND cpperiod.StartDate <= cpweek.StartDate
	AND cpperiod.EndDate >= cpweek.EndDate
	AND cpperiod.PeriodTypeId = cph.ChildPeriodTypeId
INNER JOIN dbo.CalendarPeriod cpyear ON cpyear.CalendarId = pe.CalendarPeriod_CalendarId
	AND cpyear.StartDate <= cpperiod.StartDate
	AND cpyear.EndDate >= cpperiod.EndDate
	AND cpyear.PeriodTypeId = cph.ParentPeriodTypeId
INNER JOIN dbo.FullDiaryEntries de ON de.IndividualId = ind.IndividualId
	AND de.DiaryDateYear = cpyear.PeriodValue
	AND de.DiaryDatePeriod = cpperiod.PeriodValue
LEFT JOIN (
	SELECT MSh.IndividualId
		,draMS.Group_Id
	FROM dbo.Individual AS MSh
	INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference
	INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
	INNER JOIN dbo.DynamicRoleAssignmentHistory dhMS ON dhMS.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
	WHERE drMS.Code = 2
		AND dhMS.DateTo IS NULL
	
	UNION
	
	SELECT MSh2.IndividualId
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
	) AS MainSh ON col.GUIDReference = MainSh.Group_Id
WHERE pe.IsEligible = 1
	AND cnt.CountryISO2A = 'TW'
------------------  and cpyear.PeriodValue*100+cpperiod.PeriodValue between 200000 and 301411 
GROUP BY col.Sequence
	,pan.PanelCode
	,MainSh.IndividualId
	,cpyear.PeriodValue
	,cpperiod.PeriodValue
HAVING sum(CASE 
			WHEN de.ClaimFlag = 0
				THEN 1
			ELSE 0
			END) = Count(1)