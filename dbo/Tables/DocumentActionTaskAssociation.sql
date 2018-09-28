CREATE TABLE [dbo].[DocumentActionTaskAssociation] (
    [DocumentActionTaskAssociationId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocumentId]                      BIGINT           NOT NULL,
    [ActionTaskId]                    UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DocumentActionTaskAssociation] PRIMARY KEY CLUSTERED ([DocumentActionTaskAssociationId] ASC),
    CONSTRAINT [FK_dbo.DocumentActionTaskAssociation_dbo.ActionTask_ActionTaskId] FOREIGN KEY ([ActionTaskId]) REFERENCES [dbo].[ActionTask] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DocumentActionTaskAssociation_dbo.Document_DocumentId] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[Document] ([DocumentId])
);






GO
CREATE NONCLUSTERED INDEX [IX_DocumentId]
    ON [dbo].[DocumentActionTaskAssociation]([DocumentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTaskId]
    ON [dbo].[DocumentActionTaskAssociation]([ActionTaskId] ASC);


GO
CREATE TRIGGER dbo.trgDocumentActionTaskAssociation_U 
ON dbo.[DocumentActionTaskAssociation] FOR update 
AS 
insert into audit.[DocumentActionTaskAssociation](	 [DocumentActionTaskAssociationId]	 ,[DocumentId]	 ,[ActionTaskId]	 ,AuditOperation) select 	 d.[DocumentActionTaskAssociationId]	 ,d.[DocumentId]	 ,d.[ActionTaskId],'O'  from 	 deleted d join inserted i on d.DocumentActionTaskAssociationId = i.DocumentActionTaskAssociationId 
insert into audit.[DocumentActionTaskAssociation](	 [DocumentActionTaskAssociationId]	 ,[DocumentId]	 ,[ActionTaskId]	 ,AuditOperation) select 	 i.[DocumentActionTaskAssociationId]	 ,i.[DocumentId]	 ,i.[ActionTaskId],'N'  from 	 deleted d join inserted i on d.DocumentActionTaskAssociationId = i.DocumentActionTaskAssociationId
GO
CREATE TRIGGER dbo.trgDocumentActionTaskAssociation_I
ON dbo.[DocumentActionTaskAssociation] FOR insert 
AS 
insert into audit.[DocumentActionTaskAssociation](	 [DocumentActionTaskAssociationId]	 ,[DocumentId]	 ,[ActionTaskId]	 ,AuditOperation) select 	 i.[DocumentActionTaskAssociationId]	 ,i.[DocumentId]	 ,i.[ActionTaskId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDocumentActionTaskAssociation_D
ON dbo.[DocumentActionTaskAssociation] FOR delete 
AS 
insert into audit.[DocumentActionTaskAssociation](	 [DocumentActionTaskAssociationId]	 ,[DocumentId]	 ,[ActionTaskId]	 ,AuditOperation) select 	 d.[DocumentActionTaskAssociationId]	 ,d.[DocumentId]	 ,d.[ActionTaskId],'D' from deleted d