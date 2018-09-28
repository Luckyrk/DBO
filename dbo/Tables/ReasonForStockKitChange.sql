CREATE TABLE [dbo].[ReasonForStockKitChange] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ReasonForStockKitChange] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ReasonForStockKitChange_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ReasonForStockKitChange_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ReasonForStockKitChange]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ReasonForStockKitChange]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgReasonForStockKitChange_U 
ON dbo.[ReasonForStockKitChange] FOR update 
AS 
insert into audit.[ReasonForStockKitChange](	 [Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Code]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Description_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[ReasonForStockKitChange](	 [Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Code]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Description_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgReasonForStockKitChange_I
ON dbo.[ReasonForStockKitChange] FOR insert 
AS 
insert into audit.[ReasonForStockKitChange](	 [Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Code]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Description_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgReasonForStockKitChange_D
ON dbo.[ReasonForStockKitChange] FOR delete 
AS 
insert into audit.[ReasonForStockKitChange](	 [Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Code]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Description_Id]	 ,d.[Country_Id],'D' from deleted d