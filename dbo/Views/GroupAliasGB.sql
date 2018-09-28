
CREATE VIEW [dbo].[GroupAliasGB]
AS
SELECT *
FROM [dbo].[FullGroupAliasGB]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAliasGB].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAliasGB].CountryISO2A = dbo.CountryViewAccess.Country