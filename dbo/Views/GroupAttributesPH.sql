
CREATE VIEW [dbo].[GroupAttributesPH]
AS
SELECT *
FROM [dbo].[FullGroupAttributesPH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesPH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesPH].CountryISO2A = dbo.CountryViewAccess.Country