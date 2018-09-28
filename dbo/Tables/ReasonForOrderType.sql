CREATE TABLE [dbo].[ReasonForOrderType] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Code]               INT              NOT NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [OrderType_Id]       UNIQUEIDENTIFIER NULL,	
    [StockKitOrderType_Id]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.ReasonForOrderType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.OrderType_OrderType_Id] FOREIGN KEY ([OrderType_Id]) REFERENCES [dbo].[OrderType] ([Id]),	
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.OrderType_StockKitOrderType_Id] FOREIGN KEY ([StockKitOrderType_Id]) REFERENCES [dbo].[StockKitOrderType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ReasonForOrderType]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ReasonForOrderType]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderType_Id]
    ON [dbo].[ReasonForOrderType]([OrderType_Id] ASC);


GO
CREATE TRIGGER dbo.trgReasonForOrderType_U 
ON dbo.[ReasonForOrderType] FOR update 
AS 
insert into audit.[ReasonForOrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[Country_Id]	 ,[OrderType_Id]	 ,[StockKitOrderType_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Code]	 ,d.[Description_Id]	 ,d.[Country_Id]	 ,d.[OrderType_Id]	 ,d.[StockKitOrderType_Id]	 ,'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[ReasonForOrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[Country_Id]	 ,[OrderType_Id]	 ,[StockKitOrderType_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Code]	 ,i.[Description_Id]	 ,i.[Country_Id]	 ,i.[OrderType_Id]	 ,i.[StockKitOrderType_Id]	 'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgReasonForOrderType_I
ON dbo.[ReasonForOrderType] FOR insert 
AS 
insert into audit.[ReasonForOrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[Country_Id]	 ,[OrderType_Id]	 ,[StockKitOrderType_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Code]	 ,i.[Description_Id]	 ,i.[Country_Id]	 ,i.[OrderType_Id]
	 ,i.[StockKitOrderType_Id]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgReasonForOrderType_D
ON dbo.[ReasonForOrderType] FOR delete 
AS 
insert into audit.[ReasonForOrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[Country_Id]	 ,[OrderType_Id]	 ,[StockKitOrderType_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Code]	 ,d.[Description_Id]	 ,d.[Country_Id]	 ,d.[OrderType_Id]	 ,d.[StockKitOrderType_Id]	 ,'D' from deleted d