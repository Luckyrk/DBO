
CREATE VIEW [dbo].[GeographicAreaAttributesTH]
AS
SELECT *
FROM [dbo].[FullGeographicAreaAttributesTH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesTH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND [dbo].[FullGeographicAreaAttributesTH].CountryISO2A = dbo.CountryViewAccess.Country