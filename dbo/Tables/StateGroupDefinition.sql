﻿CREATE TABLE [dbo].[StateGroupDefinition] (
    [GUIDReference]           UNIQUEIDENTIFIER NOT NULL,
    [Name]                    NVARCHAR (150)   NOT NULL,
    [Target_Percentage]       INT              NOT NULL,
    [Panel_Id]                UNIQUEIDENTIFIER NOT NULL,
    [DemographicTargetSet_Id] UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateGroupDefinition] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StateGroupDefinition_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateGroupDefinition_dbo.PanelTargetDefinition_DemographicTargetSet_Id] FOREIGN KEY ([DemographicTargetSet_Id]) REFERENCES [dbo].[PanelTargetDefinition] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[StateGroupDefinition]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DemographicTargetSet_Id]
    ON [dbo].[StateGroupDefinition]([DemographicTargetSet_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateGroupDefinition_U 
ON dbo.[StateGroupDefinition] FOR update 
AS 
insert into audit.[StateGroupDefinition](
insert into audit.[StateGroupDefinition](
GO
CREATE TRIGGER dbo.trgStateGroupDefinition_I
ON dbo.[StateGroupDefinition] FOR insert 
AS 
insert into audit.[StateGroupDefinition](
GO
CREATE TRIGGER dbo.trgStateGroupDefinition_D
ON dbo.[StateGroupDefinition] FOR delete 
AS 
insert into audit.[StateGroupDefinition](