CREATE TABLE [dbo].[ActionTaskType] (
    [GUIDReference]             UNIQUEIDENTIFIER NOT NULL,
    [ActionCode]                INT              IDENTITY (1, 1) NOT NULL,
    [IsForDpa]                  BIT              NOT NULL,
    [IsForFqs]                  BIT              NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [Duration]                  INT              NULL,
    [TagTranslation_Id]         UNIQUEIDENTIFIER NOT NULL,
    [DescriptionTranslation_Id] UNIQUEIDENTIFIER NOT NULL,
    [TypeTranslation_Id]        UNIQUEIDENTIFIER NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
    [Type]                      NVARCHAR (128)   NOT NULL,
    [IsClosed] BIT NULL, 
    [IsDealtByCommunicationTeam] BIT DEFAULT 1 , 
    CONSTRAINT [PK_dbo.ActionTaskType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ActionTaskType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ActionTaskType_dbo.Translation_DescriptionTranslation_Id] FOREIGN KEY ([DescriptionTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.ActionTaskType_dbo.Translation_TagTranslation_Id] FOREIGN KEY ([TagTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.ActionTaskType_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueActionTaskTypeTranslation] UNIQUE NONCLUSTERED ([TagTranslation_Id] ASC, [Country_Id] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_TagTranslation_Id]
    ON [dbo].[ActionTaskType]([TagTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DescriptionTranslation_Id]
    ON [dbo].[ActionTaskType]([DescriptionTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[ActionTaskType]([TypeTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ActionTaskType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgActionTaskType_U 
ON dbo.[ActionTaskType] FOR update 
AS 
insert into audit.[ActionTaskType](	 [GUIDReference]	 ,[ActionCode]	 ,[IsForDpa]	 ,[IsForFqs]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Duration]	 ,[TagTranslation_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[ActionCode]	 ,d.[IsForDpa]	 ,d.[IsForFqs]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Duration]	 ,d.[TagTranslation_Id]	 ,d.[DescriptionTranslation_Id]	 ,d.[TypeTranslation_Id]	 ,d.[Country_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ActionTaskType](	 [GUIDReference]	 ,[ActionCode]	 ,[IsForDpa]	 ,[IsForFqs]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Duration]	 ,[TagTranslation_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[ActionCode]	 ,i.[IsForDpa]	 ,i.[IsForFqs]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Duration]	 ,i.[TagTranslation_Id]	 ,i.[DescriptionTranslation_Id]	 ,i.[TypeTranslation_Id]	 ,i.[Country_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgActionTaskType_I
ON dbo.[ActionTaskType] FOR insert 
AS 
insert into audit.[ActionTaskType](	 [GUIDReference]	 ,[ActionCode]	 ,[IsForDpa]	 ,[IsForFqs]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Duration]	 ,[TagTranslation_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[ActionCode]	 ,i.[IsForDpa]	 ,i.[IsForFqs]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Duration]	 ,i.[TagTranslation_Id]	 ,i.[DescriptionTranslation_Id]	 ,i.[TypeTranslation_Id]	 ,i.[Country_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgActionTaskType_D
ON dbo.[ActionTaskType] FOR delete 
AS 
insert into audit.[ActionTaskType](	 [GUIDReference]	 ,[ActionCode]	 ,[IsForDpa]	 ,[IsForFqs]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Duration]	 ,[TagTranslation_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[ActionCode]	 ,d.[IsForDpa]	 ,d.[IsForFqs]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Duration]	 ,d.[TagTranslation_Id]	 ,d.[DescriptionTranslation_Id]	 ,d.[TypeTranslation_Id]	 ,d.[Country_Id]	 ,d.[Type],'D' from deleted d