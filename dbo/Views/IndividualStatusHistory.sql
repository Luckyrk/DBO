
CREATE VIEW [dbo].[IndividualStatusHistory]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[GPSUser]
	,[Date]
	,[FromState]
	,[ToState]
	,[ReasonCode]
FROM [dbo].[FullIndividualStatusHistory]
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualStatusHistory.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullIndividualStatusHistory.CountryISO2A = dbo.CountryViewAccess.Country