
CREATE VIEW [dbo].[IndividualAttributesFR]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesFR]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesFR].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesFR].CountryISO2A = dbo.CountryViewAccess.Country