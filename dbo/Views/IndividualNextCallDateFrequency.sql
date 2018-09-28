
CREATE VIEW [dbo].[IndividualNextCallDateFrequency]
	WITH SCHEMABINDING
AS
SELECT Distinct cr.CountryISO2A AS CountryCode
	,i.GUIDReference AS IndividualGUID
	,IndividualID
	,c.[Date] AS NextCallDate
	,t.KeyName AS Frequency
FROM dbo.Individual i
INNER JOIN dbo.Country cr ON i.CountryId = cr.CountryId
INNER JOIN dbo.CalendarEvent c ON i.Event_ID = c.ID
INNER JOIN dbo.EventFrequency e ON c.Frequency_Id = e.GUIDReference
INNER JOIN dbo.Translation t ON e.Translation_Id = t.TranslationId
INNER JOIN dbo.CountryViewAccess a ON cr.CountryISO2A = a.Country
WHERE a.UserId = SUSER_SNAME()
	AND c.[Date] IS NOT NULL