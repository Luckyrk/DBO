CREATE TABLE [dbo].[PermissionRoute] (
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
insert into audit.[PermissionRoute](	 [Id]	 ,[Path]	 ,[Name]	 ,[PermissionRouteType_Id]	 ,[ParentPermissionRoute_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Path]	 ,d.[Name]	 ,d.[PermissionRouteType_Id]	 ,d.[ParentPermissionRoute_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[PermissionRoute](	 [Id]	 ,[Path]	 ,[Name]	 ,[PermissionRouteType_Id]	 ,[ParentPermissionRoute_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Path]	 ,i.[Name]	 ,i.[PermissionRouteType_Id]	 ,i.[ParentPermissionRoute_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgPermissionRoute_I
ON dbo.[PermissionRoute] FOR insert 
AS 
insert into audit.[PermissionRoute](	 [Id]	 ,[Path]	 ,[Name]	 ,[PermissionRouteType_Id]	 ,[ParentPermissionRoute_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Path]	 ,i.[Name]	 ,i.[PermissionRouteType_Id]	 ,i.[ParentPermissionRoute_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPermissionRoute_D
ON dbo.[PermissionRoute] FOR delete 
AS 
insert into audit.[PermissionRoute](	 [Id]	 ,[Path]	 ,[Name]	 ,[PermissionRouteType_Id]	 ,[ParentPermissionRoute_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Path]	 ,d.[Name]	 ,d.[PermissionRouteType_Id]	 ,d.[ParentPermissionRoute_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d