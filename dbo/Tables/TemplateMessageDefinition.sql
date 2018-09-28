CREATE TABLE [dbo].[TemplateMessageDefinition] (
    [TemplateMessageDefinitionId]     BIGINT         NOT NULL,
    [TemplateMessageSchemeId]         INT            NOT NULL,
    [TemplateMessageThemeId]          BIGINT         NULL,
    [TemplateUsageIntentId]           INT            NOT NULL,
    [IsInspectionRequiredPriorToSend] BIT            NOT NULL,
    [Description]                     NVARCHAR (200) NULL,
    [TemplateMessageCategoryId]       BIGINT         NULL,
    [IsActive]                        BIT            NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TemplateMessageDefinition] PRIMARY KEY CLUSTERED ([TemplateMessageDefinitionId] ASC, [TemplateMessageSchemeId] ASC),
    CONSTRAINT [fk] FOREIGN KEY ([TemplateMessageCategoryId]) REFERENCES [dbo].[TemplateMessageCategories] ([TemplateMessageCategoryId]),
    CONSTRAINT [FK_dbo.TemplateMessageDefinition_dbo.TemplateMessageScheme_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId]),
    CONSTRAINT [FK_dbo.TemplateMessageDefinition_dbo.TemplateMessageTheme_TemplateMessageThemeId_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageThemeId], [TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageTheme] ([TemplateMessageThemeId], [TemplateMessageSchemeId]),
    CONSTRAINT [FK_dbo.TemplateMessageDefinition_dbo.TemplateUsageIntent_TemplateUsageIntentId] FOREIGN KEY ([TemplateUsageIntentId]) REFERENCES [dbo].[TemplateUsageIntent] ([TemplateUsageIntentId])
);












GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageDefinition]([TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageThemeId_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageDefinition]([TemplateMessageThemeId] ASC, [TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TemplateUsageIntentId]
    ON [dbo].[TemplateMessageDefinition]([TemplateUsageIntentId] ASC);


GO
CREATE TRIGGER dbo.trgTemplateMessageDefinition_U 
ON dbo.[TemplateMessageDefinition] FOR update 
AS 
insert into audit.[TemplateMessageDefinition](	 [TemplateMessageDefinitionId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageThemeId]	 ,[TemplateUsageIntentId]	 ,[IsInspectionRequiredPriorToSend]	 ,[Description]	 ,AuditOperation) select 	 d.[TemplateMessageDefinitionId]	 ,d.[TemplateMessageSchemeId]	 ,d.[TemplateMessageThemeId]	 ,d.[TemplateUsageIntentId]	 ,d.[IsInspectionRequiredPriorToSend]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.TemplateMessageDefinitionId = i.TemplateMessageDefinitionId	 and d.TemplateMessageSchemeId = i.TemplateMessageSchemeId 
insert into audit.[TemplateMessageDefinition](	 [TemplateMessageDefinitionId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageThemeId]	 ,[TemplateUsageIntentId]	 ,[IsInspectionRequiredPriorToSend]	 ,[Description]	 ,AuditOperation) select 	 i.[TemplateMessageDefinitionId]	 ,i.[TemplateMessageSchemeId]	 ,i.[TemplateMessageThemeId]	 ,i.[TemplateUsageIntentId]	 ,i.[IsInspectionRequiredPriorToSend]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.TemplateMessageDefinitionId = i.TemplateMessageDefinitionId	 and d.TemplateMessageSchemeId = i.TemplateMessageSchemeId
GO
CREATE TRIGGER dbo.trgTemplateMessageDefinition_I
ON dbo.[TemplateMessageDefinition] FOR insert 
AS 
insert into audit.[TemplateMessageDefinition](	 [TemplateMessageDefinitionId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageThemeId]	 ,[TemplateUsageIntentId]	 ,[IsInspectionRequiredPriorToSend]	 ,[Description]	 ,AuditOperation) select 	 i.[TemplateMessageDefinitionId]	 ,i.[TemplateMessageSchemeId]	 ,i.[TemplateMessageThemeId]	 ,i.[TemplateUsageIntentId]	 ,i.[IsInspectionRequiredPriorToSend]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTemplateMessageDefinition_D
ON dbo.[TemplateMessageDefinition] FOR delete 
AS 
insert into audit.[TemplateMessageDefinition](	 [TemplateMessageDefinitionId]	 ,[TemplateMessageSchemeId]	 ,[TemplateMessageThemeId]	 ,[TemplateUsageIntentId]	 ,[IsInspectionRequiredPriorToSend]	 ,[Description]	 ,AuditOperation) select 	 d.[TemplateMessageDefinitionId]	 ,d.[TemplateMessageSchemeId]	 ,d.[TemplateMessageThemeId]	 ,d.[TemplateUsageIntentId]	 ,d.[IsInspectionRequiredPriorToSend]	 ,d.[Description],'D' from deleted d