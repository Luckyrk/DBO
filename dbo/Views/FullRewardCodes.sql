GO
CREATE VIEW [dbo].[FullRewardCodes]
AS 
SELECT  C.CountryISO2A
         ,[RewardCode]
         ,a.[Code]
       ,d.Value as PointDescription
      ,a.[Value] as PointValue
      ,[HasUpdateableValue]
      ,[HasAllPanels]
         ,a.[Type]
      ,b.[Type] as AccountType
      ,a.[GPSUser]
      ,a.[GPSUpdateTimestamp]
      ,a.[CreationTimeStamp]
  FROM [IncentivePoint] a
  Join IncentivePointAccountEntryType b
  on b.GUIDReference = a.[Type_Id]
  Join Country c
  on c.CountryId = b.Country_Id
  Join TranslationTerm d
  on d.Translation_Id = a.Description_Id
  and d.CultureCode = 2057
  where a.[Type] = 'Reward'

GO
