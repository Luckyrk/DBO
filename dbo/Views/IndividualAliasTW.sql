
CREATE VIEW [dbo].[IndividualAliasTW]
AS
SELECT *
FROM [dbo].[FullIndividualAliasTW]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAliasTW].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAliasTW].CountryISO2A = dbo.CountryViewAccess.Country