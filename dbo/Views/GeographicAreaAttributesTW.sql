
CREATE VIEW [dbo].[GeographicAreaAttributesTW]
AS
SELECT *
FROM [dbo].[FullGeographicAreaAttributesTW]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesTW].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND [dbo].[FullGeographicAreaAttributesTW].CountryISO2A = dbo.CountryViewAccess.Country