CREATE TABLE [dbo].[StateTransitionStrategy] (
    [GUIDReference]   UNIQUEIDENTIFIER NOT NULL,
    [BusinessRule_Id] UNIQUEIDENTIFIER NULL,
    [Type]            NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateTransitionStrategy] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StateTransitionStrategy_dbo.BusinessRule_BusinessRule_Id] FOREIGN KEY ([BusinessRule_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_BusinessRule_Id]
    ON [dbo].[StateTransitionStrategy]([BusinessRule_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateTransitionStrategy_U 
ON dbo.[StateTransitionStrategy] FOR update 
AS 
insert into audit.[StateTransitionStrategy](	 [GUIDReference]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[BusinessRule_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StateTransitionStrategy](	 [GUIDReference]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[BusinessRule_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgStateTransitionStrategy_I
ON dbo.[StateTransitionStrategy] FOR insert 
AS 
insert into audit.[StateTransitionStrategy](	 [GUIDReference]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[BusinessRule_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStateTransitionStrategy_D
ON dbo.[StateTransitionStrategy] FOR delete 
AS 
insert into audit.[StateTransitionStrategy](	 [GUIDReference]	 ,[BusinessRule_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[BusinessRule_Id]	 ,d.[Type],'D' from deleted d