CREATE TABLE [dbo].[CommunicationEventReasonTypeActionTaskType] (
    [CommunicationEventReasonType_Id] UNIQUEIDENTIFIER NOT NULL,
    [ActionTaskType_Id]               UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CommunicationEventReasonTypeActionTaskType] PRIMARY KEY CLUSTERED ([CommunicationEventReasonType_Id] ASC, [ActionTaskType_Id] ASC),
    CONSTRAINT [FK_dbo.CommunicationEventReasonTypeActionTaskType_dbo.ActionTaskType_ActionTaskType_Id] FOREIGN KEY ([ActionTaskType_Id]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.CommunicationEventReasonTypeActionTaskType_dbo.CommunicationEventReasonType_CommunicationEventReasonType_Id] FOREIGN KEY ([CommunicationEventReasonType_Id]) REFERENCES [dbo].[CommunicationEventReasonType] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_CommunicationEventReasonType_Id]
    ON [dbo].[CommunicationEventReasonTypeActionTaskType]([CommunicationEventReasonType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTaskType_Id]
    ON [dbo].[CommunicationEventReasonTypeActionTaskType]([ActionTaskType_Id] ASC);


GO
CREATE TRIGGER dbo.trgCommunicationEventReasonTypeActionTaskType_U 
ON dbo.[CommunicationEventReasonTypeActionTaskType] FOR update 
AS 
insert into audit.[CommunicationEventReasonTypeActionTaskType](	 [CommunicationEventReasonType_Id]	 ,[ActionTaskType_Id]	 ,AuditOperation) select 	 d.[CommunicationEventReasonType_Id]	 ,d.[ActionTaskType_Id],'O'  from 	 deleted d join inserted i on d.ActionTaskType_Id = i.ActionTaskType_Id	 and d.CommunicationEventReasonType_Id = i.CommunicationEventReasonType_Id 
insert into audit.[CommunicationEventReasonTypeActionTaskType](	 [CommunicationEventReasonType_Id]	 ,[ActionTaskType_Id]	 ,AuditOperation) select 	 i.[CommunicationEventReasonType_Id]	 ,i.[ActionTaskType_Id],'N'  from 	 deleted d join inserted i on d.ActionTaskType_Id = i.ActionTaskType_Id	 and d.CommunicationEventReasonType_Id = i.CommunicationEventReasonType_Id
GO
CREATE TRIGGER dbo.trgCommunicationEventReasonTypeActionTaskType_I
ON dbo.[CommunicationEventReasonTypeActionTaskType] FOR insert 
AS 
insert into audit.[CommunicationEventReasonTypeActionTaskType](	 [CommunicationEventReasonType_Id]	 ,[ActionTaskType_Id]	 ,AuditOperation) select 	 i.[CommunicationEventReasonType_Id]	 ,i.[ActionTaskType_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommunicationEventReasonTypeActionTaskType_D
ON dbo.[CommunicationEventReasonTypeActionTaskType] FOR delete 
AS 
insert into audit.[CommunicationEventReasonTypeActionTaskType](	 [CommunicationEventReasonType_Id]	 ,[ActionTaskType_Id]	 ,AuditOperation) select 	 d.[CommunicationEventReasonType_Id]	 ,d.[ActionTaskType_Id],'D' from deleted d