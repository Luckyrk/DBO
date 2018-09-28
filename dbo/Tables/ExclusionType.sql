CREATE TABLE [dbo].[ExclusionType] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Priority]           INT              NOT NULL,
    [Visible]            BIT              NOT NULL,
    [AllowedContact]     BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ExclusionType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ExclusionType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ExclusionType_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueExclusionTypeTranslation] UNIQUE NONCLUSTERED ([Translation_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[ExclusionType]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ExclusionType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgExclusionType_U 
ON dbo.[ExclusionType] FOR update 
AS 
insert into audit.[ExclusionType](	 [GUIDReference]	 ,[Priority]	 ,[Visible]	 ,[AllowedContact]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Priority]	 ,d.[Visible]	 ,d.[AllowedContact]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ExclusionType](	 [GUIDReference]	 ,[Priority]	 ,[Visible]	 ,[AllowedContact]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Priority]	 ,i.[Visible]	 ,i.[AllowedContact]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgExclusionType_I
ON dbo.[ExclusionType] FOR insert 
AS 
insert into audit.[ExclusionType](	 [GUIDReference]	 ,[Priority]	 ,[Visible]	 ,[AllowedContact]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Priority]	 ,i.[Visible]	 ,i.[AllowedContact]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgExclusionType_D
ON dbo.[ExclusionType] FOR delete 
AS 
insert into audit.[ExclusionType](	 [GUIDReference]	 ,[Priority]	 ,[Visible]	 ,[AllowedContact]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Priority]	 ,d.[Visible]	 ,d.[AllowedContact]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d