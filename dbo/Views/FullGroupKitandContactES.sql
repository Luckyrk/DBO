Create view [dbo].[FullGroupKitandContactES]
as
SELECT 
dbo.Country.CountryISO2A
      ,dbo.Panel.PanelCode
      ,dbo.Panel.NAME PanelDesc
      ,dbo.Panel.Type 
      , col.Sequence as HouseholdNumber
         ,Sd1.Code as CurrentState
         ,SdH1.GPSUser
         ,SdH1.CreationTimeStamp as StateChangeDate
         ,DroppedOffDate
         ,LiveDate
         ,ind.IndividualId as GroupMainContact
      ,dbo.StockKit.Code KitType
      ,dbo.StockKit.Name KitDesc
FROM dbo.Panel
INNER JOIN dbo.Country ON dbo.Panel.Country_Id = dbo.Country.CountryId
and Country.CountryISO2A = 'ES'
INNER JOIN dbo.Panelist ON dbo.Panel.GUIDReference = dbo.Panelist.Panel_Id
LEFT JOIN dbo.StockKit ON dbo.Panelist.ExpectedKit_Id = dbo.StockKit.GUIDReference
INNER join dbo.Collective col on col.GUIDReference = dbo.Panelist.PanelMember_Id
Inner Join Individual ind on Ind.GUIDReference = col.GroupContact_Id
Inner Join StateDefinition Sd1 on Sd1.Id = Panelist.State_Id
Inner Join StateDefinitionHistory SdH1 on SdH1.Panelist_Id = Panelist.GUIDReference
and SdH1.To_Id = Panelist.State_Id
LEFT JOIN (
       Select Hist2.Panelist_Id, MAX(CreationDate) DroppedOffDate
       FROM dbo.StateDefinitionHistory HIST2
       Join StateDefinition Sd2 on Sd2.Id = HIST2.To_Id
       Join Country on Hist2.Country_Id = Country.CountryId
       and Country.CountryISO2A = 'ES'
       WHERE SD2.Code = 'PanelistDroppedOffState'
       Group by Hist2.Panelist_Id
       ) AS DROPDATE 
       on DROPDATE.Panelist_Id = Panelist.GUIDReference
LEFT JOIN (
       Select Hist3.Panelist_Id, MAX(CreationDate) LiveDate
       FROM dbo.StateDefinitionHistory HIST3
       Join StateDefinition Sd2 on Sd2.Id = HIST3.To_Id
       Join Country on Hist3.Country_Id = Country.CountryId
       and Country.CountryISO2A = 'ES'
       WHERE SD2.Code = 'PanelistLiveState'
       Group by Hist3.Panelist_Id
       ) AS LIVEDATE 
       on LIVEDATE.Panelist_Id = Panelist.GUIDReference

GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelCode  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'PanelCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelDesc  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'PanelDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Type  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'HouseholdNumber  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'HouseholdNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CurrentState  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'CurrentState'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUser  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'GPSUser'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'StateChangeDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'StateChangeDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DroppedOffDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'DroppedOffDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LiveDate  - the date a Panellist joined the Panel, and started returning data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'LiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupMainContact  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'GroupMainContact'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'KitType  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'KitType'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'KitDesc  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES', @level2type=N'COLUMN',@level2name=N'KitDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'FullGroupKitandContactES,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Kit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country specific - GB data only. Provides details of the Kit type and description, allocated to a household also showing the Panellist State and, if dropped off, the drop off date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupKitandContactES'
GO
