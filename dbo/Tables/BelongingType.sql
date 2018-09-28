CREATE TABLE [dbo].[BelongingType] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.BelongingType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.BelongingType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.BelongingType_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueBelongingTypeTranslation] UNIQUE NONCLUSTERED ([Translation_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[BelongingType]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[BelongingType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgBelongingType_U 
ON dbo.[BelongingType] FOR update 
AS 
insert into audit.[BelongingType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[BelongingType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgBelongingType_I
ON dbo.[BelongingType] FOR insert 
AS 
insert into audit.[BelongingType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgBelongingType_D
ON dbo.[BelongingType] FOR delete 
AS 
insert into audit.[BelongingType](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[Type],'D' from deleted d