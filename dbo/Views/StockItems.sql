
CREATE VIEW [dbo].[StockItems]
AS
SELECT dbo.FullStockItems.CountryISO2A
	,dbo.FullStockItems.CategoryCode
	,dbo.FullStockItems.SerialNumber
	,dbo.FullStockItems.Description
	,dbo.FullStockItems.KitName
	,dbo.FullStockItems.Quantity
	,dbo.FullStockItems.TypeCode
	,dbo.FullStockItems.TypeName
	,dbo.FullStockItems.TypeQuantity
	,dbo.FullStockItems.WarningLimit
	,dbo.FullStockItems.PanelCode
	,dbo.FullStockItems.PanelName
	,dbo.FullStockItems.GPSUser
	,dbo.FullStockItems.GPSUpdateTimestamp
	,dbo.FullStockItems.CreationTimeStamp
FROM dbo.FullStockItems
CROSS JOIN dbo.CountryViewAccess
WHERE (
		dbo.CountryViewAccess.UserId = SUSER_SNAME()
		AND dbo.FullStockItems.CountryISO2A = dbo.CountryViewAccess.Country
		)