
CREATE VIEW [dbo].[GroupAliasAsRows]
AS
SELECT [CountryISO2A]
	,[GroupId]
	,[Alias]
	,[AliasType]
	,[Context]
FROM [dbo].[FullGroupAliasAsRows]
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupAliasAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroupAliasAsRows.CountryISO2A = dbo.CountryViewAccess.Country