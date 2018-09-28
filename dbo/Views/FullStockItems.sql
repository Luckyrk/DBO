
CREATE VIEW [dbo].[FullStockItems]
AS
SELECT [dbo].Country.CountryISO2A
	,[dbo].StockCategory.Code CategoryCode
	,[dbo].StockItem.SerialNumber
	,[dbo].StockItem.Description
	,[dbo].StockKit.NAME AS KitName
	,[dbo].StockKitItem.Quantity
	,[dbo].StockType.Code TypeCode
	,[dbo].StockType.NAME AS TypeName
	,[dbo].StockType.Quantity AS TypeQuantity
	,[dbo].StockType.WarningLimit
	,[dbo].Panel.PanelCode
	,[dbo].Panel.NAME PanelName
	,[dbo].StockItem.GPSUser
	,[dbo].StockItem.GPSUpdateTimestamp
	,[dbo].StockItem.CreationTimeStamp
FROM [dbo].StockCategory
INNER JOIN [dbo].StockType ON [dbo].StockCategory.GUIDReference = [dbo].StockType.Category_Id
INNER JOIN [dbo].StockItem ON [dbo].StockType.GUIDReference = [dbo].StockItem.Type_Id
INNER JOIN [dbo].StockLocation ON [dbo].StockLocation.GUIDReference = [dbo].StockItem.Location_Id
INNER JOIN [dbo].StockKitItem ON [dbo].StockType.GUIDReference = [dbo].StockKitItem.StockType_Id
INNER JOIN [dbo].StockKit ON [dbo].StockKit.GUIDReference = [dbo].StockKitItem.StockKit_Id
INNER JOIN [dbo].StockTypePanel ON [dbo].StockType.GUIDReference = [dbo].StockTypePanel.StockType_Id
INNER JOIN [dbo].Country ON [dbo].StockKit.Country_Id = [dbo].Country.CountryId
INNER JOIN [dbo].Panel ON [dbo].Panel.GUIDReference = [dbo].StockTypePanel.Panel_Id