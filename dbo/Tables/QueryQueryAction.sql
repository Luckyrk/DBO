CREATE TABLE [dbo].[QueryQueryAction] (
    [Query_Id]       UNIQUEIDENTIFIER NOT NULL,
    [QueryAction_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.QueryQueryAction] PRIMARY KEY CLUSTERED ([Query_Id] ASC, [QueryAction_Id] ASC),
    CONSTRAINT [FK_dbo.QueryQueryAction_dbo.PreDefinedQuery_Query_Id] FOREIGN KEY ([Query_Id]) REFERENCES [dbo].[PreDefinedQuery] ([PreDefinedQueryId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.QueryQueryAction_dbo.QueryAction_QueryAction_Id] FOREIGN KEY ([QueryAction_Id]) REFERENCES [dbo].[QueryAction] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Query_Id]
    ON [dbo].[QueryQueryAction]([Query_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_QueryAction_Id]
    ON [dbo].[QueryQueryAction]([QueryAction_Id] ASC);


GO
CREATE TRIGGER dbo.trgQueryQueryAction_U 
ON dbo.[QueryQueryAction] FOR update 
AS 
insert into audit.[QueryQueryAction](	 [Query_Id]	 ,[QueryAction_Id]	 ,AuditOperation) select 	 d.[Query_Id]	 ,d.[QueryAction_Id],'O'  from 	 deleted d join inserted i on d.Query_Id = i.Query_Id	 and d.QueryAction_Id = i.QueryAction_Id 
insert into audit.[QueryQueryAction](	 [Query_Id]	 ,[QueryAction_Id]	 ,AuditOperation) select 	 i.[Query_Id]	 ,i.[QueryAction_Id],'N'  from 	 deleted d join inserted i on d.Query_Id = i.Query_Id	 and d.QueryAction_Id = i.QueryAction_Id
GO
CREATE TRIGGER dbo.trgQueryQueryAction_I
ON dbo.[QueryQueryAction] FOR insert 
AS 
insert into audit.[QueryQueryAction](	 [Query_Id]	 ,[QueryAction_Id]	 ,AuditOperation) select 	 i.[Query_Id]	 ,i.[QueryAction_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgQueryQueryAction_D
ON dbo.[QueryQueryAction] FOR delete 
AS 
insert into audit.[QueryQueryAction](	 [Query_Id]	 ,[QueryAction_Id]	 ,AuditOperation) select 	 d.[Query_Id]	 ,d.[QueryAction_Id],'D' from deleted d