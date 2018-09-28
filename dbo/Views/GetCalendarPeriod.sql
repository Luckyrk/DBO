
CREATE VIEW [dbo].[GetCalendarPeriod]
AS
SELECT CT.CountryISO2A
	,YEAR(startdate) Year
	,cp.PeriodValue
	,PeriodId AS Id
	,c.CalendarDescription + '--' + Convert(VARCHAR(6), YEAR(StartDate)) + '- Period(' + Convert(VARCHAR(50), PeriodValue) + ')' AS Description
FROM CalendarPeriod CP
INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = CP.CalendarID
	AND cph.SequenceWithinHierarchy = 2
INNER JOIN Calendar C ON c.GUIDReference = cp.CalendarId
	AND cp.PeriodTypeId = cph.ParentPeriodTypeId
INNER JOIN Country CT ON ct.CountryId = C.Country_Id

UNION

SELECT CT.CountryISO2A
	,YEAR(startdate) Year
	,cp.PeriodValue
	,PeriodId AS Id
	,c.CalendarDescription + '--' + Convert(VARCHAR(6), YEAR(StartDate)) + '- period(' + Convert(VARCHAR(50), PeriodValue) + ')' AS Description
FROM PanelCalendarMapping pc
INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = pc.CalendarID
	AND cph.SequenceWithinHierarchy = 2
INNER JOIN CalendarPeriod CP ON cp.CalendarId = pc.CalendarID
	AND cp.PeriodTypeId = cph.ParentPeriodTypeId
INNER JOIN Calendar C ON c.GUIDReference = pc.CalendarID
INNER JOIN Country CT ON ct.CountryId = pc.OwnerCountryId