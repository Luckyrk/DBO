
CREATE VIEW [dbo].[StockItemStatus]
AS
SELECT [CountryISO2A]
	,[SerialNumber]
	,[IndividualId]
	,[PanelCode]
	,[StockDescription]
	,[Location]
	,[StateTransitionDate]
	,[StateTransitionCreationDate]
	,[CurrentStockState]
FROM [dbo].[FullStockItemStatus]
INNER JOIN dbo.CountryViewAccess ON dbo.FullStockItemStatus.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullStockItemStatus.CountryISO2A = dbo.CountryViewAccess.Country