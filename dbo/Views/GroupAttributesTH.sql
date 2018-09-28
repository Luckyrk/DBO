
CREATE VIEW [dbo].[GroupAttributesTH]
AS
SELECT *
FROM [dbo].[FullGroupAttributesTH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesTH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesTH].CountryISO2A = dbo.CountryViewAccess.Country