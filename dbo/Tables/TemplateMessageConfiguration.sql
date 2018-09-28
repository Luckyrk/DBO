CREATE TABLE [dbo].[TemplateMessageConfiguration] (
    [TemplateMessageConfigurationId]      BIGINT     NOT NULL,
    [TemplateMessageSchemeId]             INT        NOT NULL,
    [TemplateMessageDefinitionId]         BIGINT     NOT NULL,
    [CommsMessageTemplateTypeId]          INT        NOT NULL,
    [CommsMessageTemplateSubTypeId]       INT        NOT NULL,
    [CommsMessageTemplateComponentTypeId] INT        NOT NULL,
    [CommsMessageTemplateComponentId]     BIGINT     NOT NULL,
    [ReleaseVersion]                      FLOAT (53) NOT NULL,
    [ActiveFrom]                          DATETIME   NOT NULL,
    [ActiveTo]                            DATETIME   NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TemplateMessageConfiguration] PRIMARY KEY CLUSTERED ([TemplateMessageConfigurationId] ASC),
    CONSTRAINT [FK_dbo.TemplateMessageConfiguration_dbo.CommsMessageTemplateComponent_CommsMessageTemplateComponentId] FOREIGN KEY ([CommsMessageTemplateComponentId]) REFERENCES [dbo].[CommsMessageTemplateComponent] ([CommsMessageTemplateComponentId]),
    CONSTRAINT [FK_dbo.TemplateMessageConfiguration_dbo.CommsMessageTemplateComponentType_CommsMessageTemplateTypeId_CommsMessageTemplateCompone] FOREIGN KEY ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]) REFERENCES [dbo].[CommsMessageTemplateComponentType] ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]),
    CONSTRAINT [FK_dbo.TemplateMessageConfiguration_dbo.CommsMessageTemplateSubType_CommsMessageTemplateSubTypeId_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateSubTypeId], [CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateSubType] ([CommsMessageTemplateSubTypeId], [CommsMessageTemplateTypeId]),
    CONSTRAINT [FK_dbo.TemplateMessageConfiguration_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId]),
    CONSTRAINT [FK_dbo.TemplateMessageConfiguration_dbo.TemplateMessageDefinition_TemplateMessageDefinitionId_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageDefinitionId], [TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageDefinition] ([TemplateMessageDefinitionId], [TemplateMessageSchemeId]),
    CONSTRAINT [FK_dbo.TemplateMessageConfiguration_dbo.TemplateMessageScheme_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageConfiguration]([TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageDefinitionId_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageConfiguration]([TemplateMessageDefinitionId] ASC, [TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[TemplateMessageConfiguration]([CommsMessageTemplateTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateSubTypeId_CommsMessageTemplateTypeId]
    ON [dbo].[TemplateMessageConfiguration]([CommsMessageTemplateSubTypeId] ASC, [CommsMessageTemplateTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId_CommsMessageTemplateComponentTypeId]
    ON [dbo].[TemplateMessageConfiguration]([CommsMessageTemplateTypeId] ASC, [CommsMessageTemplateComponentTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateComponentId]
    ON [dbo].[TemplateMessageConfiguration]([CommsMessageTemplateComponentId] ASC);


GO
CREATE TRIGGER dbo.trgTemplateMessageConfiguration_U 
ON dbo.[TemplateMessageConfiguration] FOR update 
AS 
insert into audit.[TemplateMessageConfiguration](	 [TemplateMessageConfigurationId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageDefinitionId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,[ReleaseVersion]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[TemplateMessageConfigurationId]	 ,d.[TemplateMessageSchemeId]	 ,d.[TemplateMessageDefinitionId]	 ,d.[CommsMessageTemplateTypeId]	 ,d.[CommsMessageTemplateSubTypeId]	 ,d.[CommsMessageTemplateComponentTypeId]	 ,d.[CommsMessageTemplateComponentId]	 ,d.[ReleaseVersion]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.TemplateMessageConfigurationId = i.TemplateMessageConfigurationId 
insert into audit.[TemplateMessageConfiguration](	 [TemplateMessageConfigurationId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageDefinitionId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,[ReleaseVersion]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[TemplateMessageConfigurationId]	 ,i.[TemplateMessageSchemeId]	 ,i.[TemplateMessageDefinitionId]	 ,i.[CommsMessageTemplateTypeId]	 ,i.[CommsMessageTemplateSubTypeId]	 ,i.[CommsMessageTemplateComponentTypeId]	 ,i.[CommsMessageTemplateComponentId]	 ,i.[ReleaseVersion]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.TemplateMessageConfigurationId = i.TemplateMessageConfigurationId
GO
CREATE TRIGGER dbo.trgTemplateMessageConfiguration_I
ON dbo.[TemplateMessageConfiguration] FOR insert 
AS 
insert into audit.[TemplateMessageConfiguration](	 [TemplateMessageConfigurationId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageDefinitionId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,[ReleaseVersion]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[TemplateMessageConfigurationId]	 ,i.[TemplateMessageSchemeId]	 ,i.[TemplateMessageDefinitionId]	 ,i.[CommsMessageTemplateTypeId]	 ,i.[CommsMessageTemplateSubTypeId]	 ,i.[CommsMessageTemplateComponentTypeId]	 ,i.[CommsMessageTemplateComponentId]	 ,i.[ReleaseVersion]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTemplateMessageConfiguration_D
ON dbo.[TemplateMessageConfiguration] FOR delete 
AS 
insert into audit.[TemplateMessageConfiguration](	 [TemplateMessageConfigurationId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageDefinitionId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,[ReleaseVersion]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[TemplateMessageConfigurationId]	 ,d.[TemplateMessageSchemeId]	 ,d.[TemplateMessageDefinitionId]	 ,d.[CommsMessageTemplateTypeId]	 ,d.[CommsMessageTemplateSubTypeId]	 ,d.[CommsMessageTemplateComponentTypeId]	 ,d.[CommsMessageTemplateComponentId]	 ,d.[ReleaseVersion]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d