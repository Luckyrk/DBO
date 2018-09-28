CREATE TABLE [dbo].[ImportFile] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Date]               DATETIME         NOT NULL,
    [Content]            VARBINARY (MAX)  NULL,
    [HashMD5]            NVARCHAR (200)   NULL,
    [Name]               NVARCHAR (200)   NULL,
    [TimeZoneId]         NVARCHAR (200)   NULL,
    [CultureCode]        INT              NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [State_Id]           UNIQUEIDENTIFIER NULL,
    [ImportFormat_Id]    UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ImportFile] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ImportFile_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ImportFile_dbo.ImportFormat_ImportFormat_Id] FOREIGN KEY ([ImportFormat_Id]) REFERENCES [dbo].[ImportFormat] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ImportFile_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[ImportFile]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ImportFormat_Id]
    ON [dbo].[ImportFile]([ImportFormat_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ImportFile]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportFile_U 
ON dbo.[ImportFile] FOR update 
AS 
insert into audit.[ImportFile](	 [GUIDReference]	 ,[Date]	 ,[Content]	 ,[HashMD5]	 ,[Name]	 ,[TimeZoneId]	 ,[CultureCode]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[State_Id]	 ,[ImportFormat_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Date]	 ,d.[Content]	 ,d.[HashMD5]	 ,d.[Name]	 ,d.[TimeZoneId]	 ,d.[CultureCode]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[State_Id]	 ,d.[ImportFormat_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ImportFile](	 [GUIDReference]	 ,[Date]	 ,[Content]	 ,[HashMD5]	 ,[Name]	 ,[TimeZoneId]	 ,[CultureCode]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[State_Id]	 ,[ImportFormat_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Date]	 ,i.[Content]	 ,i.[HashMD5]	 ,i.[Name]	 ,i.[TimeZoneId]	 ,i.[CultureCode]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[State_Id]	 ,i.[ImportFormat_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgImportFile_I
ON dbo.[ImportFile] FOR insert 
AS 
insert into audit.[ImportFile](	 [GUIDReference]	 ,[Date]	 ,[Content]	 ,[HashMD5]	 ,[Name]	 ,[TimeZoneId]	 ,[CultureCode]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[State_Id]	 ,[ImportFormat_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Date]	 ,i.[Content]	 ,i.[HashMD5]	 ,i.[Name]	 ,i.[TimeZoneId]	 ,i.[CultureCode]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[State_Id]	 ,i.[ImportFormat_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgImportFile_D
ON dbo.[ImportFile] FOR delete 
AS 
insert into audit.[ImportFile](	 [GUIDReference]	 ,[Date]	 ,[Content]	 ,[HashMD5]	 ,[Name]	 ,[TimeZoneId]	 ,[CultureCode]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[State_Id]	 ,[ImportFormat_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Date]	 ,d.[Content]	 ,d.[HashMD5]	 ,d.[Name]	 ,d.[TimeZoneId]	 ,d.[CultureCode]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[State_Id]	 ,d.[ImportFormat_Id]	 ,d.[Country_Id],'D' from deleted d