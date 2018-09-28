CREATE TABLE [dbo].[Form] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
	[SocialGrading]		 BIT			  NOT NULL DEFAULT 0,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [IsShowActiveBelonging] BIT NULL DEFAULT 0, 
    CONSTRAINT [PK_dbo.Form] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Form_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Form_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueFormTranslation] UNIQUE NONCLUSTERED ([Translation_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[Form]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Form]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgForm_U 
ON dbo.[Form] FOR update 
AS 
insert into audit.[Form](	 [GUIDReference],	 [SocialGrading]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[SocialGrading]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Form](	 [GUIDReference]	 ,[SocialGrading]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[SocialGrading]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgForm_I
ON dbo.[Form] FOR insert 
AS 
insert into audit.[Form](	 [GUIDReference]	 ,[SocialGrading]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[SocialGrading]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgForm_D
ON dbo.[Form] FOR delete 
AS 
insert into audit.[Form](	 [GUIDReference]	 ,[SocialGrading]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[SocialGrading]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d
