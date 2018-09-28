CREATE TABLE [dbo].[TranslationTerm] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [CultureCode]        INT              NOT NULL,
    [Value]              NVARCHAR (500)   NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.TranslationTerm] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.TranslationTerm_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[TranslationTerm]([Translation_Id] ASC);


GO
CREATE TRIGGER dbo.trgTranslationTerm_U 
ON dbo.[TranslationTerm] FOR update 
AS 
insert into audit.[TranslationTerm](	 [GUIDReference]	 ,[CultureCode]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CultureCode]	 ,d.[Value]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[TranslationTerm](	 [GUIDReference]	 ,[CultureCode]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CultureCode]	 ,i.[Value]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgTranslationTerm_I
ON dbo.[TranslationTerm] FOR insert 
AS 
insert into audit.[TranslationTerm](	 [GUIDReference]	 ,[CultureCode]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CultureCode]	 ,i.[Value]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTranslationTerm_D
ON dbo.[TranslationTerm] FOR delete 
AS 
insert into audit.[TranslationTerm](	 [GUIDReference]	 ,[CultureCode]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CultureCode]	 ,d.[Value]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id],'D' from deleted d