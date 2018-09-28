﻿CREATE TABLE [dbo].[FunctionalRole] (
    [FunctionalRoleId]       UNIQUEIDENTIFIER NOT NULL,
    [Name]                   NVARCHAR (200)   NULL,
    [GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    [OwnerCountry_Id]        UNIQUEIDENTIFIER NOT NULL,
    [Description]            NVARCHAR (500)   NULL,
    [ParentFunctionalRoleId] UNIQUEIDENTIFIER NULL,
    [Parent_Id]              UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.FunctionalRole] PRIMARY KEY CLUSTERED ([FunctionalRoleId] ASC),
    CONSTRAINT [FK_dbo.FunctionalRole_dbo.Country_OwnerCountry_Id] FOREIGN KEY ([OwnerCountry_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.FunctionalRole_dbo.FunctionalRole_Parent_Id] FOREIGN KEY ([Parent_Id]) REFERENCES [dbo].[FunctionalRole] ([FunctionalRoleId])
);






GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountry_Id]
    ON [dbo].[FunctionalRole]([OwnerCountry_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Parent_Id]
    ON [dbo].[FunctionalRole]([Parent_Id] ASC);


GO
CREATE TRIGGER dbo.trgFunctionalRole_U 
ON dbo.[FunctionalRole] FOR update 
AS 
insert into audit.[FunctionalRole](
insert into audit.[FunctionalRole](
GO
CREATE TRIGGER dbo.trgFunctionalRole_I
ON dbo.[FunctionalRole] FOR insert 
AS 
insert into audit.[FunctionalRole](
GO
CREATE TRIGGER dbo.trgFunctionalRole_D
ON dbo.[FunctionalRole] FOR delete 
AS 
insert into audit.[FunctionalRole](