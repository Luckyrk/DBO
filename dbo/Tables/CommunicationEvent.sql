﻿CREATE TABLE [dbo].[CommunicationEvent] (
    [GUIDReference]       UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]        DATETIME         NOT NULL,
    [Incoming]            BIT              NOT NULL,
    [State]               INT              NOT NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [CallLength]          TIME (7)         NOT NULL,
    [ContactMechanism_Id] UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]        UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CommunicationEvent] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CommunicationEvent_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CommunicationEvent_dbo.ContactMechanismType_ContactMechanism_Id] FOREIGN KEY ([ContactMechanism_Id]) REFERENCES [dbo].[ContactMechanismType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CommunicationEvent_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);








GO
CREATE NONCLUSTERED INDEX [IX_ContactMechanism_Id]
    ON [dbo].[CommunicationEvent]([ContactMechanism_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CommunicationEvent]([Country_Id] ASC)
    INCLUDE([CreationDate], [GPSUser]);




GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[CommunicationEvent]([Candidate_Id] ASC)
    INCLUDE([CreationDate], [State]);


GO
CREATE TRIGGER dbo.trgCommunicationEvent_U 
ON dbo.[CommunicationEvent] FOR update 
AS 
insert into audit.[CommunicationEvent](
insert into audit.[CommunicationEvent](
GO
CREATE TRIGGER dbo.trgCommunicationEvent_I
ON dbo.[CommunicationEvent] FOR insert 
AS 
insert into audit.[CommunicationEvent](
GO
CREATE TRIGGER dbo.trgCommunicationEvent_D
ON dbo.[CommunicationEvent] FOR delete 
AS 
insert into audit.[CommunicationEvent](