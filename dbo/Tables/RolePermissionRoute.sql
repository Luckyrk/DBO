
CREATE TABLE [dbo].[RolePermissionRoute](
	[Role_Id] [uniqueidentifier] NOT NULL,
	[PermissionRoute_Id] [uniqueidentifier] NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
 CONSTRAINT [PK_dbo.RolePermissionRoute] PRIMARY KEY CLUSTERED 
(
	[Role_Id] ASC,
	[PermissionRoute_Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) --ON [PRIMARY]

GO

ALTER TABLE [dbo].[RolePermissionRoute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RolePermissionRoute_dbo.FunctionalRole_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [dbo].[FunctionalRole] ([FunctionalRoleId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[RolePermissionRoute] CHECK CONSTRAINT [FK_dbo.RolePermissionRoute_dbo.FunctionalRole_Role_Id]
GO

ALTER TABLE [dbo].[RolePermissionRoute]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RolePermissionRoute_dbo.PermissionRoute_PermissionRoute_Id] FOREIGN KEY([PermissionRoute_Id])
REFERENCES [dbo].[PermissionRoute] ([Id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[RolePermissionRoute] CHECK CONSTRAINT [FK_dbo.RolePermissionRoute_dbo.PermissionRoute_PermissionRoute_Id]
GO


