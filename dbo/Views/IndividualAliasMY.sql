
CREATE VIEW [dbo].[IndividualAliasMY]
AS
SELECT *
FROM [dbo].[FullIndividualAliasMY]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAliasMY].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAliasMY].CountryISO2A = dbo.CountryViewAccess.Country