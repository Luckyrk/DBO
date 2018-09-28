﻿CREATE TABLE [dbo].[PreDefinedQuery] (
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
insert into audit.[PreDefinedQuery](
insert into audit.[PreDefinedQuery](
GO
CREATE TRIGGER dbo.trgPreDefinedQuery_I
ON dbo.[PreDefinedQuery] FOR insert 
AS 
insert into audit.[PreDefinedQuery](
GO
CREATE TRIGGER dbo.trgPreDefinedQuery_D
ON dbo.[PreDefinedQuery] FOR delete 
AS 
insert into audit.[PreDefinedQuery](