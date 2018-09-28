CREATE TABLE [dbo].[OrderType] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Code]               INT              NOT NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [ActionTaskType_Id]  UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.OrderType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.OrderType_dbo.ActionTaskType_ActionTaskType_Id] FOREIGN KEY ([ActionTaskType_Id]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.OrderType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.OrderType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[OrderType]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTaskType_Id]
    ON [dbo].[OrderType]([ActionTaskType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[OrderType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgOrderType_U 
ON dbo.[OrderType] FOR update 
AS 
insert into audit.[OrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[ActionTaskType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Code]	 ,d.[Description_Id]	 ,d.[ActionTaskType_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[OrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[ActionTaskType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Code]	 ,i.[Description_Id]	 ,i.[ActionTaskType_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgOrderType_I
ON dbo.[OrderType] FOR insert 
AS 
insert into audit.[OrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[ActionTaskType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Code]	 ,i.[Description_Id]	 ,i.[ActionTaskType_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgOrderType_D
ON dbo.[OrderType] FOR delete 
AS 
insert into audit.[OrderType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Code]	 ,[Description_Id]	 ,[ActionTaskType_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Code]	 ,d.[Description_Id]	 ,d.[ActionTaskType_Id]	 ,d.[Country_Id],'D' from deleted d