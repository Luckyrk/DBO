CREATE VIEW GetPurchaseCount
AS
SELECT c.CountryISO2A
	,ps.Panel_Id
	,ps.PanelistId
	,ps.SummaryCategoryId
	,ps.CalendarPeriod_CalendarId
	,ps.CalendarPeriod_PeriodId
	,cp.PeriodValue
	,i.IndividualId
	,p.PanelCode
	,ps.summarycount
FROM PanelistSummaryCount ps
INNER JOIN panel p ON p.guidreference = ps.Panel_Id
	AND p.Type = 'Individual'
INNER JOIN Panelist pl ON pl.GuidReference = ps.PanelistId
INNER JOIN country c ON c.CountryId = ps.Country_Id
INNER JOIN individual i ON i.GUIDReference = pl.PanelMember_Id
INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = ps.CalendarPeriod_CalendarId
	AND cph.SequenceWithinHierarchy = 1
INNER JOIN CalendarPeriod cp ON cp.calendarid = ps.CalendarPeriod_CalendarId
	AND cp.PeriodId = ps.CalendarPeriod_PeriodId
	AND cp.PeriodTypeId = cph.ChildPeriodTypeId
INNER JOIN Summary_Category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId

UNION ALL

SELECT c.CountryISO2A
	,ps.Panel_Id
	,ps.PanelistId
	,ps.SummaryCategoryId
	,ps.CalendarPeriod_CalendarId
	,ps.CalendarPeriod_PeriodId
	,cp.PeriodValue
	,i.IndividualId
	,p.PanelCode
	,ps.summarycount
FROM PanelistSummaryCount ps
INNER JOIN panel p ON p.guidreference = ps.Panel_Id
	AND p.Type = 'HouseHold'
INNER JOIN Panelist pl ON pl.GuidReference = ps.PanelistId
INNER JOIN country c ON c.CountryId = ps.Country_Id
INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = ps.CalendarPeriod_CalendarId
	AND cph.SequenceWithinHierarchy = 1
INNER JOIN CalendarPeriod cp ON cp.calendarid = ps.CalendarPeriod_CalendarId
	AND cp.PeriodId = ps.CalendarPeriod_PeriodId
	AND cp.PeriodTypeId = cph.ChildPeriodTypeId
INNER JOIN Summary_Category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId