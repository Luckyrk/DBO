﻿CREATE TABLE [dbo].[ConfigurationSet] (
    [ConfigurationSetId]                     UNIQUEIDENTIFIER NOT NULL,
    [CountryID]                              UNIQUEIDENTIFIER NOT NULL,
    [PanelId]                                UNIQUEIDENTIFIER NULL,
    [PanelManagementCountryConfiguration_Id] UNIQUEIDENTIFIER NULL,
    [Type]                                   NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ConfigurationSet] PRIMARY KEY CLUSTERED ([ConfigurationSetId] ASC),
    CONSTRAINT [FK_dbo.ConfigurationSet_dbo.Country_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ConfigurationSet_dbo.CountryConfiguration_PanelManagementCountryConfiguration_Id] FOREIGN KEY ([PanelManagementCountryConfiguration_Id]) REFERENCES [dbo].[CountryConfiguration] ([Id]),
    CONSTRAINT [FK_dbo.ConfigurationSet_dbo.Panel_PanelId] FOREIGN KEY ([PanelId]) REFERENCES [dbo].[Panel] ([GUIDReference])
);








GO
CREATE NONCLUSTERED INDEX [IX_CountryID]
    ON [dbo].[ConfigurationSet]([CountryID] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_PanelId]
    ON [dbo].[ConfigurationSet]([PanelId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_PanelManagementCountryConfiguration_Id]
    ON [dbo].[ConfigurationSet]([PanelManagementCountryConfiguration_Id] ASC);
GO
CREATE TRIGGER dbo.trgConfigurationSet_U 
ON dbo.[ConfigurationSet] FOR update 
AS 
insert into audit.[ConfigurationSet](
insert into audit.[ConfigurationSet](
GO
CREATE TRIGGER dbo.trgConfigurationSet_I
ON dbo.[ConfigurationSet] FOR insert 
AS 
insert into audit.[ConfigurationSet](
GO
CREATE TRIGGER dbo.trgConfigurationSet_D
ON dbo.[ConfigurationSet] FOR delete 
AS 
insert into audit.[ConfigurationSet](