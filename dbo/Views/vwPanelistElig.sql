
CREATE VIEW [dbo].[vwPanelistElig]
AS
SELECT DISTINCT i.IndividualId AS 'BusinessId'
	,p.PanelCode AS 'PanelCode'
	,ct.CountryISO2A AS 'CountryCode'
	,de.weekperiod AS 'WeekPeriodid'
	,de.periodId AS 'PeriodId'
	,de.CalendarId
	,sc.Description
	,ps.SummaryCount
	,de.DiaryDateYear
	,de.DiaryDatePeriod
	,de.DiaryDateWeek
FROM vwDiaryEntry_PeriodId de
INNER JOIN Individual i ON i.IndividualId = de.BusinessId
INNER JOIN Panel p ON p.guidreference = de.panelid
INNER JOIN country ct ON ct.CountryId = p.Country_id
INNER JOIN Panelist pl ON pl.Panelmember_id = de.PanelMember_Id
	AND pl.Panel_id = de.panelid
	AND ct.CountryId = pl.Country_Id
LEFT JOIN PanelistSummaryCount ps ON ps.PanelistId = pl.guidreference
	AND ps.Panel_Id = de.PanelId
	AND ps.CalendarPeriod_PeriodId = de.weekPeriod
	AND ps.CalendarPeriod_Calendarid = de.CalendarId
INNER JOIN Summary_Category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId