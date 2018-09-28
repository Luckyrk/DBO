CREATE TABLE [dbo].[Panelist] (
    [GUIDReference]               UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]                DATETIME         NOT NULL,
    [GPSUser]                     NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp]          DATETIME         NOT NULL,
    [CreationTimeStamp]           DATETIME         NULL,
    [Panel_Id]                    UNIQUEIDENTIFIER NOT NULL,
    [RewardsAccount_Id]           UNIQUEIDENTIFIER NULL,
    [PanelMember_Id]              UNIQUEIDENTIFIER NOT NULL,
    [CollaborationMethodology_Id] UNIQUEIDENTIFIER NULL,
    [State_Id]                    UNIQUEIDENTIFIER NOT NULL,
    [IncentiveLevel_Id]           UNIQUEIDENTIFIER NULL,
    [ExpectedKit_Id]              UNIQUEIDENTIFIER NULL,
    [ChangeReason_Id]             UNIQUEIDENTIFIER NULL,
    [Country_Id]                  UNIQUEIDENTIFIER NOT NULL,
	[ETLTimestamp]				  DATETIME NULL,
    CONSTRAINT [PK_dbo.Panelist] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Panelist_dbo.Candidate_PanelMember_Id] FOREIGN KEY ([PanelMember_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Panelist_dbo.CollaborationMethodology_CollaborationMethodology_Id] FOREIGN KEY ([CollaborationMethodology_Id]) REFERENCES [dbo].[CollaborationMethodology] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Panelist_dbo.CollaborationMethodologyChangeReason_ChangeReason_Id] FOREIGN KEY ([ChangeReason_Id]) REFERENCES [dbo].[CollaborationMethodologyChangeReason] ([ChangeReasonId]),
    CONSTRAINT [FK_dbo.Panelist_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Panelist_dbo.IncentiveLevel_IncentiveLevel_Id] FOREIGN KEY ([IncentiveLevel_Id]) REFERENCES [dbo].[IncentiveLevel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Panelist_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Panelist_dbo.RewardsAccount_RewardsAccount_Id] FOREIGN KEY ([RewardsAccount_Id]) REFERENCES [dbo].[RewardsAccount] ([RewardsAccountGUID]),
    CONSTRAINT [FK_dbo.Panelist_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.Panelist_dbo.StockKit_ExpectedKit_Id] FOREIGN KEY ([ExpectedKit_Id]) REFERENCES [dbo].[StockKit] ([GUIDReference])
);








GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[Panelist]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RewardsAccount_Id]
    ON [dbo].[Panelist]([RewardsAccount_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PanelMember_Id]
    ON [dbo].[Panelist]([PanelMember_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CollaborationMethodology_Id]
    ON [dbo].[Panelist]([CollaborationMethodology_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[Panelist]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IncentiveLevel_Id]
    ON [dbo].[Panelist]([IncentiveLevel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ExpectedKit_Id]
    ON [dbo].[Panelist]([ExpectedKit_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ChangeReason_Id]
    ON [dbo].[Panelist]([ChangeReason_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Panelist]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelist_U 
ON dbo.[Panelist] FOR update 
AS 
insert into audit.[Panelist](	 [GUIDReference]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[RewardsAccount_Id]	 ,[PanelMember_Id]	 ,[CollaborationMethodology_Id]	 ,[State_Id]	 ,[IncentiveLevel_Id]	 ,[ExpectedKit_Id]	 ,[ChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CreationDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panel_Id]	 ,d.[RewardsAccount_Id]	 ,d.[PanelMember_Id]	 ,d.[CollaborationMethodology_Id]	 ,d.[State_Id]	 ,d.[IncentiveLevel_Id]	 ,d.[ExpectedKit_Id]	 ,d.[ChangeReason_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Panelist](	 [GUIDReference]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[RewardsAccount_Id]	 ,[PanelMember_Id]	 ,[CollaborationMethodology_Id]	 ,[State_Id]	 ,[IncentiveLevel_Id]	 ,[ExpectedKit_Id]	 ,[ChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CreationDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panel_Id]	 ,i.[RewardsAccount_Id]	 ,i.[PanelMember_Id]	 ,i.[CollaborationMethodology_Id]	 ,i.[State_Id]	 ,i.[IncentiveLevel_Id]	 ,i.[ExpectedKit_Id]	 ,i.[ChangeReason_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanelist_I
ON dbo.[Panelist] FOR insert 
AS 
insert into audit.[Panelist](	 [GUIDReference]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[RewardsAccount_Id]	 ,[PanelMember_Id]	 ,[CollaborationMethodology_Id]	 ,[State_Id]	 ,[IncentiveLevel_Id]	 ,[ExpectedKit_Id]	 ,[ChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CreationDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panel_Id]	 ,i.[RewardsAccount_Id]	 ,i.[PanelMember_Id]	 ,i.[CollaborationMethodology_Id]	 ,i.[State_Id]	 ,i.[IncentiveLevel_Id]	 ,i.[ExpectedKit_Id]	 ,i.[ChangeReason_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelist_D
ON dbo.[Panelist] FOR delete 
AS 
insert into audit.[Panelist](	 [GUIDReference]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[RewardsAccount_Id]	 ,[PanelMember_Id]	 ,[CollaborationMethodology_Id]	 ,[State_Id]	 ,[IncentiveLevel_Id]	 ,[ExpectedKit_Id]	 ,[ChangeReason_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CreationDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panel_Id]	 ,d.[RewardsAccount_Id]	 ,d.[PanelMember_Id]	 ,d.[CollaborationMethodology_Id]	 ,d.[State_Id]	 ,d.[IncentiveLevel_Id]	 ,d.[ExpectedKit_Id]	 ,d.[ChangeReason_Id]	 ,d.[Country_Id],'D' from deleted d
GO

