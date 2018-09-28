CREATE TABLE [dbo].[EnumDefinition] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Value]              NVARCHAR (200)   NOT NULL,
    [IsActive]           BIT              NOT NULL,
    [IsSelected]         BIT              NOT NULL,
    [IsFreeTextRequired] BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Demographic_Id]     UNIQUEIDENTIFIER NULL,
    [EnumSet_Id]         UNIQUEIDENTIFIER NULL,
    [EnumValueSet_Id]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.EnumDefinition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.EnumDefinition_dbo.Attribute_Demographic_Id] FOREIGN KEY ([Demographic_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.EnumDefinition_dbo.DemographicValueSet_EnumValueSet_Id] FOREIGN KEY ([EnumValueSet_Id]) REFERENCES [dbo].[DemographicValueSet] ([GUIDReference]),
    CONSTRAINT [FK_dbo.EnumDefinition_dbo.EnumSet_EnumSet_Id] FOREIGN KEY ([EnumSet_Id]) REFERENCES [dbo].[EnumSet] ([Id]),
    CONSTRAINT [FK_dbo.EnumDefinition_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueEnumDefinitionTranslation] UNIQUE NONCLUSTERED ([Demographic_Id] ASC, [Translation_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[EnumDefinition]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Demographic_Id]
    ON [dbo].[EnumDefinition]([Demographic_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EnumSet_Id]
    ON [dbo].[EnumDefinition]([EnumSet_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EnumValueSet_Id]
    ON [dbo].[EnumDefinition]([EnumValueSet_Id] ASC);


GO
CREATE TRIGGER dbo.trgEnumDefinition_U 
ON dbo.[EnumDefinition] FOR update 
AS 
insert into audit.[EnumDefinition](	 [Id]	 ,[Value]	 ,[IsActive]	 ,[IsSelected]	 ,[IsFreeTextRequired]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Demographic_Id]	 ,[EnumSet_Id]	 ,[EnumValueSet_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Value]	 ,d.[IsActive]	 ,d.[IsSelected]	 ,d.[IsFreeTextRequired]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Demographic_Id]	 ,d.[EnumSet_Id]	 ,d.[EnumValueSet_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[EnumDefinition](	 [Id]	 ,[Value]	 ,[IsActive]	 ,[IsSelected]	 ,[IsFreeTextRequired]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Demographic_Id]	 ,[EnumSet_Id]	 ,[EnumValueSet_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Value]	 ,i.[IsActive]	 ,i.[IsSelected]	 ,i.[IsFreeTextRequired]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Demographic_Id]	 ,i.[EnumSet_Id]	 ,i.[EnumValueSet_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgEnumDefinition_I
ON dbo.[EnumDefinition] FOR insert 
AS 
insert into audit.[EnumDefinition](	 [Id]	 ,[Value]	 ,[IsActive]	 ,[IsSelected]	 ,[IsFreeTextRequired]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Demographic_Id]	 ,[EnumSet_Id]	 ,[EnumValueSet_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Value]	 ,i.[IsActive]	 ,i.[IsSelected]	 ,i.[IsFreeTextRequired]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Demographic_Id]	 ,i.[EnumSet_Id]	 ,i.[EnumValueSet_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgEnumDefinition_D
ON dbo.[EnumDefinition] FOR delete 
AS 
insert into audit.[EnumDefinition](	 [Id]	 ,[Value]	 ,[IsActive]	 ,[IsSelected]	 ,[IsFreeTextRequired]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Demographic_Id]	 ,[EnumSet_Id]	 ,[EnumValueSet_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Value]	 ,d.[IsActive]	 ,d.[IsSelected]	 ,d.[IsFreeTextRequired]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Demographic_Id]	 ,d.[EnumSet_Id]	 ,d.[EnumValueSet_Id],'D' from deleted d