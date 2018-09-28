﻿CREATE TABLE [dbo].[PanelTargetValueMapping] (
    [RelatedDemographic_Id] UNIQUEIDENTIFIER NOT NULL,
    [DemographicValue_Id]   UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelTargetValueMapping] PRIMARY KEY CLUSTERED ([RelatedDemographic_Id] ASC, [DemographicValue_Id] ASC),
    CONSTRAINT [FK_dbo.PanelTargetValueMapping_dbo.DemographicValue_DemographicValue_Id] FOREIGN KEY ([DemographicValue_Id]) REFERENCES [dbo].[DemographicValue] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.PanelTargetValueMapping_dbo.PanelTargetValue_RelatedDemographic_Id] FOREIGN KEY ([RelatedDemographic_Id]) REFERENCES [dbo].[PanelTargetValue] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_RelatedDemographic_Id]
    ON [dbo].[PanelTargetValueMapping]([RelatedDemographic_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DemographicValue_Id]
    ON [dbo].[PanelTargetValueMapping]([DemographicValue_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelTargetValueMapping_U 
ON dbo.[PanelTargetValueMapping] FOR update 
AS 
insert into audit.[PanelTargetValueMapping](
insert into audit.[PanelTargetValueMapping](
GO
CREATE TRIGGER dbo.trgPanelTargetValueMapping_I
ON dbo.[PanelTargetValueMapping] FOR insert 
AS 
insert into audit.[PanelTargetValueMapping](
GO
CREATE TRIGGER dbo.trgPanelTargetValueMapping_D
ON dbo.[PanelTargetValueMapping] FOR delete 
AS 
insert into audit.[PanelTargetValueMapping](