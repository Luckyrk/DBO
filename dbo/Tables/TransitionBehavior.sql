CREATE TABLE [dbo].[TransitionBehavior] (
    [GUIDReference]         UNIQUEIDENTIFIER NOT NULL,
    [TransitionStrategy_Id] UNIQUEIDENTIFIER NOT NULL,
    [Type]                  NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TransitionBehavior] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.TransitionBehavior_dbo.StateTransitionStrategy_TransitionStrategy_Id] FOREIGN KEY ([TransitionStrategy_Id]) REFERENCES [dbo].[StateTransitionStrategy] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_TransitionStrategy_Id]
    ON [dbo].[TransitionBehavior]([TransitionStrategy_Id] ASC);


GO
CREATE TRIGGER dbo.trgTransitionBehavior_U 
ON dbo.[TransitionBehavior] FOR update 
AS 
insert into audit.[TransitionBehavior](	 [GUIDReference]	 ,[TransitionStrategy_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[TransitionStrategy_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[TransitionBehavior](	 [GUIDReference]	 ,[TransitionStrategy_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[TransitionStrategy_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgTransitionBehavior_I
ON dbo.[TransitionBehavior] FOR insert 
AS 
insert into audit.[TransitionBehavior](	 [GUIDReference]	 ,[TransitionStrategy_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[TransitionStrategy_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTransitionBehavior_D
ON dbo.[TransitionBehavior] FOR delete 
AS 
insert into audit.[TransitionBehavior](	 [GUIDReference]	 ,[TransitionStrategy_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[TransitionStrategy_Id]	 ,d.[Type],'D' from deleted d