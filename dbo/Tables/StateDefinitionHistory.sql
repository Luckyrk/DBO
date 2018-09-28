CREATE TABLE [dbo].[StateDefinitionHistory] (
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
insert into audit.[StateDefinitionHistory](	 [GUIDReference]	 ,[GPSUser]	 ,[CreationDate]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Comments]	 ,[CollaborateInFuture]	 ,[From_Id]	 ,[To_Id]	 ,[ReasonForchangeState_Id]	 ,[Country_Id]	 ,[Candidate_Id]	 ,[GroupMembership_Id]	 ,[Belonging_Id]	 ,[Panelist_Id]	 ,[Order_Id]	 ,[Order_Country_Id]	 ,[Package_Id]	 ,[ImportFile_Id]	 ,[ImportFilePendingRecord_Id]	 ,[Action_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[CreationDate]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Comments]	 ,d.[CollaborateInFuture]	 ,d.[From_Id]	 ,d.[To_Id]	 ,d.[ReasonForchangeState_Id]	 ,d.[Country_Id]	 ,d.[Candidate_Id]	 ,d.[GroupMembership_Id]	 ,d.[Belonging_Id]	 ,d.[Panelist_Id]	 ,d.[Order_Id]	 ,d.[Order_Country_Id]	 ,d.[Package_Id]	 ,d.[ImportFile_Id]	 ,d.[ImportFilePendingRecord_Id]	 ,d.[Action_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StateDefinitionHistory](	 [GUIDReference]	 ,[GPSUser]	 ,[CreationDate]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Comments]	 ,[CollaborateInFuture]	 ,[From_Id]	 ,[To_Id]	 ,[ReasonForchangeState_Id]	 ,[Country_Id]	 ,[Candidate_Id]	 ,[GroupMembership_Id]	 ,[Belonging_Id]	 ,[Panelist_Id]	 ,[Order_Id]	 ,[Order_Country_Id]	 ,[Package_Id]	 ,[ImportFile_Id]	 ,[ImportFilePendingRecord_Id]	 ,[Action_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[CreationDate]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Comments]	 ,i.[CollaborateInFuture]	 ,i.[From_Id]	 ,i.[To_Id]	 ,i.[ReasonForchangeState_Id]	 ,i.[Country_Id]	 ,i.[Candidate_Id]	 ,i.[GroupMembership_Id]	 ,i.[Belonging_Id]	 ,i.[Panelist_Id]	 ,i.[Order_Id]	 ,i.[Order_Country_Id]	 ,i.[Package_Id]	 ,i.[ImportFile_Id]	 ,i.[ImportFilePendingRecord_Id]	 ,i.[Action_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgStateDefinitionHistory_I
ON dbo.[StateDefinitionHistory] FOR insert 
AS 
insert into audit.[StateDefinitionHistory](	 [GUIDReference]	 ,[GPSUser]	 ,[CreationDate]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Comments]	 ,[CollaborateInFuture]	 ,[From_Id]	 ,[To_Id]	 ,[ReasonForchangeState_Id]	 ,[Country_Id]	 ,[Candidate_Id]	 ,[GroupMembership_Id]	 ,[Belonging_Id]	 ,[Panelist_Id]	 ,[Order_Id]	 ,[Order_Country_Id]	 ,[Package_Id]	 ,[ImportFile_Id]	 ,[ImportFilePendingRecord_Id]	 ,[Action_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[CreationDate]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Comments]	 ,i.[CollaborateInFuture]	 ,i.[From_Id]	 ,i.[To_Id]	 ,i.[ReasonForchangeState_Id]	 ,i.[Country_Id]	 ,i.[Candidate_Id]	 ,i.[GroupMembership_Id]	 ,i.[Belonging_Id]	 ,i.[Panelist_Id]	 ,i.[Order_Id]	 ,i.[Order_Country_Id]	 ,i.[Package_Id]	 ,i.[ImportFile_Id]	 ,i.[ImportFilePendingRecord_Id]	 ,i.[Action_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStateDefinitionHistory_D
ON dbo.[StateDefinitionHistory] FOR delete 
AS 
insert into audit.[StateDefinitionHistory](	 [GUIDReference]	 ,[GPSUser]	 ,[CreationDate]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Comments]	 ,[CollaborateInFuture]	 ,[From_Id]	 ,[To_Id]	 ,[ReasonForchangeState_Id]	 ,[Country_Id]	 ,[Candidate_Id]	 ,[GroupMembership_Id]	 ,[Belonging_Id]	 ,[Panelist_Id]	 ,[Order_Id]	 ,[Order_Country_Id]	 ,[Package_Id]	 ,[ImportFile_Id]	 ,[ImportFilePendingRecord_Id]	 ,[Action_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[CreationDate]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Comments]	 ,d.[CollaborateInFuture]	 ,d.[From_Id]	 ,d.[To_Id]	 ,d.[ReasonForchangeState_Id]	 ,d.[Country_Id]	 ,d.[Candidate_Id]	 ,d.[GroupMembership_Id]	 ,d.[Belonging_Id]	 ,d.[Panelist_Id]	 ,d.[Order_Id]	 ,d.[Order_Country_Id]	 ,d.[Package_Id]	 ,d.[ImportFile_Id]	 ,d.[ImportFilePendingRecord_Id]	 ,d.[Action_Id],'D' from deleted d