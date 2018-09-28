CREATE TABLE [dbo].[PermissionRouteRole] (
    [PermissionRoute_Id] UNIQUEIDENTIFIER NOT NULL,
    [Role_Id]            UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PermissionRouteRole] PRIMARY KEY CLUSTERED ([PermissionRoute_Id] ASC, [Role_Id] ASC),
    CONSTRAINT [FK_dbo.PermissionRouteRole_dbo.FunctionalRole_Role_Id] FOREIGN KEY ([Role_Id]) REFERENCES [dbo].[FunctionalRole] ([FunctionalRoleId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.PermissionRouteRole_dbo.PermissionRoute_PermissionRoute_Id] FOREIGN KEY ([PermissionRoute_Id]) REFERENCES [dbo].[PermissionRoute] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_PermissionRoute_Id]
    ON [dbo].[PermissionRouteRole]([PermissionRoute_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Role_Id]
    ON [dbo].[PermissionRouteRole]([Role_Id] ASC);


GO
CREATE TRIGGER dbo.trgPermissionRouteRole_U 
ON dbo.[PermissionRouteRole] FOR update 
AS 
insert into audit.[PermissionRouteRole](	 [PermissionRoute_Id]	 ,[Role_Id]	 ,AuditOperation) select 	 d.[PermissionRoute_Id]	 ,d.[Role_Id],'O'  from 	 deleted d join inserted i on d.PermissionRoute_Id = i.PermissionRoute_Id	 and d.Role_Id = i.Role_Id 
insert into audit.[PermissionRouteRole](	 [PermissionRoute_Id]	 ,[Role_Id]	 ,AuditOperation) select 	 i.[PermissionRoute_Id]	 ,i.[Role_Id],'N'  from 	 deleted d join inserted i on d.PermissionRoute_Id = i.PermissionRoute_Id	 and d.Role_Id = i.Role_Id
GO
CREATE TRIGGER dbo.trgPermissionRouteRole_I
ON dbo.[PermissionRouteRole] FOR insert 
AS 
insert into audit.[PermissionRouteRole](	 [PermissionRoute_Id]	 ,[Role_Id]	 ,AuditOperation) select 	 i.[PermissionRoute_Id]	 ,i.[Role_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPermissionRouteRole_D
ON dbo.[PermissionRouteRole] FOR delete 
AS 
insert into audit.[PermissionRouteRole](	 [PermissionRoute_Id]	 ,[Role_Id]	 ,AuditOperation) select 	 d.[PermissionRoute_Id]	 ,d.[Role_Id],'D' from deleted d