CREATE TABLE [dbo].[IndividualSex] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IndividualSex] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IndividualSex_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IndividualSex_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[IndividualSex]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IndividualSex]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIndividualSex_U 
ON dbo.[IndividualSex] FOR update 
AS 
insert into audit.[IndividualSex](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[IndividualSex](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgIndividualSex_I
ON dbo.[IndividualSex] FOR insert 
AS 
insert into audit.[IndividualSex](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIndividualSex_D
ON dbo.[IndividualSex] FOR delete 
AS 
insert into audit.[IndividualSex](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d