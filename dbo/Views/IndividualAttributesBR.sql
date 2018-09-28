
CREATE VIEW [dbo].[IndividualAttributesBR]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesBR]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesBR].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesBR].CountryISO2A = dbo.CountryViewAccess.Country