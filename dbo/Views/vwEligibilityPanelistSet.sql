
CREATE VIEW [dbo].[vwEligibilityPanelistSet]
AS
SELECT i.IndividualId AS 'BusinessId'
	,p.PanelCode AS 'PanelCode'
	,ct.CountryISO2A AS 'CountryCode'
	,cp.CalendarId
	,cp.PeriodId AS 'WeekPeriodId'
	,COUNT(*) AS 'DiaryCount'
	,ps.SummaryCount AS 'PurchaseCount'
	,de.DiaryDateYear
	,de.DiaryDatePeriod
	,de.DiaryDateWeek
FROM DiaryEntry de
INNER JOIN Individual i ON i.IndividualId = de.BusinessId
INNER JOIN Panel p ON p.guidreference = de.panelid
INNER JOIN country ct ON ct.CountryId = p.Country_id
INNER JOIN Panelist pl ON pl.Panelmember_id = (
		SELECT [dbo].[fn_PanelMember_id_businessId](de.PanelId, de.BusinessId)
		)
	AND pl.Panel_id = de.panelid
INNER JOIN CalendarPeriod cp ON cp.CalendarId = (
		SELECT dbo.fn_getCalendarId_DiaryEntry(de.PanelId, de.CreationTimeStamp)
		)
	AND cp.PeriodId = (
		SELECT dbo.fn_GetPeriodId_DiaryEntry(de.PanelId, de.CreationTimeStamp, de.DiaryDateYear, de.DiaryDatePeriod, de.DiaryDateWeek)
		)
LEFT JOIN PanelistSummaryCount ps ON ps.PanelistId = pl.guidreference
	AND ps.Panel_Id = de.PanelId
	AND ps.CalendarPeriod_PeriodId = cp.Periodid
	AND ps.CalendarPeriod_Calendarid = cp.Calendarid
GROUP BY de.DiaryDatePeriod
	,de.DiaryDateYear
	,p.PanelCode
	,ct.CountryISO2A
	,i.IndividualId
	,cp.CalendarId
	,cp.PeriodId
	,ps.SummaryCount
	,de.DiaryDateWeek
 