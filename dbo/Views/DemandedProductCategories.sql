
CREATE VIEW [dbo].[DemandedProductCategories]
AS
SELECT [CountryISO2A]
	,[ProductCode]
	,[ProductDescription]
FROM [dbo].[FullDemandedProductCategories]
INNER JOIN dbo.CountryViewAccess ON dbo.FullDemandedProductCategories.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullDemandedProductCategories.CountryISO2A = dbo.CountryViewAccess.Country