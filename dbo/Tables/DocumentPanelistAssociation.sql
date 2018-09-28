﻿CREATE TABLE [dbo].[DocumentPanelistAssociation] (
    [DocumentPanelistAssociationId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocumentId]                    BIGINT           NOT NULL,
    [PanelistId]                    UNIQUEIDENTIFIER NULL,
    [Country_Id] UNIQUEIDENTIFIER NOT NULL, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DocumentPanelistAssociation] PRIMARY KEY CLUSTERED ([DocumentPanelistAssociationId] ASC),
    CONSTRAINT [FK_dbo.DocumentPanelistAssociation_dbo.Document_DocumentId] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[Document] ([DocumentId]) 
);






GO
CREATE NONCLUSTERED INDEX [IX_DocumentId]
    ON [dbo].[DocumentPanelistAssociation]([DocumentId] ASC);


GO
CREATE TRIGGER dbo.trgDocumentPanelistAssociation_U 
ON dbo.[DocumentPanelistAssociation] FOR update 
AS 
insert into audit.[DocumentPanelistAssociation](
insert into audit.[DocumentPanelistAssociation](
GO
CREATE TRIGGER dbo.trgDocumentPanelistAssociation_I
ON dbo.[DocumentPanelistAssociation] FOR insert 
AS 
insert into audit.[DocumentPanelistAssociation](
GO
CREATE TRIGGER dbo.trgDocumentPanelistAssociation_D
ON dbo.[DocumentPanelistAssociation] FOR delete 
AS 
insert into audit.[DocumentPanelistAssociation](