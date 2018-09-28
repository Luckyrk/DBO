
CREATE VIEW [dbo].[GeographicAreaAttributesES]
AS
SELECT *
FROM [dbo].[FullGeographicAreaAttributesES]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesES].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND [dbo].[FullGeographicAreaAttributesES].CountryISO2A = dbo.CountryViewAccess.Country