﻿CREATE TABLE [dbo].[CollaborationMethodology] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Code]               NVARCHAR (10)    NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [TranslationId]      UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CollaborationMethodology] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CollaborationMethodology_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CollaborationMethodology_dbo.Translation_TranslationId] FOREIGN KEY ([TranslationId]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CollaborationMethodology]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TranslationId]
    ON [dbo].[CollaborationMethodology]([TranslationId] ASC);


GO
CREATE TRIGGER dbo.trgCollaborationMethodology_U 
ON dbo.[CollaborationMethodology] FOR update 
AS 
insert into audit.[CollaborationMethodology](
insert into audit.[CollaborationMethodology](
GO
CREATE TRIGGER dbo.trgCollaborationMethodology_I
ON dbo.[CollaborationMethodology] FOR insert 
AS 
insert into audit.[CollaborationMethodology](
GO
CREATE TRIGGER dbo.trgCollaborationMethodology_D
ON dbo.[CollaborationMethodology] FOR delete 
AS 
insert into audit.[CollaborationMethodology](