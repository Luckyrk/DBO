CREATE TABLE [dbo].[StockCategory] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.StockCategory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockCategory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StockCategory_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);








GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[StockCategory]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StockCategory]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockCategory_U 
ON dbo.[StockCategory] FOR update 
AS 
insert into audit.[StockCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Code]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[Code],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StockCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Code]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[Code],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgStockCategory_I
ON dbo.[StockCategory] FOR insert 
AS 
insert into audit.[StockCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Code]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[Code],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStockCategory_D
ON dbo.[StockCategory] FOR delete 
AS 
insert into audit.[StockCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Code]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[Code],'D' from deleted d