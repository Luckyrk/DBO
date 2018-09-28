
CREATE VIEW [dbo].[IndividualAttributesAsRows]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[Key]
	,[Value]
	,[FreeText]
FROM [dbo].[FullIndividualAttributesAsRows]
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullIndividualAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country