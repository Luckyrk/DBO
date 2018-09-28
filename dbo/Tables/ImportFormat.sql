CREATE TABLE [dbo].[ImportFormat] (
    [GUIDReference]            UNIQUEIDENTIFIER NOT NULL,
    [Delimiter]                NVARCHAR (1)     NULL,
    [DefinedQuote]             NVARCHAR (1)     NULL,
    [IsForUpdate]              BIT              NOT NULL,
    [Type]                     NVARCHAR (200)   NULL,
    [HasHeader]                BIT              NOT NULL,
    [CreationTimeStamp]        DATETIME         NULL,
    [GPSUser]                  NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,
    [ImportDefinitionTypeName] NVARCHAR (200)   NULL,
    [Description_Id]           UNIQUEIDENTIFIER NULL,
    [Country_Id]               UNIQUEIDENTIFIER NOT NULL,
	[ImportFormatPeriod_Id]	   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.ImportFormat] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ImportFormat_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ImportFormat_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
	CONSTRAINT [FK_dbo.ImportFormat_dbo.ImportFormatPeriod_ImportFormatPeriod_Id] FOREIGN KEY ([ImportFormatPeriod_Id]) REFERENCES [dbo].[ImportFormatPeriod] ([GUIDReference]),
    CONSTRAINT [UniqueImportFormatTranslation] UNIQUE NONCLUSTERED ([Description_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ImportFormat]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ImportFormat]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportFormat_U 
ON dbo.[ImportFormat] FOR update 
AS 
insert into audit.[ImportFormat](	 [GUIDReference]	 ,[Delimiter]	 ,[DefinedQuote]	 ,[IsForUpdate]	 ,[Type]	 ,[HasHeader]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[ImportDefinitionTypeName]	 ,[Description_Id]	 ,[Country_Id]	 ,[ImportFormatPeriod_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Delimiter]	 ,d.[DefinedQuote]	 ,d.[IsForUpdate]	 ,d.[Type]	 ,d.[HasHeader]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[ImportDefinitionTypeName]	 ,d.[Description_Id]	 ,d.[Country_Id]	 ,d.[ImportFormatPeriod_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ImportFormat](	 [GUIDReference]	 ,[Delimiter]	 ,[DefinedQuote]	 ,[IsForUpdate]	 ,[Type]	 ,[HasHeader]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[ImportDefinitionTypeName]	 ,[Description_Id]	 ,[Country_Id]	 ,[ImportFormatPeriod_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Delimiter]	 ,i.[DefinedQuote]	 ,i.[IsForUpdate]	 ,i.[Type]	 ,i.[HasHeader]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[ImportDefinitionTypeName]	 ,i.[Description_Id]	 ,i.[Country_Id]	 ,i.[ImportFormatPeriod_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgImportFormat_I
ON dbo.[ImportFormat] FOR insert 
AS 
insert into audit.[ImportFormat](	 [GUIDReference]	 ,[Delimiter]	 ,[DefinedQuote]	 ,[IsForUpdate]	 ,[Type]	 ,[HasHeader]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[ImportDefinitionTypeName]	 ,[Description_Id]	 ,[Country_Id]	 ,[ImportFormatPeriod_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Delimiter]	 ,i.[DefinedQuote]	 ,i.[IsForUpdate]	 ,i.[Type]	 ,i.[HasHeader]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[ImportDefinitionTypeName]	 ,i.[Description_Id]	 ,i.[Country_Id]
	 ,i.[ImportFormatPeriod_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgImportFormat_D
ON dbo.[ImportFormat] FOR delete 
AS 
insert into audit.[ImportFormat](	 [GUIDReference]	 ,[Delimiter]	 ,[DefinedQuote]	 ,[IsForUpdate]	 ,[Type]	 ,[HasHeader]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[ImportDefinitionTypeName]	 ,[Description_Id]	 ,[Country_Id]	 ,[ImportFormatPeriod_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Delimiter]	 ,d.[DefinedQuote]	 ,d.[IsForUpdate]	 ,d.[Type]	 ,d.[HasHeader]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[ImportDefinitionTypeName]	 ,d.[Description_Id]	 ,d.[Country_Id]	 ,d.[ImportFormatPeriod_Id],'D' from deleted d