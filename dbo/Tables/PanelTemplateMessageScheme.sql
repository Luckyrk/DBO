CREATE TABLE [dbo].[PanelTemplateMessageScheme] (
    [PanelTemplateMessageSchemeId] INT              IDENTITY (1, 1) NOT NULL,
    [TemplateMessageSchemeId]      INT              NOT NULL,
    [GUIDReference]                UNIQUEIDENTIFIER NOT NULL,
    [panel_Id]                     UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelTemplateMessageScheme] PRIMARY KEY CLUSTERED ([PanelTemplateMessageSchemeId] ASC),
    CONSTRAINT [FK_dbo.PanelTemplateMessageScheme_dbo.Panel_panel_Id] FOREIGN KEY ([panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelTemplateMessageScheme_dbo.TemplateMessageScheme_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageSchemeId]
    ON [dbo].[PanelTemplateMessageScheme]([TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_panel_Id]
    ON [dbo].[PanelTemplateMessageScheme]([panel_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelTemplateMessageScheme_U 
ON dbo.[PanelTemplateMessageScheme] FOR update 
AS 
insert into audit.[PanelTemplateMessageScheme](	 [PanelTemplateMessageSchemeId]	 ,[TemplateMessageSchemeId]	 ,[GUIDReference]	 ,[panel_Id]	 ,AuditOperation) select 	 d.[PanelTemplateMessageSchemeId]	 ,d.[TemplateMessageSchemeId]	 ,d.[GUIDReference]	 ,d.[panel_Id],'O'  from 	 deleted d join inserted i on d.PanelTemplateMessageSchemeId = i.PanelTemplateMessageSchemeId 
insert into audit.[PanelTemplateMessageScheme](	 [PanelTemplateMessageSchemeId]	 ,[TemplateMessageSchemeId]	 ,[GUIDReference]	 ,[panel_Id]	 ,AuditOperation) select 	 i.[PanelTemplateMessageSchemeId]	 ,i.[TemplateMessageSchemeId]	 ,i.[GUIDReference]	 ,i.[panel_Id],'N'  from 	 deleted d join inserted i on d.PanelTemplateMessageSchemeId = i.PanelTemplateMessageSchemeId
GO
CREATE TRIGGER dbo.trgPanelTemplateMessageScheme_I
ON dbo.[PanelTemplateMessageScheme] FOR insert 
AS 
insert into audit.[PanelTemplateMessageScheme](	 [PanelTemplateMessageSchemeId]	 ,[TemplateMessageSchemeId]	 ,[GUIDReference]	 ,[panel_Id]	 ,AuditOperation) select 	 i.[PanelTemplateMessageSchemeId]	 ,i.[TemplateMessageSchemeId]	 ,i.[GUIDReference]	 ,i.[panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelTemplateMessageScheme_D
ON dbo.[PanelTemplateMessageScheme] FOR delete 
AS 
insert into audit.[PanelTemplateMessageScheme](	 [PanelTemplateMessageSchemeId]	 ,[TemplateMessageSchemeId]	 ,[GUIDReference]	 ,[panel_Id]	 ,AuditOperation) select 	 d.[PanelTemplateMessageSchemeId]	 ,d.[TemplateMessageSchemeId]	 ,d.[GUIDReference]	 ,d.[panel_Id],'D' from deleted d