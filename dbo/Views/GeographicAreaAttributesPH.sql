
CREATE VIEW [dbo].[GeographicAreaAttributesPH]
AS
SELECT *
FROM [dbo].[FullGeographicAreaAttributesPH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesPH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND [dbo].[FullGeographicAreaAttributesPH].CountryISO2A = dbo.CountryViewAccess.Country