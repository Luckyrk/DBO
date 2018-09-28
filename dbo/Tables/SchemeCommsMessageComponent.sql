CREATE TABLE [dbo].[SchemeCommsMessageComponent] (
    [SchemeCommsMessageComponentId]     BIGINT NOT NULL,
    [SchemeCommsMessageComponentTypeId] BIGINT NOT NULL,
    [CommsMessageTemplateComponentId]   BIGINT NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SchemeCommsMessageComponent] PRIMARY KEY CLUSTERED ([SchemeCommsMessageComponentId] ASC),
    CONSTRAINT [FK_dbo.SchemeCommsMessageComponent_dbo.CommsMessageTemplateComponent_CommsMessageTemplateComponentId] FOREIGN KEY ([CommsMessageTemplateComponentId]) REFERENCES [dbo].[CommsMessageTemplateComponent] ([CommsMessageTemplateComponentId]),
    CONSTRAINT [FK_dbo.SchemeCommsMessageComponent_dbo.SchemeCommsMessageComponentType_SchemeCommsMessageComponentTypeId] FOREIGN KEY ([SchemeCommsMessageComponentTypeId]) REFERENCES [dbo].[SchemeCommsMessageComponentType] ([SchemeCommsMessageComponentTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_SchemeCommsMessageComponentTypeId]
    ON [dbo].[SchemeCommsMessageComponent]([SchemeCommsMessageComponentTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateComponentId]
    ON [dbo].[SchemeCommsMessageComponent]([CommsMessageTemplateComponentId] ASC);


GO
CREATE TRIGGER dbo.trgSchemeCommsMessageComponent_U 
ON dbo.[SchemeCommsMessageComponent] FOR update 
AS 
insert into audit.[SchemeCommsMessageComponent](	 [SchemeCommsMessageComponentId]	 ,[SchemeCommsMessageComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,AuditOperation) select 	 d.[SchemeCommsMessageComponentId]	 ,d.[SchemeCommsMessageComponentTypeId]	 ,d.[CommsMessageTemplateComponentId],'O'  from 	 deleted d join inserted i on d.SchemeCommsMessageComponentId = i.SchemeCommsMessageComponentId 
insert into audit.[SchemeCommsMessageComponent](	 [SchemeCommsMessageComponentId]	 ,[SchemeCommsMessageComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,AuditOperation) select 	 i.[SchemeCommsMessageComponentId]	 ,i.[SchemeCommsMessageComponentTypeId]	 ,i.[CommsMessageTemplateComponentId],'N'  from 	 deleted d join inserted i on d.SchemeCommsMessageComponentId = i.SchemeCommsMessageComponentId
GO
CREATE TRIGGER dbo.trgSchemeCommsMessageComponent_I
ON dbo.[SchemeCommsMessageComponent] FOR insert 
AS 
insert into audit.[SchemeCommsMessageComponent](	 [SchemeCommsMessageComponentId]	 ,[SchemeCommsMessageComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,AuditOperation) select 	 i.[SchemeCommsMessageComponentId]	 ,i.[SchemeCommsMessageComponentTypeId]	 ,i.[CommsMessageTemplateComponentId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgSchemeCommsMessageComponent_D
ON dbo.[SchemeCommsMessageComponent] FOR delete 
AS 
insert into audit.[SchemeCommsMessageComponent](	 [SchemeCommsMessageComponentId]	 ,[SchemeCommsMessageComponentTypeId]	 ,[CommsMessageTemplateComponentId]	 ,AuditOperation) select 	 d.[SchemeCommsMessageComponentId]	 ,d.[SchemeCommsMessageComponentTypeId]	 ,d.[CommsMessageTemplateComponentId],'D' from deleted d