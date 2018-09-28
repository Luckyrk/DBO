CREATE TABLE [dbo].[ReasonForChangeStateAvailableTransition] (
    [AvailableTransition_Id]  UNIQUEIDENTIFIER NOT NULL,
    [ReasonForChangeState_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ReasonForChangeStateAvailableTransition] PRIMARY KEY CLUSTERED ([AvailableTransition_Id] ASC, [ReasonForChangeState_Id] ASC),
    CONSTRAINT [FK_dbo.ReasonForChangeStateAvailableTransition_dbo.ReasonForChangeState_ReasonForChangeState_Id] FOREIGN KEY ([ReasonForChangeState_Id]) REFERENCES [dbo].[ReasonForChangeState] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ReasonForChangeStateAvailableTransition_dbo.StateTransition_AvailableTransition_Id] FOREIGN KEY ([AvailableTransition_Id]) REFERENCES [dbo].[StateTransition] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_AvailableTransition_Id]
    ON [dbo].[ReasonForChangeStateAvailableTransition]([AvailableTransition_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ReasonForChangeState_Id]
    ON [dbo].[ReasonForChangeStateAvailableTransition]([ReasonForChangeState_Id] ASC);


GO
CREATE TRIGGER dbo.trgReasonForChangeStateAvailableTransition_U 
ON dbo.[ReasonForChangeStateAvailableTransition] FOR update 
AS 
insert into audit.[ReasonForChangeStateAvailableTransition](	 [AvailableTransition_Id]	 ,[ReasonForChangeState_Id]	 ,AuditOperation) select 	 d.[AvailableTransition_Id]	 ,d.[ReasonForChangeState_Id],'O'  from 	 deleted d join inserted i on d.AvailableTransition_Id = i.AvailableTransition_Id	 and d.ReasonForChangeState_Id = i.ReasonForChangeState_Id 
insert into audit.[ReasonForChangeStateAvailableTransition](	 [AvailableTransition_Id]	 ,[ReasonForChangeState_Id]	 ,AuditOperation) select 	 i.[AvailableTransition_Id]	 ,i.[ReasonForChangeState_Id],'N'  from 	 deleted d join inserted i on d.AvailableTransition_Id = i.AvailableTransition_Id	 and d.ReasonForChangeState_Id = i.ReasonForChangeState_Id
GO
CREATE TRIGGER dbo.trgReasonForChangeStateAvailableTransition_I
ON dbo.[ReasonForChangeStateAvailableTransition] FOR insert 
AS 
insert into audit.[ReasonForChangeStateAvailableTransition](	 [AvailableTransition_Id]	 ,[ReasonForChangeState_Id]	 ,AuditOperation) select 	 i.[AvailableTransition_Id]	 ,i.[ReasonForChangeState_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgReasonForChangeStateAvailableTransition_D
ON dbo.[ReasonForChangeStateAvailableTransition] FOR delete 
AS 
insert into audit.[ReasonForChangeStateAvailableTransition](	 [AvailableTransition_Id]	 ,[ReasonForChangeState_Id]	 ,AuditOperation) select 	 d.[AvailableTransition_Id]	 ,d.[ReasonForChangeState_Id],'D' from deleted d