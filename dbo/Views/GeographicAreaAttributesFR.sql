
CREATE VIEW [dbo].[GeographicAreaAttributesFR]
AS
SELECT *
FROM [dbo].[FullGeographicAreaAttributesFR]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesFR].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND [dbo].[FullGeographicAreaAttributesFR].CountryISO2A = dbo.CountryViewAccess.Country