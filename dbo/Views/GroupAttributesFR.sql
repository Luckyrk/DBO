
CREATE VIEW [dbo].[GroupAttributesFR]
AS
SELECT *
FROM [dbo].[FullGroupAttributesFR]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesFR].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesFR].CountryISO2A = dbo.CountryViewAccess.Country