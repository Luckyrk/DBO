CREATE TABLE [dbo].[AttributeCategory] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.AttributeCategory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.AttributeCategory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.AttributeCategory_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueAttributeCategoryTranslation] UNIQUE NONCLUSTERED ([Translation_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[AttributeCategory]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[AttributeCategory]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgAttributeCategory_U 
ON dbo.[AttributeCategory] FOR update 
AS 
insert into audit.[AttributeCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[AttributeCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgAttributeCategory_I
ON dbo.[AttributeCategory] FOR insert 
AS 
insert into audit.[AttributeCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAttributeCategory_D
ON dbo.[AttributeCategory] FOR delete 
AS 
insert into audit.[AttributeCategory](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d