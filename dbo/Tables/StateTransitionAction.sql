CREATE TABLE [dbo].[StateTransitionAction] (
    [GUIDReference]   UNIQUEIDENTIFIER NOT NULL,
    [NextAction_Id]   UNIQUEIDENTIFIER NULL,
    [BusinessRule_Id] UNIQUEIDENTIFIER NULL,
    [Type]            NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateTransitionAction] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StateTransitionAction_dbo.BusinessRule_BusinessRule_Id] FOREIGN KEY ([BusinessRule_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateTransitionAction_dbo.StateTransitionAction_NextAction_Id] FOREIGN KEY ([NextAction_Id]) REFERENCES [dbo].[StateTransitionAction] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_NextAction_Id]
    ON [dbo].[StateTransitionAction]([NextAction_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_BusinessRule_Id]
    ON [dbo].[StateTransitionAction]([BusinessRule_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateTransitionAction_U 
ON dbo.[StateTransitionAction] FOR update 
AS 
insert into audit.[StateTransitionAction](	 [GUIDReference]	 ,[NextAction_Id]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[NextAction_Id]	 ,d.[BusinessRule_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StateTransitionAction](	 [GUIDReference]	 ,[NextAction_Id]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[NextAction_Id]	 ,i.[BusinessRule_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgStateTransitionAction_I
ON dbo.[StateTransitionAction] FOR insert 
AS 
insert into audit.[StateTransitionAction](	 [GUIDReference]	 ,[NextAction_Id]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[NextAction_Id]	 ,i.[BusinessRule_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStateTransitionAction_D
ON dbo.[StateTransitionAction] FOR delete 
AS 
insert into audit.[StateTransitionAction](	 [GUIDReference]	 ,[NextAction_Id]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[NextAction_Id]	 ,d.[BusinessRule_Id]	 ,d.[Type],'D' from deleted d