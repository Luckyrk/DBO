﻿CREATE TABLE [dbo].[CollaborationMethodologyHistory] (
    [GUIDReference]                           UNIQUEIDENTIFIER NOT NULL,
    [GPSUpdateTimestamp]                      DATETIME         NULL,
    [CreationTimeStamp]                       DATETIME         NULL,
    [Date]                                    DATETIME         NOT NULL,
    [GPSUser]                                 NVARCHAR (50)    NULL,
    [Comments]                                NVARCHAR (500)   NULL,
    [Panelist_Id]                             UNIQUEIDENTIFIER NULL,
    [OldCollaborationMethodology_Id]          UNIQUEIDENTIFIER NULL,
    [NewCollaborationMethodology_Id]          UNIQUEIDENTIFIER NULL,
    [CollaborationMethodologyChangeReason_Id] UNIQUEIDENTIFIER NULL,
    [Country_Id]                              UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CollaborationMethodologyHistory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CollaborationMethodologyHistory_dbo.CollaborationMethodology_NewCollaborationMethodology_Id] FOREIGN KEY ([NewCollaborationMethodology_Id]) REFERENCES [dbo].[CollaborationMethodology] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CollaborationMethodologyHistory_dbo.CollaborationMethodology_OldCollaborationMethodology_Id] FOREIGN KEY ([OldCollaborationMethodology_Id]) REFERENCES [dbo].[CollaborationMethodology] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CollaborationMethodologyHistory_dbo.CollaborationMethodologyChangeReason_CollaborationMethodologyChangeReason_Id] FOREIGN KEY ([CollaborationMethodologyChangeReason_Id]) REFERENCES [dbo].[CollaborationMethodologyChangeReason] ([ChangeReasonId]),
    CONSTRAINT [FK_dbo.CollaborationMethodologyHistory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CollaborationMethodologyHistory_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[CollaborationMethodologyHistory]([Panelist_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OldCollaborationMethodology_Id]
    ON [dbo].[CollaborationMethodologyHistory]([OldCollaborationMethodology_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NewCollaborationMethodology_Id]
    ON [dbo].[CollaborationMethodologyHistory]([NewCollaborationMethodology_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CollaborationMethodologyChangeReason_Id]
    ON [dbo].[CollaborationMethodologyHistory]([CollaborationMethodologyChangeReason_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CollaborationMethodologyHistory]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgCollaborationMethodologyHistory_U 
ON dbo.[CollaborationMethodologyHistory] FOR update 
AS 
insert into audit.[CollaborationMethodologyHistory](
insert into audit.[CollaborationMethodologyHistory](
GO
CREATE TRIGGER dbo.trgCollaborationMethodologyHistory_I
ON dbo.[CollaborationMethodologyHistory] FOR insert 
AS 
insert into audit.[CollaborationMethodologyHistory](
GO
CREATE TRIGGER dbo.trgCollaborationMethodologyHistory_D
ON dbo.[CollaborationMethodologyHistory] FOR delete 
AS 
insert into audit.[CollaborationMethodologyHistory](