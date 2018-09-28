
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
insert into audit.[RoleIdentityUser](
insert into audit.[RoleIdentityUser](
GO
CREATE TRIGGER dbo.trgRoleIdentityUser_I
ON dbo.[RoleIdentityUser] FOR insert 
AS 
insert into audit.[RoleIdentityUser](
GO
CREATE TRIGGER dbo.trgRoleIdentityUser_D
ON dbo.[RoleIdentityUser] FOR delete 
AS 
insert into audit.[RoleIdentityUser](