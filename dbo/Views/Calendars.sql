
CREATE VIEW [dbo].[Calendars]
AS
SELECT [CountryISO2A]
	,[CalendarDescription]
	,[PeriodTypeDescription]
	,[FullPeriod]
	,[Year]
	,[Period]
	,[Week]
	,[PeriodLevelFour]
	,[StartDate]
	,[EndDate]
	,[PanelCode]
	,[PanelName]
	,[CalendarId]
	,[YearId]
	,[PeriodId]
	,[WeekId]
	,[PeriodLevelFourId]
FROM [dbo].[FullCalendars]
CROSS JOIN dbo.CountryViewAccess
WHERE (
		dbo.CountryViewAccess.UserId = SUSER_SNAME()
		AND dbo.FullCalendars.CountryISO2A = dbo.CountryViewAccess.Country
		)