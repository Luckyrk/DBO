﻿CREATE TABLE [dbo].[PermissionRouteType] (
    [Id]                           UNIQUEIDENTIFIER NOT NULL,
    [Description]                  NVARCHAR (400)   NOT NULL,
    [ParentPermissionRouteType_Id] UNIQUEIDENTIFIER NULL,
    [GPSUser]                      NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]           DATETIME         NULL,
    [CreationTimeStamp]            DATETIME         NULL,
    CONSTRAINT [PK_dbo.PermissionRouteType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.PermissionRouteType_dbo.PermissionRouteType_ParentPermissionRouteType_Id] FOREIGN KEY ([ParentPermissionRouteType_Id]) REFERENCES [dbo].[PermissionRouteType] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_ParentPermissionRouteType_Id]
    ON [dbo].[PermissionRouteType]([ParentPermissionRouteType_Id] ASC);


GO
CREATE TRIGGER dbo.trgPermissionRouteType_U 
ON dbo.[PermissionRouteType] FOR update 
AS 
insert into audit.[PermissionRouteType](
insert into audit.[PermissionRouteType](
GO
CREATE TRIGGER dbo.trgPermissionRouteType_I
ON dbo.[PermissionRouteType] FOR insert 
AS 
insert into audit.[PermissionRouteType](
GO
CREATE TRIGGER dbo.trgPermissionRouteType_D
ON dbo.[PermissionRouteType] FOR delete 
AS 
insert into audit.[PermissionRouteType](