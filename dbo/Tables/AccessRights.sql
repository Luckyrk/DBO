CREATE TABLE [dbo].[AccessRights] (
    [AccessContextId]        BIGINT   NOT NULL,
    [RestrictedAccessAreaId] BIGINT   NOT NULL,
    [SystemOperationId]      BIGINT   NOT NULL,
    [SystemRoleTypeId]       BIGINT   NOT NULL,
    [IsPermissionGranted]    BIT      NOT NULL,
    [ActiveFrom]             DATETIME NOT NULL,
    [ActiveTo]               DATETIME NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.AccessRights] PRIMARY KEY CLUSTERED ([AccessContextId] ASC, [RestrictedAccessAreaId] ASC, [SystemOperationId] ASC, [SystemRoleTypeId] ASC),
    CONSTRAINT [FK_dbo.AccessRights_dbo.AccessContext_AccessContextId] FOREIGN KEY ([AccessContextId]) REFERENCES [dbo].[AccessContext] ([AccessContextId]),
    CONSTRAINT [FK_dbo.AccessRights_dbo.RestrictedAccessArea_RestrictedAccessAreaId] FOREIGN KEY ([RestrictedAccessAreaId]) REFERENCES [dbo].[RestrictedAccessArea] ([RestrictedAccessAreaId]),
    CONSTRAINT [FK_dbo.AccessRights_dbo.SystemOperation_SystemOperationId] FOREIGN KEY ([SystemOperationId]) REFERENCES [dbo].[SystemOperation] ([SystemOperationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_AccessContextId]
    ON [dbo].[AccessRights]([AccessContextId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RestrictedAccessAreaId]
    ON [dbo].[AccessRights]([RestrictedAccessAreaId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SystemOperationId]
    ON [dbo].[AccessRights]([SystemOperationId] ASC);


GO
CREATE TRIGGER dbo.trgAccessRights_U 
ON dbo.[AccessRights] FOR update 
AS 
insert into audit.[AccessRights](	 [AccessContextId]	 ,[RestrictedAccessAreaId]	 ,[SystemOperationId]	 ,[SystemRoleTypeId]	 ,[IsPermissionGranted]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[AccessContextId]	 ,d.[RestrictedAccessAreaId]	 ,d.[SystemOperationId]	 ,d.[SystemRoleTypeId]	 ,d.[IsPermissionGranted]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.AccessContextId = i.AccessContextId	 and d.RestrictedAccessAreaId = i.RestrictedAccessAreaId	 and d.SystemOperationId = i.SystemOperationId	 and d.SystemRoleTypeId = i.SystemRoleTypeId 
insert into audit.[AccessRights](	 [AccessContextId]	 ,[RestrictedAccessAreaId]	 ,[SystemOperationId]	 ,[SystemRoleTypeId]	 ,[IsPermissionGranted]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[AccessContextId]	 ,i.[RestrictedAccessAreaId]	 ,i.[SystemOperationId]	 ,i.[SystemRoleTypeId]	 ,i.[IsPermissionGranted]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.AccessContextId = i.AccessContextId	 and d.RestrictedAccessAreaId = i.RestrictedAccessAreaId	 and d.SystemOperationId = i.SystemOperationId	 and d.SystemRoleTypeId = i.SystemRoleTypeId
GO
CREATE TRIGGER dbo.trgAccessRights_I
ON dbo.[AccessRights] FOR insert 
AS 
insert into audit.[AccessRights](	 [AccessContextId]	 ,[RestrictedAccessAreaId]	 ,[SystemOperationId]	 ,[SystemRoleTypeId]	 ,[IsPermissionGranted]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[AccessContextId]	 ,i.[RestrictedAccessAreaId]	 ,i.[SystemOperationId]	 ,i.[SystemRoleTypeId]	 ,i.[IsPermissionGranted]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAccessRights_D
ON dbo.[AccessRights] FOR delete 
AS 
insert into audit.[AccessRights](	 [AccessContextId]	 ,[RestrictedAccessAreaId]	 ,[SystemOperationId]	 ,[SystemRoleTypeId]	 ,[IsPermissionGranted]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[AccessContextId]	 ,d.[RestrictedAccessAreaId]	 ,d.[SystemOperationId]	 ,d.[SystemRoleTypeId]	 ,d.[IsPermissionGranted]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d