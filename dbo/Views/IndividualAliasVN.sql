
CREATE VIEW [dbo].[IndividualAliasVN]
AS
SELECT *
FROM [dbo].[FullIndividualAliasVN]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAliasVN].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAliasVN].CountryISO2A = dbo.CountryViewAccess.Country

GO

