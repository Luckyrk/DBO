CREATE TABLE [dbo].[DemographicTargetScoreboard] (
    [GUIDReference]                    UNIQUEIDENTIFIER NOT NULL,
    [Target]                           BIGINT           NOT NULL,
    [Actual]                           BIGINT           NOT NULL,
    [GPSUser]                          NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]               DATETIME         NULL,
    [CreationTimeStamp]                DATETIME         NULL,
    [Dimension_Id]                     UNIQUEIDENTIFIER NOT NULL,
    [RelatedDemographic_Id]            UNIQUEIDENTIFIER NULL,
    [DemographicStateSetScoreboard_Id] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.DemographicTargetScoreboard] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicTargetScoreboard_dbo.DemographicStateSetScoreboard_DemographicStateSetScoreboard_Id] FOREIGN KEY ([DemographicStateSetScoreboard_Id]) REFERENCES [dbo].[DemographicStateSetScoreboard] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DemographicTargetScoreboard_dbo.PanelTargetValue_RelatedDemographic_Id] FOREIGN KEY ([RelatedDemographic_Id]) REFERENCES [dbo].[PanelTargetValue] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DemographicTargetScoreboard_dbo.PanelTargetValueDefinition_Dimension_Id] FOREIGN KEY ([Dimension_Id]) REFERENCES [dbo].[PanelTargetValueDefinition] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Dimension_Id]
    ON [dbo].[DemographicTargetScoreboard]([Dimension_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RelatedDemographic_Id]
    ON [dbo].[DemographicTargetScoreboard]([RelatedDemographic_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DemographicStateSetScoreboard_Id]
    ON [dbo].[DemographicTargetScoreboard]([DemographicStateSetScoreboard_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemographicTargetScoreboard_U 
ON dbo.[DemographicTargetScoreboard] FOR update 
AS 
insert into audit.[DemographicTargetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Dimension_Id]	 ,[RelatedDemographic_Id]	 ,[DemographicStateSetScoreboard_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Target]	 ,d.[Actual]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Dimension_Id]	 ,d.[RelatedDemographic_Id]	 ,d.[DemographicStateSetScoreboard_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[DemographicTargetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Dimension_Id]	 ,[RelatedDemographic_Id]	 ,[DemographicStateSetScoreboard_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Target]	 ,i.[Actual]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Dimension_Id]	 ,i.[RelatedDemographic_Id]	 ,i.[DemographicStateSetScoreboard_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgDemographicTargetScoreboard_I
ON dbo.[DemographicTargetScoreboard] FOR insert 
AS 
insert into audit.[DemographicTargetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Dimension_Id]	 ,[RelatedDemographic_Id]	 ,[DemographicStateSetScoreboard_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Target]	 ,i.[Actual]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Dimension_Id]	 ,i.[RelatedDemographic_Id]	 ,i.[DemographicStateSetScoreboard_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemographicTargetScoreboard_D
ON dbo.[DemographicTargetScoreboard] FOR delete 
AS 
insert into audit.[DemographicTargetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Dimension_Id]	 ,[RelatedDemographic_Id]	 ,[DemographicStateSetScoreboard_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Target]	 ,d.[Actual]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Dimension_Id]	 ,d.[RelatedDemographic_Id]	 ,d.[DemographicStateSetScoreboard_Id],'D' from deleted d