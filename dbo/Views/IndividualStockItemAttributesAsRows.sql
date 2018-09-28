CREATE VIEW [dbo].[IndividualStockItemAttributesAsRows]
AS
SELECT *
FROM [dbo].[FullIndividualStockItemAttributesAsRows]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualStockItemAttributesAsRows].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualStockItemAttributesAsRows].CountryISO2A = dbo.CountryViewAccess.Country

