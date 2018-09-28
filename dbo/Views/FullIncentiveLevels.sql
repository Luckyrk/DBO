
CREATE VIEW [dbo].[FullIncentiveLevels]
WITH SCHEMABINDING
AS
SELECT     [dbo].Country.CountryISO2A, [dbo].IncentiveLevel.Code LevelCode, [dbo].IncentiveLevel.Description, [dbo].IncentiveLevelValue.LevelValue, [dbo].IncentiveLevelValue.CanOverride, 
                      [dbo].IncentivePoint.Code AS PointCode, [dbo].IncentivePoint.Value, [dbo].IncentivePoint.HasUpdateableValue, [dbo].IncentivePoint.HasAllPanels, [dbo].IncentivePoint.RewardCode, 
                      [dbo].IncentivePoint.ValidFrom, [dbo].IncentivePoint.ValidTo, [dbo].IncentivePoint.CostPrice, [dbo].IncentivePoint.RewardSource, [dbo].IncentivePoint.HasStockControl, [dbo].IncentivePoint.StockLevel, 
                      [dbo].IncentivePoint.Type PointType, [dbo].IncentivePoint.GiftPrice, [dbo].IncentivePoint.Minimum, [dbo].IncentivePoint.Maximum, [dbo].IncentiveSupplier.Code AS SupplierCode, [dbo].IncentiveSupplier.Description AS SupplierDescription
FROM        [dbo].Country INNER JOIN
                      [dbo].IncentiveLevel ON [dbo].Country.CountryId = [dbo].IncentiveLevel.Country_Id INNER JOIN
                      [dbo].IncentiveLevelValue ON [dbo].Country.CountryId = [dbo].IncentiveLevelValue.Country_Id AND [dbo].IncentiveLevel.GUIDReference = [dbo].IncentiveLevelValue.IncentiveLevel_Id INNER JOIN
                      [dbo].IncentivePoint ON [dbo].IncentiveLevelValue.Incentive_Id = [dbo].IncentivePoint.GUIDReference LEFT JOIN
                      [dbo].IncentiveSupplier ON [dbo].Country.CountryId = [dbo].IncentiveSupplier.Country_Id AND [dbo].IncentivePoint.SupplierId = [dbo].IncentiveSupplier.IncentiveSupplierId