CREATE TABLE [dbo].[PartyPanelSurveyParticipationTask](
       [Panelist_Id] [uniqueidentifier] NOT NULL,
       [PanelTaskAssociation_Id] [uniqueidentifier] NOT NULL,
       [FromDate] [datetime] NOT NULL,
       [ToDate] [datetime] NULL,
       [Active] [bit] NOT NULL DEFAULT ((0)),
       [GPSUser] [nvarchar](50) NOT NULL DEFAULT ('DefaultGPSUser'),
       [GPSUpdateTimestamp] [datetime] NOT NULL DEFAULT ('01/01/2012'),
       [CreationTimeStamp] [datetime] NOT NULL DEFAULT ('01/01/2012'),
CONSTRAINT [PK_dbo.PartyPanelSurveyParticipationTask] PRIMARY KEY CLUSTERED 
(
       [Panelist_Id] ASC,
       [PanelTaskAssociation_Id] ASC,
       [FromDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PartyPanelSurveyParticipationTask]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PartyPanelSurveyParticipationTask_dbo.Panelist_Panelist_Id] FOREIGN KEY([Panelist_Id])
REFERENCES [dbo].[Panelist] ([GUIDReference])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[PartyPanelSurveyParticipationTask] CHECK CONSTRAINT [FK_dbo.PartyPanelSurveyParticipationTask_dbo.Panelist_Panelist_Id]
GO

ALTER TABLE [dbo].[PartyPanelSurveyParticipationTask]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PartyPanelSurveyParticipationTask_dbo.PanelSurveyParticipationTask_PanelTaskAssociation_Id] FOREIGN KEY([PanelTaskAssociation_Id])
REFERENCES [dbo].[PanelSurveyParticipationTask] ([PanelSurveyParticipationTaskId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[PartyPanelSurveyParticipationTask] CHECK CONSTRAINT [FK_dbo.PartyPanelSurveyParticipationTask_dbo.PanelSurveyParticipationTask_PanelTaskAssociation_Id]




GO
CREATE NONCLUSTERED INDEX [IX_PanelTaskAssociation_Id]
    ON [dbo].[PartyPanelSurveyParticipationTask]([PanelTaskAssociation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[PartyPanelSurveyParticipationTask]([Panelist_Id] ASC);


GO
CREATE TRIGGER dbo.trgPartyPanelSurveyParticipationTask_U 
ON dbo.[PartyPanelSurveyParticipationTask] FOR update 
AS 
insert into audit.[PartyPanelSurveyParticipationTask](
	 [Panelist_Id]
	 ,[PanelTaskAssociation_Id]
	 ,[FromDate]
	 ,[ToDate]
	 ,[Active]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 d.[Panelist_Id]
	 ,d.[PanelTaskAssociation_Id]
	 ,d.[FromDate]
	 ,d.[ToDate]
	 ,d.[Active]
	 ,d.[GPSUser]
	 ,d.[GPSUpdateTimestamp]
	 ,d.[CreationTimeStamp],'O'  from 
	 deleted d join inserted i on d.Panelist_Id = i.Panelist_Id
	 and d.PanelTaskAssociation_Id = i.PanelTaskAssociation_Id 
insert into audit.[PartyPanelSurveyParticipationTask](
	 [Panelist_Id]
	 ,[PanelTaskAssociation_Id]
	 ,[FromDate]
	 ,[ToDate]
	 ,[Active]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 i.[Panelist_Id]
	 ,i.[PanelTaskAssociation_Id]
	 ,i.[FromDate]
	 ,i.[ToDate]
	 ,i.[Active]
	 ,i.[GPSUser]
	 ,i.[GPSUpdateTimestamp]
	 ,i.[CreationTimeStamp], 'N'  from 
	 deleted d join inserted i on d.Panelist_Id = i.Panelist_Id
	 and d.PanelTaskAssociation_Id = i.PanelTaskAssociation_Id
GO
CREATE TRIGGER dbo.trgPartyPanelSurveyParticipationTask_I
ON dbo.[PartyPanelSurveyParticipationTask] FOR insert 
AS 
insert into audit.[PartyPanelSurveyParticipationTask](
	 [Panelist_Id]
	 ,[PanelTaskAssociation_Id]
	 ,[FromDate]
	 ,[ToDate]
	 ,[Active]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 i.[Panelist_Id]
	 ,i.[PanelTaskAssociation_Id]
	 ,i.[FromDate]
	 ,i.[ToDate]
	 ,i.[Active]
	 ,i.[GPSUser]
	 ,i.[GPSUpdateTimestamp]
	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPartyPanelSurveyParticipationTask_D
ON dbo.[PartyPanelSurveyParticipationTask] FOR delete 
AS 
insert into audit.[PartyPanelSurveyParticipationTask](
	 [Panelist_Id]
	 ,[PanelTaskAssociation_Id]
	 ,[FromDate]
	 ,[ToDate]
	 ,[Active]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 d.[Panelist_Id]
	 ,d.[PanelTaskAssociation_Id]
	 ,d.[FromDate]
	 ,d.[ToDate]
	 ,d.[Active]
	 ,d.[GPSUser]
	 ,d.[GPSUpdateTimestamp]
	 ,d.[CreationTimeStamp],'D' from deleted d