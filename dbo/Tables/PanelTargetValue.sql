CREATE TABLE [dbo].[PanelTargetValue] (
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
insert into audit.[PanelTargetValue](	 [GUIDReference]	 ,[Target]	 ,[DemographicTarget_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Target]	 ,d.[DemographicTarget_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[PanelTargetValue](	 [GUIDReference]	 ,[Target]	 ,[DemographicTarget_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Target]	 ,i.[DemographicTarget_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanelTargetValue_I
ON dbo.[PanelTargetValue] FOR insert 
AS 
insert into audit.[PanelTargetValue](	 [GUIDReference]	 ,[Target]	 ,[DemographicTarget_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Target]	 ,i.[DemographicTarget_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelTargetValue_D
ON dbo.[PanelTargetValue] FOR delete 
AS 
insert into audit.[PanelTargetValue](	 [GUIDReference]	 ,[Target]	 ,[DemographicTarget_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Target]	 ,d.[DemographicTarget_Id],'D' from deleted d