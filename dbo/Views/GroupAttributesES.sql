
CREATE VIEW [dbo].[GroupAttributesES]
AS
SELECT *
FROM [dbo].[FullGroupAttributesES]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesES].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesES].CountryISO2A = dbo.CountryViewAccess.Country