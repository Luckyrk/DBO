
CREATE VIEW [dbo].[FullGroupKitandContactGB]
as
select x.*
from
(SELECT 
dbo.Country.CountryISO2A
      ,dbo.Panel.PanelCode
      ,dbo.Panel.NAME PanelDesc
      ,dbo.Panel.Type 
      , col.Sequence as HouseholdNumber
         ,Sd1.Code as CurrentState
         ,SdH1.GPSUser
         ,SdH1.CreationDate as StateChangeDate
         ,DroppedOffDate
         ,LiveDate
         ,ind.IndividualId as GroupMainContact
      ,dbo.StockKit.Code KitType
      ,dbo.StockKit.Name KitDesc
         ,ROW_NUMBER()
         OVER(PARTITION BY PanelCode, col.Sequence Order by SdH1.CreationDate desc) as Row
FROM dbo.Panel
INNER JOIN dbo.Country ON dbo.Panel.Country_Id = dbo.Country.CountryId
and Country.CountryISO2A = 'GB'
and Panel.PanelCode = 27
INNER JOIN dbo.Panelist ON dbo.Panel.GUIDReference = dbo.Panelist.Panel_Id
LEFT JOIN dbo.StockKit ON dbo.Panelist.ExpectedKit_Id = dbo.StockKit.GUIDReference
INNER join dbo.Collective col on col.GUIDReference = dbo.Panelist.PanelMember_Id
Inner Join Individual ind on Ind.GUIDReference = col.GroupContact_Id
Inner Join StateDefinition Sd1 on Sd1.Id = Panelist.State_Id
Inner Join StateDefinitionHistory SdH1 on SdH1.Panelist_Id = Panelist.GUIDReference
LEFT JOIN (
       Select Hist2.Panelist_Id, MAX(CreationDate) DroppedOffDate
       FROM dbo.StateDefinitionHistory HIST2
       Join StateDefinition Sd2 on Sd2.Id = HIST2.To_Id
       Join Country on Hist2.Country_Id = Country.CountryId
       and Country.CountryISO2A = 'GB'
       WHERE SD2.Code = 'PanelistDroppedOffState'
       Group by Hist2.Panelist_Id
       ) AS DROPDATE 
       on DROPDATE.Panelist_Id = Panelist.GUIDReference
LEFT JOIN (
       Select Hist3.Panelist_Id, MAX(CreationDate) LiveDate
       FROM dbo.StateDefinitionHistory HIST3
       Join StateDefinition Sd2 on Sd2.Id = HIST3.To_Id
       Join Country on Hist3.Country_Id = Country.CountryId
       and Country.CountryISO2A = 'GB'
       WHERE SD2.Code = 'PanelistLiveState'
       Group by Hist3.Panelist_Id
       ) AS LIVEDATE 
       on LIVEDATE.Panelist_Id = Panelist.GUIDReference
) x
where Row = 1