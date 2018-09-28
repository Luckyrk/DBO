
CREATE VIEW [dbo].[GetWeekPurchaseCount]
AS
SELECT cnt.CountryISO2A
	,pan.PanelCode
	,scat.Code
	,ind.individualid
	,b.[Year]
	,b.Period
	,b.[Week]
	,SummaryCount
FROM PanelistSummaryCount a
INNER JOIN Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN Panel pan ON pan.GUIDReference = a.Panel_Id
INNER JOIN Panelist pst ON pst.GUIDReference = a.PanelistId
INNER JOIN individual ind ON ind.GUIDReference = pst.PanelMember_Id
INNER JOIN Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
INNER JOIN FullCalendars b ON a.CalendarPeriod_CalendarId = b.CalendarId
	AND a.CalendarPeriod_PeriodId = b.WeekId