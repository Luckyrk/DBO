CREATE TABLE [dbo].[ConfigurationSet] (
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
insert into audit.[ConfigurationSet](	 [ConfigurationSetId]	 ,[CountryID]	 ,[PanelId]	 ,[PanelManagementCountryConfiguration_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[ConfigurationSetId]	 ,d.[CountryID]	 ,d.[PanelId]	 ,d.[PanelManagementCountryConfiguration_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.ConfigurationSetId = i.ConfigurationSetId 
insert into audit.[ConfigurationSet](	 [ConfigurationSetId]	 ,[CountryID]	 ,[PanelId]	 ,[PanelManagementCountryConfiguration_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[ConfigurationSetId]	 ,i.[CountryID]	 ,i.[PanelId]	 ,i.[PanelManagementCountryConfiguration_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.ConfigurationSetId = i.ConfigurationSetId
GO
CREATE TRIGGER dbo.trgConfigurationSet_I
ON dbo.[ConfigurationSet] FOR insert 
AS 
insert into audit.[ConfigurationSet](	 [ConfigurationSetId]	 ,[CountryID]	 ,[PanelId]	 ,[PanelManagementCountryConfiguration_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[ConfigurationSetId]	 ,i.[CountryID]	 ,i.[PanelId]	 ,i.[PanelManagementCountryConfiguration_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgConfigurationSet_D
ON dbo.[ConfigurationSet] FOR delete 
AS 
insert into audit.[ConfigurationSet](	 [ConfigurationSetId]	 ,[CountryID]	 ,[PanelId]	 ,[PanelManagementCountryConfiguration_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[ConfigurationSetId]	 ,d.[CountryID]	 ,d.[PanelId]	 ,d.[PanelManagementCountryConfiguration_Id]	 ,d.[Type],'D' from deleted d