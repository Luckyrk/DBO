﻿CREATE TABLE [dbo].[IdentityUser] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [UserName]           NVARCHAR (400)   NOT NULL,
    [Password]           NVARCHAR (50)    NULL,
    [GPSUser]            NVARCHAR (400)   NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IdentityUser] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.IdentityUser_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IdentityUser]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIdentityUser_U 
ON dbo.[IdentityUser] FOR update 
AS 
insert into audit.[IdentityUser](
insert into audit.[IdentityUser](
GO
CREATE TRIGGER dbo.trgIdentityUser_I
ON dbo.[IdentityUser] FOR insert 
AS 
insert into audit.[IdentityUser](
GO
CREATE TRIGGER dbo.trgIdentityUser_D
ON dbo.[IdentityUser] FOR delete 
AS 
insert into audit.[IdentityUser](