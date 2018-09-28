CREATE TABLE [dbo].[GenericEventAudit] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [EventType]          NVARCHAR (300)   NULL,
    [Status]             NVARCHAR (100)   NULL,
    [TransactionId]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [ProcessorType]      NVARCHAR (100)   NULL,
    CONSTRAINT [PK_dbo.GenericEventAudit] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);




GO
CREATE TRIGGER dbo.trgGenericEventAudit_U 
ON dbo.[GenericEventAudit] FOR update 
AS 
insert into audit.[GenericEventAudit](	 [GUIDReference]	 ,[EventType]	 ,[Status]	 ,[TransactionId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ProcessorType]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[EventType]	 ,d.[Status]	 ,d.[TransactionId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ProcessorType],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[GenericEventAudit](	 [GUIDReference]	 ,[EventType]	 ,[Status]	 ,[TransactionId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ProcessorType]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[EventType]	 ,i.[Status]	 ,i.[TransactionId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ProcessorType],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgGenericEventAudit_I
ON dbo.[GenericEventAudit] FOR insert 
AS 
insert into audit.[GenericEventAudit](	 [GUIDReference]	 ,[EventType]	 ,[Status]	 ,[TransactionId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ProcessorType]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[EventType]	 ,i.[Status]	 ,i.[TransactionId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ProcessorType],'I' from inserted i
GO
CREATE TRIGGER dbo.trgGenericEventAudit_D
ON dbo.[GenericEventAudit] FOR delete 
AS 
insert into audit.[GenericEventAudit](	 [GUIDReference]	 ,[EventType]	 ,[Status]	 ,[TransactionId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ProcessorType]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[EventType]	 ,d.[Status]	 ,d.[TransactionId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ProcessorType],'D' from deleted d