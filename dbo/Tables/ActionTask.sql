CREATE TABLE [dbo].[ActionTask] (
    [GUIDReference]              UNIQUEIDENTIFIER NOT NULL,
    [StartDate]                  DATETIME         NOT NULL,
    [EndDate]                    DATETIME         NULL,
    [CompletionDate]             DATETIME         NULL,
    [ActionComment]              NVARCHAR (500)   NULL,
    [InternalOrExternal]         INT              NOT NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    [State]                      INT              NOT NULL,
    [CommunicationCompletion_Id] UNIQUEIDENTIFIER NULL,
    [ActionTaskType_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]               UNIQUEIDENTIFIER NULL,
    [Country_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [FormId]                     UNIQUEIDENTIFIER NULL,
    [Assignee_Id]                UNIQUEIDENTIFIER NULL,
    [Panel_Id]                   UNIQUEIDENTIFIER NULL,
	[ActionTaskPriority]		 INT DEFAULT 0 NOT NULL,
	[CallBackDateTime]		     DATETIME         NULL,
    CONSTRAINT [PK_dbo.ActionTask] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_ActionTask_dbo_Form_Id] FOREIGN KEY ([FormId]) REFERENCES [dbo].[Form] ([GUIDReference]),
    CONSTRAINT [FK_ActionTask_IdentityUser_Id] FOREIGN KEY ([Assignee_Id]) REFERENCES [dbo].[IdentityUser] ([Id]),
    CONSTRAINT [FK_ActionTask_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionTask_dbo.ActionTaskType_ActionTaskType_Id] FOREIGN KEY ([ActionTaskType_Id]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionTask_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionTask_dbo.CommunicationEvent_CommunicationCompletion_Id] FOREIGN KEY ([CommunicationCompletion_Id]) REFERENCES [dbo].[CommunicationEvent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionTask_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);








GO
CREATE NONCLUSTERED INDEX [IX_CommunicationCompletion_Id]
    ON [dbo].[ActionTask]([CommunicationCompletion_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTaskType_Id]
    ON [dbo].[ActionTask]([ActionTaskType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[ActionTask]([Candidate_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ActionTask]([Country_Id] ASC);

	GO
CREATE NONCLUSTERED INDEX [IX_Form_Id]
    ON [dbo].[ActionTask]([FormId] ASC);

GO
CREATE TRIGGER dbo.trgActionTask_U 
ON dbo.[ActionTask] FOR update 
AS 
insert into audit.[ActionTask](	 [GUIDReference]	 ,[StartDate]	 ,[EndDate]	 ,[CompletionDate]	 ,[ActionComment]	 ,[InternalOrExternal]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State]	 ,[CommunicationCompletion_Id]	 ,[ActionTaskType_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,[FormId]	 ,[Assignee_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[StartDate]	 ,d.[EndDate]	 ,d.[CompletionDate]	 ,d.[ActionComment]	 ,d.[InternalOrExternal]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[State]	 ,d.[CommunicationCompletion_Id]	 ,d.[ActionTaskType_Id]	 ,d.[Candidate_Id]	 ,d.[Country_Id]	 ,d.[FormId]	 ,d.[Assignee_Id]	 ,d.[Panel_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ActionTask](	 [GUIDReference]	 ,[StartDate]	 ,[EndDate]	 ,[CompletionDate]	 ,[ActionComment]	 ,[InternalOrExternal]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State]	 ,[CommunicationCompletion_Id]	 ,[ActionTaskType_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,[FormId]	 ,[Assignee_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[StartDate]	 ,i.[EndDate]	 ,i.[CompletionDate]	 ,i.[ActionComment]	 ,i.[InternalOrExternal]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[State]	 ,i.[CommunicationCompletion_Id]	 ,i.[ActionTaskType_Id]	 ,i.[Candidate_Id]	 ,i.[Country_Id]	 ,i.[FormId]	 ,i.[Assignee_Id]	 ,i.[Panel_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgActionTask_I
ON dbo.[ActionTask] FOR insert 
AS 
insert into audit.[ActionTask](	 [GUIDReference]	 ,[StartDate]	 ,[EndDate]	 ,[CompletionDate]	 ,[ActionComment]	 ,[InternalOrExternal]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State]	 ,[CommunicationCompletion_Id]	 ,[ActionTaskType_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,[FormId]	 ,[Assignee_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[StartDate]	 ,i.[EndDate]	 ,i.[CompletionDate]	 ,i.[ActionComment]	 ,i.[InternalOrExternal]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[State]	 ,i.[CommunicationCompletion_Id]	 ,i.[ActionTaskType_Id]	 ,i.[Candidate_Id]	 ,i.[Country_Id]	 ,i.[FormId]	 ,i.[Assignee_Id]	 ,i.[Panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgActionTask_D
ON dbo.[ActionTask] FOR delete 
AS 
insert into audit.[ActionTask](	 [GUIDReference]	 ,[StartDate]	 ,[EndDate]	 ,[CompletionDate]	 ,[ActionComment]	 ,[InternalOrExternal]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State]	 ,[CommunicationCompletion_Id]	 ,[ActionTaskType_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,[FormId]	 ,[Assignee_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[StartDate]	 ,d.[EndDate]	 ,d.[CompletionDate]	 ,d.[ActionComment]	 ,d.[InternalOrExternal]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[State]	 ,d.[CommunicationCompletion_Id]	 ,d.[ActionTaskType_Id]	 ,d.[Candidate_Id]	 ,d.[Country_Id]	 ,d.[FormId]	 ,d.[Assignee_Id]	 ,d.[Panel_Id],'D' from deleted d