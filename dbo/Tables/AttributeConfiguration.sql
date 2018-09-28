CREATE TABLE [dbo].[AttributeConfiguration] (
    [AttributeConfigurationId] UNIQUEIDENTIFIER NOT NULL,
    [Order]                    INT              NOT NULL,
    [AttributeId]              UNIQUEIDENTIFIER NOT NULL,
    [IsRequired]               BIT              NOT NULL,
    [ConfigurationSetId]       UNIQUEIDENTIFIER NULL,
    [BelongingTypeId]          UNIQUEIDENTIFIER NULL,
    [Discriminator]            NVARCHAR (128)   NOT NULL CONSTRAINT DF_AttributeConfiguration DEFAULT N'ConfigurationSet',
	[UseShortCode]             BIT              NOT NULL DEFAULT(0),
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.AttributeConfiguration] PRIMARY KEY CLUSTERED ([AttributeConfigurationId] ASC),
    CONSTRAINT [FK_dbo.AttributeConfiguration_dbo.Attribute_AttributeId] FOREIGN KEY ([AttributeId]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.AttributeConfiguration_dbo.BelongingType_BelongingTypeId] FOREIGN KEY ([BelongingTypeId]) REFERENCES [dbo].[BelongingType] ([Id]),
    CONSTRAINT [FK_dbo.AttributeConfiguration_dbo.ConfigurationSet_ConfigurationSetId] FOREIGN KEY ([ConfigurationSetId]) REFERENCES [dbo].[ConfigurationSet] ([ConfigurationSetId])
);








GO
CREATE NONCLUSTERED INDEX [IX_ConfigurationSetId]
    ON [dbo].[AttributeConfiguration]([ConfigurationSetId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AttributeId]
    ON [dbo].[AttributeConfiguration]([AttributeId] ASC);


GO
CREATE TRIGGER dbo.trgAttributeConfiguration_U 
ON dbo.[AttributeConfiguration] FOR update 
AS 
insert into audit.[AttributeConfiguration](	 [AttributeConfigurationId]	 ,[Order]	 ,[AttributeId]	 ,[IsRequired]	 ,[ConfigurationSetId]	 ,[BelongingTypeId]	 ,[Discriminator]	 ,[UseShortCode]	 ,AuditOperation) select 	 d.[AttributeConfigurationId]	 ,d.[Order]	 ,d.[AttributeId]	 ,d.[IsRequired]	 ,d.[ConfigurationSetId]	 ,d.[BelongingTypeId]	 ,d.[Discriminator]	 ,d.[UseShortCode]	 ,'O'  from 	 deleted d join inserted i on d.AttributeConfigurationId = i.AttributeConfigurationId 
insert into audit.[AttributeConfiguration](	 [AttributeConfigurationId]	 ,[Order]	 ,[AttributeId]	 ,[IsRequired]	 ,[ConfigurationSetId]	 ,[BelongingTypeId]	 ,[Discriminator]	 ,[UseShortCode]	 ,AuditOperation) select 	 i.[AttributeConfigurationId]	 ,i.[Order]	 ,i.[AttributeId]	 ,i.[IsRequired]	 ,i.[ConfigurationSetId]	 ,i.[BelongingTypeId]	 ,i.[Discriminator]	 ,i.[UseShortCode]	 ,'N'  from 	 deleted d join inserted i on d.AttributeConfigurationId = i.AttributeConfigurationId
GO
CREATE TRIGGER dbo.trgAttributeConfiguration_I
ON dbo.[AttributeConfiguration] FOR insert 
AS 
insert into audit.[AttributeConfiguration](	 [AttributeConfigurationId]	 ,[Order]	 ,[AttributeId]	 ,[IsRequired]	 ,[ConfigurationSetId]	 ,[BelongingTypeId]	 ,[Discriminator]	 ,[UseShortCode]	 ,AuditOperation) select 	 i.[AttributeConfigurationId]	 ,i.[Order]	 ,i.[AttributeId]	 ,i.[IsRequired]	 ,i.[ConfigurationSetId]	 ,i.[BelongingTypeId]	 ,i.[Discriminator]
	 ,i.[UseShortCode]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgAttributeConfiguration_D
ON dbo.[AttributeConfiguration] FOR delete 
AS 
insert into audit.[AttributeConfiguration](	 [AttributeConfigurationId]	 ,[Order]	 ,[AttributeId]	 ,[IsRequired]	 ,[ConfigurationSetId]	 ,[BelongingTypeId]	 ,[Discriminator]	 ,[UseShortCode]	 ,AuditOperation) select 	 d.[AttributeConfigurationId]	 ,d.[Order]	 ,d.[AttributeId]	 ,d.[IsRequired]	 ,d.[ConfigurationSetId]	 ,d.[BelongingTypeId]	 ,d.[Discriminator]
	 ,d.[UseShortCode]
	 ,'D' from deleted d
GO
CREATE NONCLUSTERED INDEX [IX_BelongingTypeId]
    ON [dbo].[AttributeConfiguration]([BelongingTypeId] ASC);

