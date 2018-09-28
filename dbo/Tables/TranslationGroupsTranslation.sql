CREATE TABLE [dbo].[TranslationGroupsTranslation] (
    [MultipleTranslation_Id] UNIQUEIDENTIFIER NOT NULL,
    [SystemTranslation_Id]   UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TranslationGroupsTranslation] PRIMARY KEY CLUSTERED ([MultipleTranslation_Id] ASC, [SystemTranslation_Id] ASC),
    CONSTRAINT [FK_dbo.TranslationGroupsTranslation_dbo.Translation_SystemTranslation_Id] FOREIGN KEY ([SystemTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.TranslationGroupsTranslation_dbo.TranslationGroup_MultipleTranslation_Id] FOREIGN KEY ([MultipleTranslation_Id]) REFERENCES [dbo].[TranslationGroup] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_MultipleTranslation_Id]
    ON [dbo].[TranslationGroupsTranslation]([MultipleTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SystemTranslation_Id]
    ON [dbo].[TranslationGroupsTranslation]([SystemTranslation_Id] ASC);


GO
CREATE TRIGGER dbo.trgTranslationGroupsTranslation_U 
ON dbo.[TranslationGroupsTranslation] FOR update 
AS 
insert into audit.[TranslationGroupsTranslation](	 [MultipleTranslation_Id]	 ,[SystemTranslation_Id]	 ,AuditOperation) select 	 d.[MultipleTranslation_Id]	 ,d.[SystemTranslation_Id],'O'  from 	 deleted d join inserted i on d.MultipleTranslation_Id = i.MultipleTranslation_Id	 and d.SystemTranslation_Id = i.SystemTranslation_Id 
insert into audit.[TranslationGroupsTranslation](	 [MultipleTranslation_Id]	 ,[SystemTranslation_Id]	 ,AuditOperation) select 	 i.[MultipleTranslation_Id]	 ,i.[SystemTranslation_Id],'N'  from 	 deleted d join inserted i on d.MultipleTranslation_Id = i.MultipleTranslation_Id	 and d.SystemTranslation_Id = i.SystemTranslation_Id
GO
CREATE TRIGGER dbo.trgTranslationGroupsTranslation_I
ON dbo.[TranslationGroupsTranslation] FOR insert 
AS 
insert into audit.[TranslationGroupsTranslation](	 [MultipleTranslation_Id]	 ,[SystemTranslation_Id]	 ,AuditOperation) select 	 i.[MultipleTranslation_Id]	 ,i.[SystemTranslation_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTranslationGroupsTranslation_D
ON dbo.[TranslationGroupsTranslation] FOR delete 
AS 
insert into audit.[TranslationGroupsTranslation](	 [MultipleTranslation_Id]	 ,[SystemTranslation_Id]	 ,AuditOperation) select 	 d.[MultipleTranslation_Id]	 ,d.[SystemTranslation_Id],'D' from deleted d