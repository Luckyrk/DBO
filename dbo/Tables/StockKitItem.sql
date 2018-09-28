CREATE TABLE [dbo].[StockKitItem] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Quantity]           INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [StockKit_Id]        UNIQUEIDENTIFIER NULL,
    [StockType_Id]       UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.StockKitItem] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockKitItem_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StockKitItem_dbo.StockKit_StockKit_Id] FOREIGN KEY ([StockKit_Id]) REFERENCES [dbo].[StockKit] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockKitItem_dbo.StockType_StockType_Id] FOREIGN KEY ([StockType_Id]) REFERENCES [dbo].[StockType] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_StockKit_Id]
    ON [dbo].[StockKitItem]([StockKit_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StockType_Id]
    ON [dbo].[StockKitItem]([StockType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StockKitItem]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockKitItem_U 
ON dbo.[StockKitItem] FOR update 
AS 
insert into audit.[StockKitItem](	 [GUIDReference]	 ,[Quantity]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StockKit_Id]	 ,[StockType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Quantity]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[StockKit_Id]	 ,d.[StockType_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StockKitItem](	 [GUIDReference]	 ,[Quantity]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StockKit_Id]	 ,[StockType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Quantity]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[StockKit_Id]	 ,i.[StockType_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgStockKitItem_I
ON dbo.[StockKitItem] FOR insert 
AS 
insert into audit.[StockKitItem](	 [GUIDReference]	 ,[Quantity]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StockKit_Id]	 ,[StockType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Quantity]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[StockKit_Id]	 ,i.[StockType_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStockKitItem_D
ON dbo.[StockKitItem] FOR delete 
AS 
insert into audit.[StockKitItem](	 [GUIDReference]	 ,[Quantity]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StockKit_Id]	 ,[StockType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Quantity]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[StockKit_Id]	 ,d.[StockType_Id]	 ,d.[Country_Id],'D' from deleted d