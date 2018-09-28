CREATE VIEW [dbo].[GroupAttributesTW]
AS
SELECT *
FROM [dbo].[FullGroupAttributesTW]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesTW].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesTW].CountryISO2A = dbo.CountryViewAccess.Country