CREATE TABLE [dbo].[TranslationGroup] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [KeyName]            NVARCHAR (200)   NOT NULL,
    [LastUpdateDate]     DATETIME         NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.TranslationGroup] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [UniqueTranslationGroupsKeyName] UNIQUE NONCLUSTERED ([KeyName] ASC)
);




GO
CREATE TRIGGER dbo.trgTranslationGroup_U 
ON dbo.[TranslationGroup] FOR update 
AS 
insert into audit.[TranslationGroup](	 [GUIDReference]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[KeyName]	 ,d.[LastUpdateDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[TranslationGroup](	 [GUIDReference]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[KeyName]	 ,i.[LastUpdateDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgTranslationGroup_I
ON dbo.[TranslationGroup] FOR insert 
AS 
insert into audit.[TranslationGroup](	 [GUIDReference]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[KeyName]	 ,i.[LastUpdateDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTranslationGroup_D
ON dbo.[TranslationGroup] FOR delete 
AS 
insert into audit.[TranslationGroup](	 [GUIDReference]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[KeyName]	 ,d.[LastUpdateDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d