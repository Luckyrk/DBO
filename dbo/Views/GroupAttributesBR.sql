
CREATE VIEW [dbo].[GroupAttributesBR]
AS
SELECT *
FROM [dbo].[FullGroupAttributesBR]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesBR].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesBR].CountryISO2A = dbo.CountryViewAccess.Country