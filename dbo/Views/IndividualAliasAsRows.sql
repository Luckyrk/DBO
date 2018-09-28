
CREATE VIEW [dbo].[IndividualAliasAsRows]
AS
SELECT [CountryISO2A]
	,[IndividualID]
	,[Alias]
	,[AliasType]
	,[Context]
FROM [dbo].[FullIndividualAliasAsRows]
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualAliasAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullIndividualAliasAsRows.CountryISO2A = dbo.CountryViewAccess.Country