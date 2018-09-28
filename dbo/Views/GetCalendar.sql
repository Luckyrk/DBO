
CREATE VIEW [dbo].[GetCalendar]
AS
SELECT CT.CountryISO2A
	,C.GUIDReference AS Id
	,C.CalendarDescription AS Description
FROM Calendar C
	,Country CT
WHERE CT.CountryId = C.Country_Id