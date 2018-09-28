﻿CREATE TABLE [dbo].[DocumentCommunicationEventAssociation] (
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
insert into audit.[DocumentCommunicationEventAssociation](
insert into audit.[DocumentCommunicationEventAssociation](
GO
CREATE TRIGGER dbo.trgDocumentCommunicationEventAssociation_I
ON dbo.[DocumentCommunicationEventAssociation] FOR insert 
AS 
insert into audit.[DocumentCommunicationEventAssociation](
GO
CREATE TRIGGER dbo.trgDocumentCommunicationEventAssociation_D
ON dbo.[DocumentCommunicationEventAssociation] FOR delete 
AS 
insert into audit.[DocumentCommunicationEventAssociation](