CREATE TABLE [dbo].[CommsMessageTemplateComponent] (
    [CommsMessageTemplateComponentId]     BIGINT         NOT NULL,
    [CommsMessageTemplateTypeId]          INT            NOT NULL,
    [CommsMessageTemplateSubTypeId]       INT            NOT NULL,
    [CommsMessageTemplateComponentTypeId] INT            NOT NULL,
    [Description]                         NVARCHAR (200) NULL,
    [Subject]                             NVARCHAR (200) NULL,
    [TextContent]                         NVARCHAR (MAX) NULL,
    [GPSUser]                             NVARCHAR (50)  NULL,
    [GPSUpdateTimestamp]                  DATETIME       NULL,
    [CreationTimeStamp]                   DATETIME       NULL,
    [ActiveFrom]                          DATETIME       NOT NULL,
    [ActiveTo]                            DATETIME       NULL,
    [CountryId]                           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.CommsMessageTemplateComponent] PRIMARY KEY CLUSTERED ([CommsMessageTemplateComponentId] ASC),
    CONSTRAINT [FK_dbo.CommsMessageTemplateComponent_dbo.CommsMessageTemplateComponentType_CommsMessageTemplateTypeId_CommsMessageTemplateCompon] FOREIGN KEY ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]) REFERENCES [dbo].[CommsMessageTemplateComponentType] ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]),
    CONSTRAINT [FK_dbo.CommsMessageTemplateComponent_dbo.CommsMessageTemplateSubType_CommsMessageTemplateSubTypeId_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateSubTypeId], [CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateSubType] ([CommsMessageTemplateSubTypeId], [CommsMessageTemplateTypeId]),
    CONSTRAINT [FK_dbo.CommsMessageTemplateComponent_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId])
);








GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[CommsMessageTemplateComponent]([CommsMessageTemplateTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateSubTypeId_CommsMessageTemplateTypeId]
    ON [dbo].[CommsMessageTemplateComponent]([CommsMessageTemplateSubTypeId] ASC, [CommsMessageTemplateTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId_CommsMessageTemplateComponentTypeId]
    ON [dbo].[CommsMessageTemplateComponent]([CommsMessageTemplateTypeId] ASC, [CommsMessageTemplateComponentTypeId] ASC);


GO
CREATE TRIGGER dbo.trgCommsMessageTemplateComponent_U 
ON dbo.[CommsMessageTemplateComponent] FOR update 
AS 
insert into audit.[CommsMessageTemplateComponent](	 [CommsMessageTemplateComponentId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,[Subject]	 ,[TextContent]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[CommsMessageTemplateComponentId]	 ,d.[CommsMessageTemplateTypeId]	 ,d.[CommsMessageTemplateSubTypeId]	 ,d.[CommsMessageTemplateComponentTypeId]	 ,d.[Description]	 ,d.[Subject]	 ,d.[TextContent]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.CommsMessageTemplateComponentId = i.CommsMessageTemplateComponentId 
insert into audit.[CommsMessageTemplateComponent](	 [CommsMessageTemplateComponentId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,[Subject]	 ,[TextContent]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[CommsMessageTemplateComponentId]	 ,i.[CommsMessageTemplateTypeId]	 ,i.[CommsMessageTemplateSubTypeId]	 ,i.[CommsMessageTemplateComponentTypeId]	 ,i.[Description]	 ,i.[Subject]	 ,i.[TextContent]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.CommsMessageTemplateComponentId = i.CommsMessageTemplateComponentId
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateComponent_I
ON dbo.[CommsMessageTemplateComponent] FOR insert 
AS 
insert into audit.[CommsMessageTemplateComponent](	 [CommsMessageTemplateComponentId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,[Subject]	 ,[TextContent]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[CommsMessageTemplateComponentId]	 ,i.[CommsMessageTemplateTypeId]	 ,i.[CommsMessageTemplateSubTypeId]	 ,i.[CommsMessageTemplateComponentTypeId]	 ,i.[Description]	 ,i.[Subject]	 ,i.[TextContent]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateComponent_D
ON dbo.[CommsMessageTemplateComponent] FOR delete 
AS 
insert into audit.[CommsMessageTemplateComponent](	 [CommsMessageTemplateComponentId]	 ,[CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,[Subject]	 ,[TextContent]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[CommsMessageTemplateComponentId]	 ,d.[CommsMessageTemplateTypeId]	 ,d.[CommsMessageTemplateSubTypeId]	 ,d.[CommsMessageTemplateComponentTypeId]	 ,d.[Description]	 ,d.[Subject]	 ,d.[TextContent]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d