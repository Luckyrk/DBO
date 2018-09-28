GO
/* As Per Sunil StockItemHistory is iscoloatec, due to that we have commend the below h.countryid condition  */
CREATE VIEW [dbo].[FullPanelistDevices]
AS
Select x.CountryISO2A
,x.SerialNumber
,x.DeviceCode
,x.DeviceName
,x.KitStatus
,x.Household
,x.GPSUser
,x.DateofChange
,x.KitLocation
From
(SELECT  b.CountryISO2A
      ,[SerialNumber]
      ,c.Code as DeviceCode
         ,c.Name as DeviceName
         ,d.Code as KitStatus
      ,f.Sequence as Household
      ,a.[GPSUser]
      ,n.CreationDate as DateofChange
         ,case  
            when h.Location is not null then CAST(h.Location as varchar)
            when l.Sequence is not null then CAST(l.sequence as varchar)
       End as KitLocation
          , ROW_NUMBER() OVER(PARTITION BY a.SerialNumber Order by n.CreationDate desc) as Row
  FROM [StockItem] a
  Join Country b
  on b.CountryId = a.Country_Id
  Join StockType c
  on c.GUIDReference = a.[Type_Id]
  Join StateDefinition d
  on d.Id = a.State_Id
  Left Join Panelist e
  on e.GUIDReference = a.Panelist_Id
  Join Collective f
  on f.GUIDReference = e.PanelMember_Id
  Join StockLocation g
  on g.GUIDReference = a.Location_Id
  Left Join GenericStockLocation h
  on h.GUIDReference = g.GUIDReference
  Left Join StockPanelistLocation j
  on j.GUIDReference = g.GUIDReference
  Left Join Panelist k
  on k.GUIDReference = j.Panelist_Id
  Left Join Collective l
  on l.GUIDReference = k.PanelMember_Id 
  Join StockStateDefinitionHistory m
  on m.StockItem_Id = a.GUIDReference
  Join StateDefinitionHistory n
  on n.GUIDReference = m.GUIDReference
  ) x
  where Row = 1

  GO
