CREATE TABLE [dbo].[Candidate] (
    [GUIDReference]         UNIQUEIDENTIFIER NOT NULL,
    [ValidFromDate]         DATETIME         NOT NULL,
    [EnrollmentDate]        DATETIME         NULL,
    [Comments]              NVARCHAR (200)   NULL,
    [CandidateStatus]       UNIQUEIDENTIFIER NOT NULL,
    [GeographicArea_Id]     UNIQUEIDENTIFIER NULL,
    [RewardsAccountGUID_Id] UNIQUEIDENTIFIER NULL,
    [PreallocatedBatch_Id]  UNIQUEIDENTIFIER NULL,
    [GPSUser]               NVARCHAR (50)    NOT NULL,
    [CreationTimeStamp]     DATETIME         NULL,
    [GPSUpdateTimestamp]    DATETIME         NOT NULL,
    [Country_Id]            UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    CONSTRAINT [PK_dbo.Candidate] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Candidate_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Candidate_dbo.GeographicArea_GeographicArea_Id] FOREIGN KEY ([GeographicArea_Id]) REFERENCES [dbo].[GeographicArea] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Candidate_dbo.PreallocatedBatch_PreallocatedBatch_Id] FOREIGN KEY ([PreallocatedBatch_Id]) REFERENCES [dbo].[PreallocatedBatch] ([Id]),
    CONSTRAINT [FK_dbo.Candidate_dbo.RewardsAccount_RewardsAccountGUID_Id] FOREIGN KEY ([RewardsAccountGUID_Id]) REFERENCES [dbo].[RewardsAccount] ([RewardsAccountGUID]),
    CONSTRAINT [FK_dbo.Candidate_dbo.StateDefinition_CandidateStatus] FOREIGN KEY ([CandidateStatus]) REFERENCES [dbo].[StateDefinition] ([Id])
);



GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[Candidate]([GUIDReference] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Candidate]([Country_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_CandidateStatus]
    ON [dbo].[Candidate]([CandidateStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_GeographicArea_Id]
    ON [dbo].[Candidate]([GeographicArea_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RewardsAccountGUID_Id]
    ON [dbo].[Candidate]([RewardsAccountGUID_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PreallocatedBatch_Id]
    ON [dbo].[Candidate]([PreallocatedBatch_Id] ASC);


GO
CREATE TRIGGER dbo.trgCandidate_U 
ON dbo.[Candidate] FOR update 
AS 
insert into audit.[Candidate](	 [GUIDReference]	 ,[ValidFromDate]	 ,[EnrollmentDate]	 ,[Comments]	 ,[CandidateStatus]	 ,[GeographicArea_Id]	 ,[RewardsAccountGUID_Id]	 ,[PreallocatedBatch_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[ValidFromDate]	 ,d.[EnrollmentDate]	 ,d.[Comments]	 ,d.[CandidateStatus]	 ,d.[GeographicArea_Id]	 ,d.[RewardsAccountGUID_Id]	 ,d.[PreallocatedBatch_Id]	 ,d.[GPSUser]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Candidate](	 [GUIDReference]	 ,[ValidFromDate]	 ,[EnrollmentDate]	 ,[Comments]	 ,[CandidateStatus]	 ,[GeographicArea_Id]	 ,[RewardsAccountGUID_Id]	 ,[PreallocatedBatch_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[ValidFromDate]	 ,i.[EnrollmentDate]	 ,i.[Comments]	 ,i.[CandidateStatus]	 ,i.[GeographicArea_Id]	 ,i.[RewardsAccountGUID_Id]	 ,i.[PreallocatedBatch_Id]	 ,i.[GPSUser]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgCandidate_I
ON dbo.[Candidate] FOR insert 
AS 
insert into audit.[Candidate](	 [GUIDReference]	 ,[ValidFromDate]	 ,[EnrollmentDate]	 ,[Comments]	 ,[CandidateStatus]	 ,[GeographicArea_Id]	 ,[RewardsAccountGUID_Id]	 ,[PreallocatedBatch_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[ValidFromDate]	 ,i.[EnrollmentDate]	 ,i.[Comments]	 ,i.[CandidateStatus]	 ,i.[GeographicArea_Id]	 ,i.[RewardsAccountGUID_Id]	 ,i.[PreallocatedBatch_Id]	 ,i.[GPSUser]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp]
	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCandidate_D
ON dbo.[Candidate] FOR delete 
AS 
insert into audit.[Candidate](	 [GUIDReference]	 ,[ValidFromDate]	 ,[EnrollmentDate]	 ,[Comments]	 ,[CandidateStatus]	 ,[GeographicArea_Id]	 ,[RewardsAccountGUID_Id]	 ,[PreallocatedBatch_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[ValidFromDate]	 ,d.[EnrollmentDate]	 ,d.[Comments]	 ,d.[CandidateStatus]	 ,d.[GeographicArea_Id]	 ,d.[RewardsAccountGUID_Id]	 ,d.[PreallocatedBatch_Id]	 ,d.[GPSUser]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp]	 ,d.[Country_Id],'D' from deleted d
GO