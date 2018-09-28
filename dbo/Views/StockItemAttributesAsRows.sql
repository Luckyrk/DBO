CREATE VIEW [dbo].[StockItemAttributesAsRows]
AS
SELECT *
FROM [dbo].[FullStockItemAttributesAsRows]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullStockItemAttributesAsRows].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullStockItemAttributesAsRows].CountryISO2A = dbo.CountryViewAccess.Country

