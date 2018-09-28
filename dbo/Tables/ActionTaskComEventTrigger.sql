CREATE TABLE [dbo].[ActionTaskComEventTrigger] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [WhatInitiateWhat]   INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Action_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Communication_Id]   UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ActionTaskComEventTrigger] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ActionTaskComEventTrigger_dbo.ActionTask_Action_Id] FOREIGN KEY ([Action_Id]) REFERENCES [dbo].[ActionTask] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionTaskComEventTrigger_dbo.CommunicationEvent_Communication_Id] FOREIGN KEY ([Communication_Id]) REFERENCES [dbo].[CommunicationEvent] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Action_Id]
    ON [dbo].[ActionTaskComEventTrigger]([Action_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Communication_Id]
    ON [dbo].[ActionTaskComEventTrigger]([Communication_Id] ASC);


GO
CREATE TRIGGER dbo.trgActionTaskComEventTrigger_U 
ON dbo.[ActionTaskComEventTrigger] FOR update 
AS 
insert into audit.[ActionTaskComEventTrigger](	 [GUIDReference]	 ,[WhatInitiateWhat]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Action_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[WhatInitiateWhat]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Action_Id]	 ,d.[Communication_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ActionTaskComEventTrigger](	 [GUIDReference]	 ,[WhatInitiateWhat]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Action_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[WhatInitiateWhat]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Action_Id]	 ,i.[Communication_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgActionTaskComEventTrigger_I
ON dbo.[ActionTaskComEventTrigger] FOR insert 
AS 
insert into audit.[ActionTaskComEventTrigger](	 [GUIDReference]	 ,[WhatInitiateWhat]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Action_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[WhatInitiateWhat]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Action_Id]	 ,i.[Communication_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgActionTaskComEventTrigger_D
ON dbo.[ActionTaskComEventTrigger] FOR delete 
AS 
insert into audit.[ActionTaskComEventTrigger](	 [GUIDReference]	 ,[WhatInitiateWhat]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Action_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[WhatInitiateWhat]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Action_Id]	 ,d.[Communication_Id],'D' from deleted d