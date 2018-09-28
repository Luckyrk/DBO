
CREATE VIEW [dbo].[GroupAttributesMY]
AS
SELECT *
FROM [dbo].[FullGroupAttributesMY]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGroupAttributesMY].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullGroupAttributesMY].CountryISO2A = dbo.CountryViewAccess.Country