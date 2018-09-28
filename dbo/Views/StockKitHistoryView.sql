
CREATE VIEW [dbo].[StockKitHistoryView]
AS
SELECT [CountryISO2A]
	,[FromCode]
	,[FromName]
	,[ToCode]
	,[ToName]
	,[ReasonCode]
	,[ReasonDescription]
	,[Panelist_Id]
	,[PanelCode]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,[GUIDReference]
FROM [dbo].[FullStockKitHistory]
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullStockKitHistory.CountryISO2A = dbo.CountryViewAccess.Country