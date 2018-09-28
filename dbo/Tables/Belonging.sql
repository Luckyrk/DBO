CREATE TABLE [dbo].[Belonging] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [CandidateId]        UNIQUEIDENTIFIER NOT NULL,
    [TypeId]             UNIQUEIDENTIFIER NOT NULL,
    [BelongingCode]      INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [State_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.Belonging] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Belonging_dbo.BelongingType_TypeId] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[BelongingType] ([Id]),
    CONSTRAINT [FK_dbo.Belonging_dbo.Candidate_CandidateId] FOREIGN KEY ([CandidateId]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Belonging_dbo.Respondent_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Respondent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Belonging_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[Belonging]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CandidateId]
    ON [dbo].[Belonging]([CandidateId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TypeId]
    ON [dbo].[Belonging]([TypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[Belonging]([State_Id] ASC);


GO
CREATE TRIGGER dbo.trgBelonging_U 
ON dbo.[Belonging] FOR update 
AS 
insert into audit.[Belonging](	 [GUIDReference]	 ,[CandidateId]	 ,[TypeId]	 ,[BelongingCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CandidateId]	 ,d.[TypeId]	 ,d.[BelongingCode]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[State_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Belonging](	 [GUIDReference]	 ,[CandidateId]	 ,[TypeId]	 ,[BelongingCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CandidateId]	 ,i.[TypeId]	 ,i.[BelongingCode]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[State_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgBelonging_I
ON dbo.[Belonging] FOR insert 
AS 
insert into audit.[Belonging](	 [GUIDReference]	 ,[CandidateId]	 ,[TypeId]	 ,[BelongingCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CandidateId]	 ,i.[TypeId]	 ,i.[BelongingCode]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[State_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgBelonging_D
ON dbo.[Belonging] FOR delete 
AS 
insert into audit.[Belonging](	 [GUIDReference]	 ,[CandidateId]	 ,[TypeId]	 ,[BelongingCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CandidateId]	 ,d.[TypeId]	 ,d.[BelongingCode]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[State_Id]	 ,d.[Type],'D' from deleted d