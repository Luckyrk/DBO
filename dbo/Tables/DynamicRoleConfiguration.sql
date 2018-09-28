CREATE TABLE [dbo].[DynamicRoleConfiguration] (
    [DynamicRoleConfigurationId] UNIQUEIDENTIFIER NOT NULL,
    [ConfigurationSetId]         UNIQUEIDENTIFIER NOT NULL,
    [DynamicRoleId]              UNIQUEIDENTIFIER NOT NULL,
    [ActiveFrom]                 DATETIME         NULL,
    [ActiveTo]                   DATETIME         NULL,
    [Order]                      INT              NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DynamicRoleConfiguration] PRIMARY KEY CLUSTERED ([DynamicRoleConfigurationId] ASC),
    CONSTRAINT [FK_dbo.DynamicRoleConfiguration_dbo.ConfigurationSet_ConfigurationSetId] FOREIGN KEY ([ConfigurationSetId]) REFERENCES [dbo].[ConfigurationSet] ([ConfigurationSetId]),
    CONSTRAINT [FK_dbo.DynamicRoleConfiguration_dbo.DynamicRole_DynamicRoleId] FOREIGN KEY ([DynamicRoleId]) REFERENCES [dbo].[DynamicRole] ([DynamicRoleId])
);


GO
CREATE TRIGGER dbo.trgDynamicRoleConfiguration_U 
ON dbo.[DynamicRoleConfiguration] FOR update 
AS 
insert into audit.[DynamicRoleConfiguration](	 [DynamicRoleConfigurationId]	 ,[ConfigurationSetId]	 ,[DynamicRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,[Order]	 ,AuditOperation) select 	 d.[DynamicRoleConfigurationId]	 ,d.[ConfigurationSetId]	 ,d.[DynamicRoleId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo]	 ,d.[Order],'O'  from 	 deleted d join inserted i on d.DynamicRoleConfigurationId = i.DynamicRoleConfigurationId 
insert into audit.[DynamicRoleConfiguration](	 [DynamicRoleConfigurationId]	 ,[ConfigurationSetId]	 ,[DynamicRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,[Order]	 ,AuditOperation) select 	 i.[DynamicRoleConfigurationId]	 ,i.[ConfigurationSetId]	 ,i.[DynamicRoleId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo]	 ,i.[Order],'N'  from 	 deleted d join inserted i on d.DynamicRoleConfigurationId = i.DynamicRoleConfigurationId
GO
CREATE TRIGGER dbo.trgDynamicRoleConfiguration_I
ON dbo.[DynamicRoleConfiguration] FOR insert 
AS 
insert into audit.[DynamicRoleConfiguration](	 [DynamicRoleConfigurationId]	 ,[ConfigurationSetId]	 ,[DynamicRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,[Order]	 ,AuditOperation) select 	 i.[DynamicRoleConfigurationId]	 ,i.[ConfigurationSetId]	 ,i.[DynamicRoleId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo]	 ,i.[Order],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDynamicRoleConfiguration_D
ON dbo.[DynamicRoleConfiguration] FOR delete 
AS 
insert into audit.[DynamicRoleConfiguration](	 [DynamicRoleConfigurationId]	 ,[ConfigurationSetId]	 ,[DynamicRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,[Order]	 ,AuditOperation) select 	 d.[DynamicRoleConfigurationId]	 ,d.[ConfigurationSetId]	 ,d.[DynamicRoleId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo]	 ,d.[Order],'D' from deleted d