﻿CREATE TABLE [dbo].[Country] (
    [CountryId]          UNIQUEIDENTIFIER NOT NULL,
    [CountryISO2A]       NVARCHAR (2)     NOT NULL,
    [TimeZone]			 NVARCHAR (60)    NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [TranslationId]      UNIQUEIDENTIFIER NOT NULL,
    [Configuration_Id]   UNIQUEIDENTIFIER NOT NULL,
    [Flag]               VARBINARY (MAX)  NULL,
    CONSTRAINT [PK_dbo.Country] PRIMARY KEY CLUSTERED ([CountryId] ASC),
    CONSTRAINT [FK_dbo.Country_dbo.CountryConfiguration_Configuration_Id] FOREIGN KEY ([Configuration_Id]) REFERENCES [dbo].[CountryConfiguration] ([Id]),
    CONSTRAINT [FK_dbo.Country_dbo.Translation_TranslationId] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueCountryTranslation] UNIQUE NONCLUSTERED ([TranslationId] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_TranslationId]
    ON [dbo].[Country]([TranslationId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Configuration_Id]
    ON [dbo].[Country]([Configuration_Id] ASC);


GO
CREATE TRIGGER dbo.trgCountry_U 
ON dbo.[Country] FOR update 
AS 
insert into audit.[Country](
insert into audit.[Country](
GO
CREATE TRIGGER dbo.trgCountry_I
ON dbo.[Country] FOR insert 
AS 
insert into audit.[Country](
GO
CREATE TRIGGER dbo.trgCountry_D
ON dbo.[Country] FOR delete 
AS 
insert into audit.[Country](