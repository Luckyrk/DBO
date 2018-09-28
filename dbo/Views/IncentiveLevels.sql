
CREATE VIEW [dbo].[IncentiveLevels]
AS
SELECT    [dbo].[FullIncentiveLevels].CountryISO2A, [dbo].[FullIncentiveLevels].LevelCode, [dbo].[FullIncentiveLevels].Description, [dbo].[FullIncentiveLevels].LevelValue, [dbo].[FullIncentiveLevels].CanOverride, 
                      [dbo].[FullIncentiveLevels].PointCode, [dbo].[FullIncentiveLevels].Value, [dbo].[FullIncentiveLevels].HasUpdateableValue, [dbo].[FullIncentiveLevels].HasAllPanels, [dbo].[FullIncentiveLevels].RewardCode, 
                      [dbo].[FullIncentiveLevels].ValidFrom, [dbo].[FullIncentiveLevels].ValidTo, [dbo].[FullIncentiveLevels].CostPrice, [dbo].[FullIncentiveLevels].RewardSource, [dbo].[FullIncentiveLevels].HasStockControl, [dbo].[FullIncentiveLevels].StockLevel, 
                      [dbo].[FullIncentiveLevels].PointType, [dbo].[FullIncentiveLevels].GiftPrice, [dbo].[FullIncentiveLevels].Minimum, [dbo].[FullIncentiveLevels].Maximum, [dbo].[FullIncentiveLevels].SupplierCode, [dbo].[FullIncentiveLevels].SupplierDescription
FROM         dbo.FullIncentiveLevels INNER JOIN
                      dbo.CountryViewAccess ON dbo.FullIncentiveLevels.CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) AND dbo.FullIncentiveLevels.CountryISO2A = dbo.CountryViewAccess.Country