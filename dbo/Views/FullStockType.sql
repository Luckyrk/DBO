  Create View FullStockType
  As
  SELECT b.CountryISO2A
      ,c.Code as CategoryCode
         ,d.Value as CategoryDescription
      ,a.[Code] as StockCode
      ,a.[Name] as StockName
      ,a.[Quantity]
      ,a.[WarningLimit]
      ,a.[GPSUser]
      ,a.[GPSUpdateTimestamp]
      ,a.[CreationTimeStamp]
  FROM [StockType] a
  Join Country b
  on b.CountryId = a.CountryId
  Left Join StockCategory c
  on c.GUIDReference = a.Category_Id
  Left Join TranslationTerm d
  on d.CultureCode = 2057
  and d.Translation_Id = c.Translation_Id
  
