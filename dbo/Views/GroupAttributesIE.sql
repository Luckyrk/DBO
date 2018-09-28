
CREATE VIEW [dbo].[GroupAttributesIE]
AS
SELECT *
FROM [dbo].[FullGroupAttributesIE]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesIE].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesIE].CountryISO2A = dbo.CountryViewAccess.Country