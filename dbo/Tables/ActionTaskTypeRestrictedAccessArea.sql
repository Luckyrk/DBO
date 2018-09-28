CREATE TABLE [dbo].[ActionTaskTypeRestrictedAccessArea] (
    [ActionTaskTypeId]       UNIQUEIDENTIFIER NOT NULL,
    [RestrictedAccessAreaId] BIGINT           NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ActionTaskTypeRestrictedAccessArea] PRIMARY KEY CLUSTERED ([ActionTaskTypeId] ASC, [RestrictedAccessAreaId] ASC),
    CONSTRAINT [FK_dbo.ActionTaskTypeRestrictedAccessArea_dbo.ActionTaskType_ActionTaskTypeId] FOREIGN KEY ([ActionTaskTypeId]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ActionTaskTypeRestrictedAccessArea_dbo.RestrictedAccessArea_RestrictedAccessAreaId] FOREIGN KEY ([RestrictedAccessAreaId]) REFERENCES [dbo].[RestrictedAccessArea] ([RestrictedAccessAreaId]) ON DELETE CASCADE
);


GO
CREATE TRIGGER dbo.trgActionTaskTypeRestrictedAccessArea_U 
ON dbo.[ActionTaskTypeRestrictedAccessArea] FOR update 
AS 
insert into audit.[ActionTaskTypeRestrictedAccessArea](	 [ActionTaskTypeId]	 ,[RestrictedAccessAreaId]	 ,AuditOperation) select 	 d.[ActionTaskTypeId]	 ,d.[RestrictedAccessAreaId],'O'  from 	 deleted d join inserted i on d.ActionTaskTypeId = i.ActionTaskTypeId	 and d.RestrictedAccessAreaId = i.RestrictedAccessAreaId 
insert into audit.[ActionTaskTypeRestrictedAccessArea](	 [ActionTaskTypeId]	 ,[RestrictedAccessAreaId]	 ,AuditOperation) select 	 i.[ActionTaskTypeId]	 ,i.[RestrictedAccessAreaId],'N'  from 	 deleted d join inserted i on d.ActionTaskTypeId = i.ActionTaskTypeId	 and d.RestrictedAccessAreaId = i.RestrictedAccessAreaId
GO
CREATE TRIGGER dbo.trgActionTaskTypeRestrictedAccessArea_D
ON dbo.[ActionTaskTypeRestrictedAccessArea] FOR delete 
AS 
insert into audit.[ActionTaskTypeRestrictedAccessArea](	 [ActionTaskTypeId]	 ,[RestrictedAccessAreaId]	 ,AuditOperation) select 	 d.[ActionTaskTypeId]	 ,d.[RestrictedAccessAreaId],'D' from deleted d
GO
CREATE TRIGGER dbo.trgActionTaskTypeRestrictedAccessArea_I
ON dbo.[ActionTaskTypeRestrictedAccessArea] FOR insert 
AS 
insert into audit.[ActionTaskTypeRestrictedAccessArea](	 [ActionTaskTypeId]	 ,[RestrictedAccessAreaId]	 ,AuditOperation) select 	 i.[ActionTaskTypeId]	 ,i.[RestrictedAccessAreaId],'I' from inserted i