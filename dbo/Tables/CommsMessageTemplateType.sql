CREATE TABLE [dbo].[CommsMessageTemplateType] (
    [CommsMessageTemplateTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Description]                NVARCHAR (50) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CommsMessageTemplateType] PRIMARY KEY CLUSTERED ([CommsMessageTemplateTypeId] ASC)
);








GO
CREATE TRIGGER dbo.trgCommsMessageTemplateType_U 
ON dbo.[CommsMessageTemplateType] FOR update 
AS 
insert into audit.[CommsMessageTemplateType](	 [CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[CommsMessageTemplateTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.CommsMessageTemplateTypeId = i.CommsMessageTemplateTypeId 
insert into audit.[CommsMessageTemplateType](	 [CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[CommsMessageTemplateTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.CommsMessageTemplateTypeId = i.CommsMessageTemplateTypeId
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateType_I
ON dbo.[CommsMessageTemplateType] FOR insert 
AS 
insert into audit.[CommsMessageTemplateType](	 [CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[CommsMessageTemplateTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateType_D
ON dbo.[CommsMessageTemplateType] FOR delete 
AS 
insert into audit.[CommsMessageTemplateType](	 [CommsMessageTemplateTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[CommsMessageTemplateTypeId]	 ,d.[Description],'D' from deleted d