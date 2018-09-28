CREATE TABLE [dbo].[Translation] (
    [TranslationId]      UNIQUEIDENTIFIER NOT NULL,
    [KeyName]            NVARCHAR (500)   NOT NULL,
    [LastUpdateDate]     DATETIME         NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Discriminator]      NVARCHAR (30)    NOT NULL,
    CONSTRAINT [PK_dbo.Translation] PRIMARY KEY CLUSTERED ([TranslationId] ASC),
    CONSTRAINT [UniqueTranslationsKeyName] UNIQUE NONCLUSTERED ([KeyName] ASC, [Discriminator] ASC)
);



GO
CREATE TRIGGER dbo.trgTranslation_U 
ON dbo.[Translation] FOR update 
AS 
insert into audit.[Translation](	 [TranslationId]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 d.[TranslationId]	 ,d.[KeyName]	 ,d.[LastUpdateDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Discriminator],'O'  from 	 deleted d join inserted i on d.TranslationId = i.TranslationId 
insert into audit.[Translation](	 [TranslationId]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 i.[TranslationId]	 ,i.[KeyName]	 ,i.[LastUpdateDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Discriminator],'N'  from 	 deleted d join inserted i on d.TranslationId = i.TranslationId
GO







GO
CREATE TRIGGER dbo.trgTranslation_I
ON dbo.[Translation] FOR insert 
AS 
insert into audit.[Translation](	 [TranslationId]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 i.[TranslationId]	 ,i.[KeyName]	 ,i.[LastUpdateDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Discriminator],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTranslation_D
ON dbo.[Translation] FOR delete 
AS 
insert into audit.[Translation](	 [TranslationId]	 ,[KeyName]	 ,[LastUpdateDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 d.[TranslationId]	 ,d.[KeyName]	 ,d.[LastUpdateDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Discriminator],'D' from deleted d
GO
CREATE NONCLUSTERED INDEX [_dta_index_Translation_5_21575115__K7_K1_2]
    ON [dbo].[Translation]([Discriminator] ASC, [TranslationId] ASC)
    INCLUDE([KeyName]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_Translation_5_21575115__K7_K1]
    ON [dbo].[Translation]([Discriminator] ASC, [TranslationId] ASC);


GO
CREATE STATISTICS [_dta_stat_1239727519_7_1]
    ON [dbo].[Translation]([Discriminator], [TranslationId]);

