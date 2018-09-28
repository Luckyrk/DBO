﻿CREATE TABLE [dbo].[IdentityUserSession] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [SessionKey]         UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [IdentityUser_Id]    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IdentityUserSession] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.IdentityUserSession_dbo.IdentityUser_IdentityUser_Id] FOREIGN KEY ([IdentityUser_Id]) REFERENCES [dbo].[IdentityUser] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_IdentityUser_Id]
    ON [dbo].[IdentityUserSession]([IdentityUser_Id] ASC);


GO
CREATE TRIGGER dbo.trgIdentityUserSession_U 
ON dbo.[IdentityUserSession] FOR update 
AS 
insert into audit.[IdentityUserSession](
insert into audit.[IdentityUserSession](
GO
CREATE TRIGGER dbo.trgIdentityUserSession_I
ON dbo.[IdentityUserSession] FOR insert 
AS 
insert into audit.[IdentityUserSession](
GO
CREATE TRIGGER dbo.trgIdentityUserSession_D
ON dbo.[IdentityUserSession] FOR delete 
AS 
insert into audit.[IdentityUserSession](