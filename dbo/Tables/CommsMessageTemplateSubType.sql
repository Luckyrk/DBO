CREATE TABLE [dbo].[CommsMessageTemplateSubType] (
    [CommsMessageTemplateSubTypeId] INT           NOT NULL,
    [CommsMessageTemplateTypeId]    INT           NOT NULL,
    [Description]                   NVARCHAR (50) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CommsMessageTemplateSubType] PRIMARY KEY CLUSTERED ([CommsMessageTemplateSubTypeId] ASC, [CommsMessageTemplateTypeId] ASC),
    CONSTRAINT [FK_dbo.CommsMessageTemplateSubType_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[CommsMessageTemplateSubType]([CommsMessageTemplateTypeId] ASC);


GO
CREATE TRIGGER dbo.trgCommsMessageTemplateSubType_U 
ON dbo.[CommsMessageTemplateSubType] FOR update 
AS 
insert into audit.[CommsMessageTemplateSubType](	 [CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[CommsMessageTemplateSubTypeId]	 ,d.[CommsMessageTemplateTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.CommsMessageTemplateSubTypeId = i.CommsMessageTemplateSubTypeId	 and d.CommsMessageTemplateTypeId = i.CommsMessageTemplateTypeId 
insert into audit.[CommsMessageTemplateSubType](	 [CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[CommsMessageTemplateSubTypeId]	 ,i.[CommsMessageTemplateTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.CommsMessageTemplateSubTypeId = i.CommsMessageTemplateSubTypeId	 and d.CommsMessageTemplateTypeId = i.CommsMessageTemplateTypeId
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateSubType_I
ON dbo.[CommsMessageTemplateSubType] FOR insert 
AS 
insert into audit.[CommsMessageTemplateSubType](	 [CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[CommsMessageTemplateSubTypeId]	 ,i.[CommsMessageTemplateTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateSubType_D
ON dbo.[CommsMessageTemplateSubType] FOR delete 
AS 
insert into audit.[CommsMessageTemplateSubType](	 [CommsMessageTemplateSubTypeId]	 ,[CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[CommsMessageTemplateSubTypeId]	 ,d.[CommsMessageTemplateTypeId]	 ,d.[Description],'D' from deleted d