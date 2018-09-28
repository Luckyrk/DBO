-- =============================================
-- Author:		Sunil Kumar Kattamuri
-- Create date: 30/03/2014
-- Description:	Function will return the period,week , year and also current week of the year
-- =============================================
CREATE FUNCTION dbo.GetYPWandWeekOfYearFromDate 
(	
	-- Add the parameters for the function here
	@date varchar(100),
	@panelcode int, 
	@countryCode varchar(10)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT cpweek.StartDate
	,cp.periodvalue AS [Year]
	,cpperiod.PeriodValue AS [Period]
	,cpweek.PeriodValue AS [Week]
	,DATEPART(week, @date) AS WeekofYear
FROM PanelCalendarMapping pcm
INNER JOIN panel p ON p.GUIDReference = pcm.PanelID
	AND p.Country_Id = pcm.OwnerCountryId
INNER JOIN CalendarPeriodHierarchy cphweek ON cphweek.CalendarId = pcm.CalendarID
	AND cphweek.SequenceWithinHierarchy = 2
INNER JOIN CalendarPeriod cpweek ON cpweek.CalendarId = cphweek.CalendarId
	AND cpweek.PeriodTypeId = cphweek.ChildPeriodTypeId
	AND cpweek.EndDate >= CONVERT(VARCHAR(10), @date, 110)
	AND cpweek.StartDate <= CONVERT(VARCHAR(121), @date, 110)
INNER JOIN CalendarPeriodHierarchy cphyear ON cphyear.CalendarId = pcm.CalendarID
	AND cphyear.SequenceWithinHierarchy = 1
INNER JOIN calendarperiod cp ON cp.CalendarId = cphyear.CalendarID
	AND cp.PeriodTypeId = cphyear.ParentPeriodTypeId
	AND cp.StartDate <= cpweek.StartDate
	AND cp.EndDate >= cpweek.EndDate
INNER JOIN CalendarPeriod cpperiod ON cpperiod.CalendarId = cphyear.calendarid
	AND cpperiod.PeriodTypeId = cphyear.ChildPeriodTypeId
	AND cpperiod.StartDate <= cpweek.StartDate
	AND cpperiod.EndDate >= cpweek.EndDate
INNER JOIN country c ON c.CountryId = p.Country_Id
	AND p.PanelCode = @panelcode
	AND c.CountryISO2A = @countryCode
)