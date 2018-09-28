
CREATE VIEW [dbo].[GroupAttributesAsRows]
AS
SELECT [CountryISO2A]
	,[GroupId]
	,[Key]
	,[Value]
	,[FreeText]
FROM [dbo].[FullGroupAttributesAsRows]
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroupAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country