﻿CREATE TABLE [dbo].[PanelTargetValue] (
    [GUIDReference]        UNIQUEIDENTIFIER NOT NULL,
    [Target]               INT              NOT NULL,
    [DemographicTarget_Id] UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelTargetValue] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.PanelTargetValue_dbo.PanelTargetValueDefinition_DemographicTarget_Id] FOREIGN KEY ([DemographicTarget_Id]) REFERENCES [dbo].[PanelTargetValueDefinition] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_DemographicTarget_Id]
    ON [dbo].[PanelTargetValue]([DemographicTarget_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelTargetValue_U 
ON dbo.[PanelTargetValue] FOR update 
AS 
insert into audit.[PanelTargetValue](
insert into audit.[PanelTargetValue](
GO
CREATE TRIGGER dbo.trgPanelTargetValue_I
ON dbo.[PanelTargetValue] FOR insert 
AS 
insert into audit.[PanelTargetValue](
GO
CREATE TRIGGER dbo.trgPanelTargetValue_D
ON dbo.[PanelTargetValue] FOR delete 
AS 
insert into audit.[PanelTargetValue](