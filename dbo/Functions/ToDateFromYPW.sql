CREATE FUNCTION dbo.ToDateFromYPW 
(	
	-- Add the parameters for the function here
	@Year int,
	@Period int,
	@Week int,
	@panelcode int, 
	@countryCode varchar(10)
)
RETURNS TABLE 
AS
RETURN 
(SELECT cpweek.StartDate
	,cp.periodvalue AS [Year]
	,cpperiod.PeriodValue AS [Period]
	,cpweek.PeriodValue AS [Week]
	,DATEADD(wk,DATEPART(week, cpweek.StartDate)-1,DATEADD(yy,@Year-1900,0)) AS WeekStart
	,DATENAME(dw,DATEADD(wk,DATEPART(week, cpweek.StartDate)-1,DATEADD(yy,@Year-1900,0))) as WeekStartDay
FROM PanelCalendarMapping pcm
INNER JOIN panel p ON p.GUIDReference = pcm.PanelID
	AND p.Country_Id = pcm.OwnerCountryId
INNER JOIN CalendarPeriodHierarchy cphweek ON cphweek.CalendarId = pcm.CalendarID
	AND cphweek.SequenceWithinHierarchy = 2
INNER JOIN CalendarPeriod cpweek ON cpweek.CalendarId = cphweek.CalendarId
	AND cpweek.PeriodTypeId = cphweek.ChildPeriodTypeId and cpweek.PeriodValue=@Week
	
INNER JOIN CalendarPeriodHierarchy cphyear ON cphyear.CalendarId = pcm.CalendarID
	AND cphyear.SequenceWithinHierarchy = 1
INNER JOIN calendarperiod cp ON cp.CalendarId = cphyear.CalendarID
	AND cp.PeriodTypeId = cphyear.ParentPeriodTypeId
	AND cp.StartDate <= cpweek.StartDate
	AND cp.EndDate >= cpweek.EndDate and cp.PeriodValue=@Year
INNER JOIN CalendarPeriod cpperiod ON cpperiod.CalendarId = cphyear.calendarid
	AND cpperiod.PeriodTypeId = cphyear.ChildPeriodTypeId
	AND cpperiod.StartDate <= cpweek.StartDate
	AND cpperiod.EndDate >= cpweek.EndDate and cpperiod.PeriodValue=@Period
INNER JOIN country c ON c.CountryId = p.Country_Id
	AND p.PanelCode = @panelcode
	AND c.CountryISO2A = 'TW'
)