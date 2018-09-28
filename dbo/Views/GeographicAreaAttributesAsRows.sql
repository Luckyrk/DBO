
CREATE VIEW [dbo].[GeographicAreaAttributesAsRows]
AS
SELECT [CountryISO2A]
	,[Code]
	,[Key]
	,[Attribute]
	,[Value]
FROM [dbo].[FullGeographicAreaAttributesAsRows]
INNER JOIN dbo.CountryViewAccess ON dbo.FullGeographicAreaAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGeographicAreaAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country