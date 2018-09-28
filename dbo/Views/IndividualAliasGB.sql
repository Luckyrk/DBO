
CREATE VIEW [dbo].[IndividualAliasGB]
AS
SELECT *
FROM [dbo].[FullIndividualAliasGB]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAliasGB].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAliasGB].CountryISO2A = dbo.CountryViewAccess.Country