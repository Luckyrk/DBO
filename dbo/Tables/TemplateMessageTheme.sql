CREATE TABLE [dbo].[TemplateMessageTheme] (
    [TemplateMessageThemeId]  BIGINT         NOT NULL,
    [TemplateMessageSchemeId] INT            NOT NULL,
    [ThemeRanking]            INT            NOT NULL,
    [Description]             NVARCHAR (100) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TemplateMessageTheme] PRIMARY KEY CLUSTERED ([TemplateMessageThemeId] ASC, [TemplateMessageSchemeId] ASC),
    CONSTRAINT [FK_dbo.TemplateMessageTheme_dbo.TemplateMessageScheme_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageTheme]([TemplateMessageSchemeId] ASC);


GO
CREATE TRIGGER dbo.trgTemplateMessageTheme_U 
ON dbo.[TemplateMessageTheme] FOR update 
AS 
insert into audit.[TemplateMessageTheme](	 [TemplateMessageThemeId]	 ,[TemplateMessageSchemeId]	 ,[ThemeRanking]	 ,[Description]	 ,AuditOperation) select 	 d.[TemplateMessageThemeId]	 ,d.[TemplateMessageSchemeId]	 ,d.[ThemeRanking]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.TemplateMessageSchemeId = i.TemplateMessageSchemeId	 and d.TemplateMessageThemeId = i.TemplateMessageThemeId 
insert into audit.[TemplateMessageTheme](	 [TemplateMessageThemeId]	 ,[TemplateMessageSchemeId]	 ,[ThemeRanking]	 ,[Description]	 ,AuditOperation) select 	 i.[TemplateMessageThemeId]	 ,i.[TemplateMessageSchemeId]	 ,i.[ThemeRanking]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.TemplateMessageSchemeId = i.TemplateMessageSchemeId	 and d.TemplateMessageThemeId = i.TemplateMessageThemeId
GO
CREATE TRIGGER dbo.trgTemplateMessageTheme_I
ON dbo.[TemplateMessageTheme] FOR insert 
AS 
insert into audit.[TemplateMessageTheme](	 [TemplateMessageThemeId]	 ,[TemplateMessageSchemeId]	 ,[ThemeRanking]	 ,[Description]	 ,AuditOperation) select 	 i.[TemplateMessageThemeId]	 ,i.[TemplateMessageSchemeId]	 ,i.[ThemeRanking]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTemplateMessageTheme_D
ON dbo.[TemplateMessageTheme] FOR delete 
AS 
insert into audit.[TemplateMessageTheme](	 [TemplateMessageThemeId]	 ,[TemplateMessageSchemeId]	 ,[ThemeRanking]	 ,[Description]	 ,AuditOperation) select 	 d.[TemplateMessageThemeId]	 ,d.[TemplateMessageSchemeId]	 ,d.[ThemeRanking]	 ,d.[Description],'D' from deleted d