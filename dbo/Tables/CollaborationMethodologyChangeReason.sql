﻿CREATE TABLE [dbo].[CollaborationMethodologyChangeReason] (
    [ChangeReasonId]     UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Code]               INT              NOT NULL,
    [Description_Id]     UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CollaborationMethodologyChangeReason] PRIMARY KEY CLUSTERED ([ChangeReasonId] ASC),
    CONSTRAINT [FK_dbo.CollaborationMethodologyChangeReason_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CollaborationMethodologyChangeReason_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[CollaborationMethodologyChangeReason]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CollaborationMethodologyChangeReason]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgCollaborationMethodologyChangeReason_U 
ON dbo.[CollaborationMethodologyChangeReason] FOR update 
AS 
insert into audit.[CollaborationMethodologyChangeReason](
insert into audit.[CollaborationMethodologyChangeReason](
GO
CREATE TRIGGER dbo.trgCollaborationMethodologyChangeReason_I
ON dbo.[CollaborationMethodologyChangeReason] FOR insert 
AS 
insert into audit.[CollaborationMethodologyChangeReason](
GO
CREATE TRIGGER dbo.trgCollaborationMethodologyChangeReason_D
ON dbo.[CollaborationMethodologyChangeReason] FOR delete 
AS 
insert into audit.[CollaborationMethodologyChangeReason](