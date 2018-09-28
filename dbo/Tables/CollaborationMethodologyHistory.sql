CREATE TABLE [dbo].[CollaborationMethodologyHistory] (
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
insert into audit.[CollaborationMethodologyHistory](	 [GUIDReference]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Date]	 ,[GPSUser]	 ,[Comments]	 ,[Panelist_Id]	 ,[OldCollaborationMethodology_Id]	 ,[NewCollaborationMethodology_Id]	 ,[CollaborationMethodologyChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Date]	 ,d.[GPSUser]	 ,d.[Comments]	 ,d.[Panelist_Id]	 ,d.[OldCollaborationMethodology_Id]	 ,d.[NewCollaborationMethodology_Id]	 ,d.[CollaborationMethodologyChangeReason_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[CollaborationMethodologyHistory](	 [GUIDReference]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Date]	 ,[GPSUser]	 ,[Comments]	 ,[Panelist_Id]	 ,[OldCollaborationMethodology_Id]	 ,[NewCollaborationMethodology_Id]	 ,[CollaborationMethodologyChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Date]	 ,i.[GPSUser]	 ,i.[Comments]	 ,i.[Panelist_Id]	 ,i.[OldCollaborationMethodology_Id]	 ,i.[NewCollaborationMethodology_Id]	 ,i.[CollaborationMethodologyChangeReason_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgCollaborationMethodologyHistory_I
ON dbo.[CollaborationMethodologyHistory] FOR insert 
AS 
insert into audit.[CollaborationMethodologyHistory](	 [GUIDReference]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Date]	 ,[GPSUser]	 ,[Comments]	 ,[Panelist_Id]	 ,[OldCollaborationMethodology_Id]	 ,[NewCollaborationMethodology_Id]	 ,[CollaborationMethodologyChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Date]	 ,i.[GPSUser]	 ,i.[Comments]	 ,i.[Panelist_Id]	 ,i.[OldCollaborationMethodology_Id]	 ,i.[NewCollaborationMethodology_Id]	 ,i.[CollaborationMethodologyChangeReason_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCollaborationMethodologyHistory_D
ON dbo.[CollaborationMethodologyHistory] FOR delete 
AS 
insert into audit.[CollaborationMethodologyHistory](	 [GUIDReference]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Date]	 ,[GPSUser]	 ,[Comments]	 ,[Panelist_Id]	 ,[OldCollaborationMethodology_Id]	 ,[NewCollaborationMethodology_Id]	 ,[CollaborationMethodologyChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Date]	 ,d.[GPSUser]	 ,d.[Comments]	 ,d.[Panelist_Id]	 ,d.[OldCollaborationMethodology_Id]	 ,d.[NewCollaborationMethodology_Id]	 ,d.[CollaborationMethodologyChangeReason_Id]	 ,d.[Country_Id],'D' from deleted d