CREATE TABLE [dbo].[StockItem] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Type_Id]            UNIQUEIDENTIFIER NOT NULL,
    [State_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Panelist_Id]        UNIQUEIDENTIFIER NULL,
    [Location_Id]        UNIQUEIDENTIFIER NULL,
    [SerialNumber]       NVARCHAR (40)    NOT NULL,
    [Description]        NVARCHAR (200)   NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.StockItem] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockItem_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StockItem_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockItem_dbo.Respondent_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Respondent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockItem_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.StockItem_dbo.StockLocation_Location_Id] FOREIGN KEY ([Location_Id]) REFERENCES [dbo].[StockLocation] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockItem_dbo.StockType_Type_Id] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[StockType] ([GUIDReference]),
    CONSTRAINT [Un_TypeSerialNoCountry] UNIQUE NONCLUSTERED ([Type_Id] ASC, [SerialNumber] ASC, [Country_Id] ASC)
);










GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[StockItem]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Type_Id]
    ON [dbo].[StockItem]([Type_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[StockItem]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[StockItem]([Panelist_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Location_Id]
    ON [dbo].[StockItem]([Location_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockItem_U 
ON dbo.[StockItem] FOR update 
AS 
insert into audit.[StockItem](	 [GUIDReference]	 ,[Type_Id]	 ,[State_Id]	 ,[Panelist_Id]	 ,[Location_Id]	 ,[SerialNumber]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Type_Id]	 ,d.[State_Id]	 ,d.[Panelist_Id]	 ,d.[Location_Id]	 ,d.[SerialNumber]	 ,d.[Description]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StockItem](	 [GUIDReference]	 ,[Type_Id]	 ,[State_Id]	 ,[Panelist_Id]	 ,[Location_Id]	 ,[SerialNumber]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Type_Id]	 ,i.[State_Id]	 ,i.[Panelist_Id]	 ,i.[Location_Id]	 ,i.[SerialNumber]	 ,i.[Description]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgStockItem_I
ON dbo.[StockItem] FOR insert 
AS 
insert into audit.[StockItem](	 [GUIDReference]	 ,[Type_Id]	 ,[State_Id]	 ,[Panelist_Id]	 ,[Location_Id]	 ,[SerialNumber]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Type_Id]	 ,i.[State_Id]	 ,i.[Panelist_Id]	 ,i.[Location_Id]	 ,i.[SerialNumber]	 ,i.[Description]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStockItem_D
ON dbo.[StockItem] FOR delete 
AS 
insert into audit.[StockItem](	 [GUIDReference]	 ,[Type_Id]	 ,[State_Id]	 ,[Panelist_Id]	 ,[Location_Id]	 ,[SerialNumber]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Type_Id]	 ,d.[State_Id]	 ,d.[Panelist_Id]	 ,d.[Location_Id]	 ,d.[SerialNumber]	 ,d.[Description]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'D' from deleted d