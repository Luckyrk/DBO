CREATE TABLE [dbo].[PreDefinedQuery] (
    [PreDefinedQueryId]  UNIQUEIDENTIFIER NOT NULL,
    [Select]             NVARCHAR (2000)  NOT NULL,
    [Where]              NVARCHAR (2000)  NULL,
    [OrderBy]            NVARCHAR (500)   NULL,
    [GroupBy]            NVARCHAR (500)   NULL,
    [Name]               NVARCHAR (150)   NOT NULL,
    [ElementType]        NVARCHAR (150)   NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Discriminator]      NVARCHAR (30)    NULL,
    [Export_Id]          UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PreDefinedQuery] PRIMARY KEY CLUSTERED ([PreDefinedQueryId] ASC),
    CONSTRAINT [FK_dbo.PreDefinedQuery_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PreDefinedQuery_dbo.QueryExport_Export_Id] FOREIGN KEY ([Export_Id]) REFERENCES [dbo].[QueryExport] ([Id]),
    CONSTRAINT [UniqueQueryName] UNIQUE NONCLUSTERED ([Name] , [Country_Id] )
);






GO
CREATE NONCLUSTERED INDEX [IX_Export_Id]
    ON [dbo].[PreDefinedQuery]([Export_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PreDefinedQuery]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgPreDefinedQuery_U 
ON dbo.[PreDefinedQuery] FOR update 
AS 
insert into audit.[PreDefinedQuery](	 [PreDefinedQueryId]	 ,[Select]	 ,[Where]	 ,[OrderBy]	 ,[GroupBy]	 ,[Name]	 ,[ElementType]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,[Export_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[PreDefinedQueryId]	 ,d.[Select]	 ,d.[Where]	 ,d.[OrderBy]	 ,d.[GroupBy]	 ,d.[Name]	 ,d.[ElementType]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Discriminator]	 ,d.[Export_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.PreDefinedQueryId = i.PreDefinedQueryId 
insert into audit.[PreDefinedQuery](	 [PreDefinedQueryId]	 ,[Select]	 ,[Where]	 ,[OrderBy]	 ,[GroupBy]	 ,[Name]	 ,[ElementType]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,[Export_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[PreDefinedQueryId]	 ,i.[Select]	 ,i.[Where]	 ,i.[OrderBy]	 ,i.[GroupBy]	 ,i.[Name]	 ,i.[ElementType]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Discriminator]	 ,i.[Export_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.PreDefinedQueryId = i.PreDefinedQueryId
GO
CREATE TRIGGER dbo.trgPreDefinedQuery_I
ON dbo.[PreDefinedQuery] FOR insert 
AS 
insert into audit.[PreDefinedQuery](	 [PreDefinedQueryId]	 ,[Select]	 ,[Where]	 ,[OrderBy]	 ,[GroupBy]	 ,[Name]	 ,[ElementType]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,[Export_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[PreDefinedQueryId]	 ,i.[Select]	 ,i.[Where]	 ,i.[OrderBy]	 ,i.[GroupBy]	 ,i.[Name]	 ,i.[ElementType]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Discriminator]	 ,i.[Export_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPreDefinedQuery_D
ON dbo.[PreDefinedQuery] FOR delete 
AS 
insert into audit.[PreDefinedQuery](	 [PreDefinedQueryId]	 ,[Select]	 ,[Where]	 ,[OrderBy]	 ,[GroupBy]	 ,[Name]	 ,[ElementType]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,[Export_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[PreDefinedQueryId]	 ,d.[Select]	 ,d.[Where]	 ,d.[OrderBy]	 ,d.[GroupBy]	 ,d.[Name]	 ,d.[ElementType]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Discriminator]	 ,d.[Export_Id]	 ,d.[Country_Id],'D' from deleted d