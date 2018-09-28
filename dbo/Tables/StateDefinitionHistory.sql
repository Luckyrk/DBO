﻿CREATE TABLE [dbo].[StateDefinitionHistory] (
    [GUIDReference]              UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                    NVARCHAR (50)    NOT NULL,
    [CreationDate]               DATETIME         NOT NULL,
    [GPSUpdateTimestamp]         DATETIME         NOT NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    [Comments]                   NVARCHAR (500)   NULL,
    [CollaborateInFuture]        BIT              NOT NULL,
    [From_Id]                    UNIQUEIDENTIFIER NOT NULL,
    [To_Id]                      UNIQUEIDENTIFIER NOT NULL,
    [ReasonForchangeState_Id]    UNIQUEIDENTIFIER NULL,
    [Country_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]               UNIQUEIDENTIFIER NULL,
    [GroupMembership_Id]         UNIQUEIDENTIFIER NULL,
    [Belonging_Id]               UNIQUEIDENTIFIER NULL,
    [Panelist_Id]                UNIQUEIDENTIFIER NULL,
    [Order_Id]                   BIGINT           NULL,
    [Order_Country_Id]           UNIQUEIDENTIFIER NULL,
    [Package_Id]                 UNIQUEIDENTIFIER NULL,
    [ImportFile_Id]              UNIQUEIDENTIFIER NULL,
    [ImportFilePendingRecord_Id] UNIQUEIDENTIFIER NULL,
    [Action_Id]                  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.StateDefinitionHistory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Action_Action_Id] FOREIGN KEY ([Action_Id]) REFERENCES [dbo].[Action] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Belonging_Belonging_Id] FOREIGN KEY ([Belonging_Id]) REFERENCES [dbo].[Belonging] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.CollectiveMembership_GroupMembership_Id] FOREIGN KEY ([GroupMembership_Id]) REFERENCES [dbo].[CollectiveMembership] ([CollectiveMembershipId]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.ImportFile_ImportFile_Id] FOREIGN KEY ([ImportFile_Id]) REFERENCES [dbo].[ImportFile] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.ImportFilePendingRecord_ImportFilePendingRecord_Id] FOREIGN KEY ([ImportFilePendingRecord_Id]) REFERENCES [dbo].[ImportFilePendingRecord] ([Id]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Order_Order_Id_Order_Country_Id] FOREIGN KEY ([Order_Id], [Order_Country_Id]) REFERENCES [dbo].[Order] ([OrderId], [Country_Id]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Package_Package_Id] FOREIGN KEY ([Package_Id]) REFERENCES [dbo].[Package] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.ReasonForChangeState_ReasonForchangeState_Id] FOREIGN KEY ([ReasonForchangeState_Id]) REFERENCES [dbo].[ReasonForChangeState] ([Id]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.StateDefinition_From_Id] FOREIGN KEY ([From_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.StateDefinitionHistory_dbo.StateDefinition_To_Id] FOREIGN KEY ([To_Id]) REFERENCES [dbo].[StateDefinition] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_From_Id]
    ON [dbo].[StateDefinitionHistory]([From_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_To_Id]
    ON [dbo].[StateDefinitionHistory]([To_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ReasonForchangeState_Id]
    ON [dbo].[StateDefinitionHistory]([ReasonForchangeState_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StateDefinitionHistory]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[StateDefinitionHistory]([Candidate_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_GroupMembership_Id]
    ON [dbo].[StateDefinitionHistory]([GroupMembership_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Belonging_Id]
    ON [dbo].[StateDefinitionHistory]([Belonging_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[StateDefinitionHistory]([Panelist_Id] ASC);


GO



GO
CREATE NONCLUSTERED INDEX [IX_Package_Id]
    ON [dbo].[StateDefinitionHistory]([Package_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ImportFile_Id]
    ON [dbo].[StateDefinitionHistory]([ImportFile_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ImportFilePendingRecord_Id]
    ON [dbo].[StateDefinitionHistory]([ImportFilePendingRecord_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Action_Id]
    ON [dbo].[StateDefinitionHistory]([Action_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Order_Id_Order_Country_Id]
    ON [dbo].[StateDefinitionHistory]([Order_Id] ASC, [Order_Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateDefinitionHistory_U 
ON dbo.[StateDefinitionHistory] FOR update 
AS 
insert into audit.[StateDefinitionHistory](
insert into audit.[StateDefinitionHistory](
GO
CREATE TRIGGER dbo.trgStateDefinitionHistory_I
ON dbo.[StateDefinitionHistory] FOR insert 
AS 
insert into audit.[StateDefinitionHistory](
GO
CREATE TRIGGER dbo.trgStateDefinitionHistory_D
ON dbo.[StateDefinitionHistory] FOR delete 
AS 
insert into audit.[StateDefinitionHistory](