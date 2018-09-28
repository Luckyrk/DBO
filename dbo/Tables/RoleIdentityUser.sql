
CREATE TABLE [dbo].[RoleIdentityUser] (
    [Role_Id]         UNIQUEIDENTIFIER NOT NULL,
    [IdentityUser_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RoleIdentityUser] PRIMARY KEY CLUSTERED ([Role_Id] ASC, [IdentityUser_Id] ASC),
    CONSTRAINT [FK_dbo.RoleIdentityUser_dbo.FunctionalRole_Role_Id] FOREIGN KEY ([Role_Id]) REFERENCES [dbo].[FunctionalRole] ([FunctionalRoleId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.RoleIdentityUser_dbo.IdentityUser_IdentityUser_Id] FOREIGN KEY ([IdentityUser_Id]) REFERENCES [dbo].[IdentityUser] ([Id]) ON DELETE CASCADE
);



GO


GO


GO


GO


GO
CREATE TRIGGER dbo.trgRoleIdentityUser_U 
ON dbo.[RoleIdentityUser] FOR update 
AS 
insert into audit.[RoleIdentityUser](	 [Role_Id]	 ,[IdentityUser_Id]	 ,AuditOperation) select 	 d.[Role_Id]	 ,d.[IdentityUser_Id],'O'  from 	 deleted d join inserted i on d.IdentityUser_Id = i.IdentityUser_Id	 and d.Role_Id = i.Role_Id 
insert into audit.[RoleIdentityUser](	 [Role_Id]	 ,[IdentityUser_Id]	 ,AuditOperation) select 	 i.[Role_Id]	 ,i.[IdentityUser_Id],'N'  from 	 deleted d join inserted i on d.IdentityUser_Id = i.IdentityUser_Id	 and d.Role_Id = i.Role_Id
GO
CREATE TRIGGER dbo.trgRoleIdentityUser_I
ON dbo.[RoleIdentityUser] FOR insert 
AS 
insert into audit.[RoleIdentityUser](	 [Role_Id]	 ,[IdentityUser_Id]	 ,AuditOperation) select 	 i.[Role_Id]	 ,i.[IdentityUser_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRoleIdentityUser_D
ON dbo.[RoleIdentityUser] FOR delete 
AS 
insert into audit.[RoleIdentityUser](	 [Role_Id]	 ,[IdentityUser_Id]	 ,AuditOperation) select 	 d.[Role_Id]	 ,d.[IdentityUser_Id],'D' from deleted d