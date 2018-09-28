﻿CREATE TABLE [dbo].[DemographicTargetScoreboard] (
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
insert into audit.[DemographicTargetScoreboard](
insert into audit.[DemographicTargetScoreboard](
GO
CREATE TRIGGER dbo.trgDemographicTargetScoreboard_I
ON dbo.[DemographicTargetScoreboard] FOR insert 
AS 
insert into audit.[DemographicTargetScoreboard](
GO
CREATE TRIGGER dbo.trgDemographicTargetScoreboard_D
ON dbo.[DemographicTargetScoreboard] FOR delete 
AS 
insert into audit.[DemographicTargetScoreboard](