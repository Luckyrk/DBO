CREATE TABLE [dbo].[PanelTargetValueDefinition] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelTargetValueDefinition] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);




GO
CREATE TRIGGER dbo.trgPanelTargetValueDefinition_U 
ON dbo.[PanelTargetValueDefinition] FOR update 
AS 
insert into audit.[PanelTargetValueDefinition](	 [GUIDReference]	 ,AuditOperation) select 	 d.[GUIDReference],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[PanelTargetValueDefinition](	 [GUIDReference]	 ,AuditOperation) select 	 i.[GUIDReference],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanelTargetValueDefinition_I
ON dbo.[PanelTargetValueDefinition] FOR insert 
AS 
insert into audit.[PanelTargetValueDefinition](	 [GUIDReference]	 ,AuditOperation) select 	 i.[GUIDReference],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelTargetValueDefinition_D
ON dbo.[PanelTargetValueDefinition] FOR delete 
AS 
insert into audit.[PanelTargetValueDefinition](	 [GUIDReference]	 ,AuditOperation) select 	 d.[GUIDReference],'D' from deleted d