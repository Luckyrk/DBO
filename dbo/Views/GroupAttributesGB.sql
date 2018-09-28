
CREATE VIEW [dbo].[GroupAttributesGB]
AS
SELECT *
FROM [dbo].[FullGroupAttributesGB]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesGB].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesGB].CountryISO2A = dbo.CountryViewAccess.Country