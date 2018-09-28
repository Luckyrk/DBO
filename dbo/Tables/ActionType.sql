CREATE TABLE [dbo].[ActionType] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [StateModel_Id]      UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ActionType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ActionType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ActionType_dbo.StateModel_StateModel_Id] FOREIGN KEY ([StateModel_Id]) REFERENCES [dbo].[StateModel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueActionTypeTranslation] UNIQUE NONCLUSTERED ([Description_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ActionType]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StateModel_Id]
    ON [dbo].[ActionType]([StateModel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ActionType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgActionType_U 
ON dbo.[ActionType] FOR update 
AS 
insert into audit.[ActionType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Description_Id]	 ,[StateModel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Description_Id]	 ,d.[StateModel_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ActionType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Description_Id]	 ,[StateModel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Description_Id]	 ,i.[StateModel_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgActionType_I
ON dbo.[ActionType] FOR insert 
AS 
insert into audit.[ActionType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Description_Id]	 ,[StateModel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Description_Id]	 ,i.[StateModel_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgActionType_D
ON dbo.[ActionType] FOR delete 
AS 
insert into audit.[ActionType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Description_Id]	 ,[StateModel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Description_Id]	 ,d.[StateModel_Id]	 ,d.[Country_Id],'D' from deleted d