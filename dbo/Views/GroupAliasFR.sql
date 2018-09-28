
CREATE VIEW [dbo].[GroupAliasFR]
AS
SELECT *
FROM [dbo].[FullGroupAliasFR]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAliasFR].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAliasFR].CountryISO2A = dbo.CountryViewAccess.Country