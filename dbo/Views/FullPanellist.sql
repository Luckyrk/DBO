Create View FullPanellist
As
SELECT 
      c.CountryISO2A
      ,d.PanelCode
         ,d.Name as PanelName
         ,d.Type
         ,e.Sequence as GroupId
         ,f.IndividualId
         ,b.Code as IncentiveCode
         ,b.Description as IncentiveDescription
              ,g.Code as StateCode
              ,h.Code as StockCode
              ,h.Name as KitName
  FROM [Panelist] a
  Join IncentiveLevel b
  on b.GUIDReference = a.IncentiveLevel_Id
  Join Country c
  on c.CountryId = a.Country_Id
  Join Panel d
  on d.GUIDReference = a.Panel_Id
  Left Join Collective e
  on e.GUIDReference = a.PanelMember_Id
  Left Join Individual f
  on f.GUIDReference = a.PanelMember_Id
  Join StateDefinition g
  on g.Id = a.State_Id
  Left join StockKit h
  on h.GUIDReference = a.ExpectedKit_Id
