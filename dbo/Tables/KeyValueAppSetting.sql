CREATE TABLE [dbo].[KeyValueAppSetting]
(
    [GUIDReference]             UNIQUEIDENTIFIER NOT NULL,
    [Value]						NVARCHAR (255)   NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [KeyAppSetting_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.KeyValueAppSetting] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.KeyValueAppSetting_dbo.KeyAppSetting_KeyAppSetting_Id] FOREIGN KEY ([KeyAppSetting_Id]) REFERENCES [dbo].[KeyAppSetting] ([GUIDReference]),
    CONSTRAINT [FK_dbo.KeyValueAppSetting_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
	CONSTRAINT [UniqueKeyCountryAppConfig] UNIQUE NONCLUSTERED ([KeyAppSetting_Id] ASC, [Country_Id] ASC)
)
