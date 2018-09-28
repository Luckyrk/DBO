CREATE TABLE [dbo].[CommsMessageTemplateComponentType] (
    [CommsMessageTemplateTypeId]          INT           NOT NULL,
    [CommsMessageTemplateComponentTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Description]                         NVARCHAR (50) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CommsMessageTemplateComponentType] PRIMARY KEY CLUSTERED ([CommsMessageTemplateTypeId] ASC, [CommsMessageTemplateComponentTypeId] ASC),
    CONSTRAINT [FK_dbo.CommsMessageTemplateComponentType_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId])
);










GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[CommsMessageTemplateComponentType]([CommsMessageTemplateTypeId] ASC);


GO
CREATE TRIGGER dbo.trgCommsMessageTemplateComponentType_U 
ON dbo.[CommsMessageTemplateComponentType] FOR update 
AS 
insert into audit.[CommsMessageTemplateComponentType](	 [CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[CommsMessageTemplateTypeId]	 ,d.[CommsMessageTemplateComponentTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.CommsMessageTemplateComponentTypeId = i.CommsMessageTemplateComponentTypeId	 and d.CommsMessageTemplateTypeId = i.CommsMessageTemplateTypeId 
insert into audit.[CommsMessageTemplateComponentType](	 [CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[CommsMessageTemplateTypeId]	 ,i.[CommsMessageTemplateComponentTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.CommsMessageTemplateComponentTypeId = i.CommsMessageTemplateComponentTypeId	 and d.CommsMessageTemplateTypeId = i.CommsMessageTemplateTypeId
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateComponentType_I
ON dbo.[CommsMessageTemplateComponentType] FOR insert 
AS 
insert into audit.[CommsMessageTemplateComponentType](	 [CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[CommsMessageTemplateTypeId]	 ,i.[CommsMessageTemplateComponentTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateComponentType_D
ON dbo.[CommsMessageTemplateComponentType] FOR delete 
AS 
insert into audit.[CommsMessageTemplateComponentType](	 [CommsMessageTemplateTypeId]	 ,[CommsMessageTemplateComponentTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[CommsMessageTemplateTypeId]	 ,d.[CommsMessageTemplateComponentTypeId]	 ,d.[Description],'D' from deleted d