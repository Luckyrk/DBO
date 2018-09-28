
CREATE VIEW [dbo].[GetPeriodPurchaseCount]
AS
SELECT cnt.CountryISO2A
	,pan.PanelCode
	,scat.Code
	,ind.individualid
	,cpperiod.PeriodValue Period
	,cpyear.PeriodValue [Year]
	,SummaryCount
FROM PanelistSummaryCount a
INNER JOIN Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN Panel pan ON pan.GUIDReference = a.Panel_Id
INNER JOIN Panelist pst ON pst.GUIDReference = a.PanelistId
INNER JOIN individual ind ON ind.GUIDReference = pst.PanelMember_Id
INNER JOIN Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
INNER JOIN CalendarPeriod cpweek ON cpweek.CalendarId = a.CalendarPeriod_CalendarId
	AND cpweek.PeriodId = a.CalendarPeriod_PeriodId
INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = a.CalendarPeriod_CalendarId
	AND cph.SequenceWithinHierarchy = 1
INNER JOIN CalendarPeriod cpperiod ON cpperiod.CalendarId = a.CalendarPeriod_CalendarId
	AND cpperiod.StartDate <= cpweek.StartDate
	AND cpperiod.EndDate >= cpweek.EndDate
	AND cpperiod.PeriodTypeId = cph.ChildPeriodTypeId
INNER JOIN CalendarPeriod cpyear ON cpyear.CalendarId = a.CalendarPeriod_CalendarId
	AND cpyear.StartDate <= cpperiod.StartDate
	AND cpyear.EndDate >= cpperiod.EndDate
	AND cpyear.PeriodTypeId = cph.ParentPeriodTypeId