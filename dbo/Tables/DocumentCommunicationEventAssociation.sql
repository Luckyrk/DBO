CREATE TABLE [dbo].[DocumentCommunicationEventAssociation] (
    [DocumentCommunicationEventAssociationId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocumentId]                              BIGINT           NOT NULL,
    [CommunicationEventId]                    UNIQUEIDENTIFIER NOT NULL,
	[Country_Id]							  UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DocumentCommunicationEventAssociation] PRIMARY KEY CLUSTERED ([DocumentCommunicationEventAssociationId] ASC),
    CONSTRAINT [FK_dbo.DocumentCommunicationEventAssociation_dbo.CommunicationEvent_CommunicationEventId] FOREIGN KEY ([CommunicationEventId]) REFERENCES [dbo].[CommunicationEvent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DocumentCommunicationEventAssociation_dbo.Document_DocumentId] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[Document] ([DocumentId])
);






GO
CREATE NONCLUSTERED INDEX [IX_DocumentId]
    ON [dbo].[DocumentCommunicationEventAssociation]([DocumentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommunicationEventId]
    ON [dbo].[DocumentCommunicationEventAssociation]([CommunicationEventId] ASC);


GO
CREATE TRIGGER dbo.trgDocumentCommunicationEventAssociation_U 
ON dbo.[DocumentCommunicationEventAssociation] FOR update 
AS 
insert into audit.[DocumentCommunicationEventAssociation](	 [DocumentCommunicationEventAssociationId]	 ,[DocumentId]	 ,[CommunicationEventId]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[DocumentCommunicationEventAssociationId]	 ,d.[DocumentId]	 ,d.[CommunicationEventId],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.DocumentCommunicationEventAssociationId = i.DocumentCommunicationEventAssociationId 
insert into audit.[DocumentCommunicationEventAssociation](	 [DocumentCommunicationEventAssociationId]	 ,[DocumentId]	 ,[CommunicationEventId]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[DocumentCommunicationEventAssociationId]	 ,i.[DocumentId]	 ,i.[CommunicationEventId],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.DocumentCommunicationEventAssociationId = i.DocumentCommunicationEventAssociationId
GO
CREATE TRIGGER dbo.trgDocumentCommunicationEventAssociation_I
ON dbo.[DocumentCommunicationEventAssociation] FOR insert 
AS 
insert into audit.[DocumentCommunicationEventAssociation](	 [DocumentCommunicationEventAssociationId]	 ,[DocumentId]	 ,[CommunicationEventId]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[DocumentCommunicationEventAssociationId]	 ,i.[DocumentId]	 ,i.[CommunicationEventId],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDocumentCommunicationEventAssociation_D
ON dbo.[DocumentCommunicationEventAssociation] FOR delete 
AS 
insert into audit.[DocumentCommunicationEventAssociation](	 [DocumentCommunicationEventAssociationId]	 ,[DocumentId]	 ,[CommunicationEventId]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[DocumentCommunicationEventAssociationId]	 ,d.[DocumentId]	 ,d.[CommunicationEventId],d.[Country_Id],'D' from deleted d