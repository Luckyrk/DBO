CREATE VIEW [dbo].[SummaryCount]
	WITH schemabinding
AS
SELECT a.CountryISO2A
	,a.PanelCode
	,a.PanelName
	,a.CollaborationMethodology
	,a.CategoryCode
	,a.CategoryDescription
	,a.[SummaryCount]
	,a.FullPeriod
	,a.[Year]
	,a.[Period]
	,a.[Week]
	,a.PeriodLevelFour
	,a.[PanelistId]
	,a.[MainShopper]
	,a.[CalendarId]
	,a.[CalendarTypePeriodId]
FROM [dbo].[FullSummaryCount] a
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND a.CountryISO2A = dbo.CountryViewAccess.Country