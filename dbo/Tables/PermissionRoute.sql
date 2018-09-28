﻿CREATE TABLE [dbo].[PermissionRoute] (
    [Id]                       UNIQUEIDENTIFIER NOT NULL,
    [Path]                     NVARCHAR (400)   NULL,
    [Name]                     NVARCHAR (100)   NOT NULL,
    [PermissionRouteType_Id]   UNIQUEIDENTIFIER NOT NULL,
    [ParentPermissionRoute_Id] UNIQUEIDENTIFIER NULL,
    [GPSUser]                  NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,
    [CreationTimeStamp]        DATETIME         NULL,
    CONSTRAINT [PK_dbo.PermissionRoute] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.PermissionRoute_dbo.PermissionRoute_ParentPermissionRoute_Id] FOREIGN KEY ([ParentPermissionRoute_Id]) REFERENCES [dbo].[PermissionRoute] ([Id]),
    CONSTRAINT [FK_dbo.PermissionRoute_dbo.PermissionRouteType_PermissionRouteType_Id] FOREIGN KEY ([PermissionRouteType_Id]) REFERENCES [dbo].[PermissionRouteType] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_PermissionRouteType_Id]
    ON [dbo].[PermissionRoute]([PermissionRouteType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ParentPermissionRoute_Id]
    ON [dbo].[PermissionRoute]([ParentPermissionRoute_Id] ASC);


GO
CREATE TRIGGER dbo.trgPermissionRoute_U 
ON dbo.[PermissionRoute] FOR update 
AS 
insert into audit.[PermissionRoute](
insert into audit.[PermissionRoute](
GO
CREATE TRIGGER dbo.trgPermissionRoute_I
ON dbo.[PermissionRoute] FOR insert 
AS 
insert into audit.[PermissionRoute](
GO
CREATE TRIGGER dbo.trgPermissionRoute_D
ON dbo.[PermissionRoute] FOR delete 
AS 
insert into audit.[PermissionRoute](