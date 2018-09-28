
CREATE VIEW [dbo].[GeographicAreaAttributesMY]
AS
SELECT *
FROM [dbo].[FullGeographicAreaAttributesMY]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesMY].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND [dbo].[FullGeographicAreaAttributesMY].CountryISO2A = dbo.CountryViewAccess.Country