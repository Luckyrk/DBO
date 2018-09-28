﻿CREATE TABLE [dbo].[IdentityUserRole] (
    [IdentityUser_Id] UNIQUEIDENTIFIER NOT NULL,
    [Role_Id]         UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.IdentityUserRole] PRIMARY KEY CLUSTERED ([IdentityUser_Id] ASC, [Role_Id] ASC),
    CONSTRAINT [FK_dbo.IdentityUserRole_dbo.FunctionalRole_Role_Id] FOREIGN KEY ([Role_Id]) REFERENCES [dbo].[FunctionalRole] ([FunctionalRoleId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.IdentityUserRole_dbo.IdentityUser_IdentityUser_Id] FOREIGN KEY ([IdentityUser_Id]) REFERENCES [dbo].[IdentityUser] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_IdentityUser_Id]
    ON [dbo].[IdentityUserRole]([IdentityUser_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Role_Id]
    ON [dbo].[IdentityUserRole]([Role_Id] ASC);


GO
CREATE TRIGGER dbo.trgIdentityUserRole_U 
ON dbo.[IdentityUserRole] FOR update 
AS 
insert into audit.[IdentityUserRole](
insert into audit.[IdentityUserRole](
GO
CREATE TRIGGER dbo.trgIdentityUserRole_I
ON dbo.[IdentityUserRole] FOR insert 
AS 
insert into audit.[IdentityUserRole](
GO
CREATE TRIGGER dbo.trgIdentityUserRole_D
ON dbo.[IdentityUserRole] FOR delete 
AS 
insert into audit.[IdentityUserRole](