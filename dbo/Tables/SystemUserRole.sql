CREATE TABLE [dbo].[SystemUserRole] (
    [Id]               UNIQUEIDENTIFIER NOT NULL,
    [IdentityUserId]   UNIQUEIDENTIFIER NOT NULL,
    [SystemRoleTypeId] BIGINT           NOT NULL,
    [CountryId]        UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SystemUserRole] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.SystemUserRole_dbo.Country_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.SystemUserRole_dbo.IdentityUser_IdentityUserId] FOREIGN KEY ([IdentityUserId]) REFERENCES [dbo].[IdentityUser] ([Id]),
    CONSTRAINT [FK_dbo.SystemUserRole_dbo.SystemRoleType_SystemRoleTypeId] FOREIGN KEY ([SystemRoleTypeId]) REFERENCES [dbo].[SystemRoleType] ([SystemRoleTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_IdentityUserId]
    ON [dbo].[SystemUserRole]([IdentityUserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SystemRoleTypeId]
    ON [dbo].[SystemUserRole]([SystemRoleTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CountryId]
    ON [dbo].[SystemUserRole]([CountryId] ASC);


GO
CREATE TRIGGER dbo.trgSystemUserRole_U 
ON dbo.[SystemUserRole] FOR update 
AS 
insert into audit.[SystemUserRole](	 [Id]	 ,[IdentityUserId]	 ,[SystemRoleTypeId]	 ,[CountryId]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IdentityUserId]	 ,d.[SystemRoleTypeId]	 ,d.[CountryId],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[SystemUserRole](	 [Id]	 ,[IdentityUserId]	 ,[SystemRoleTypeId]	 ,[CountryId]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IdentityUserId]	 ,i.[SystemRoleTypeId]	 ,i.[CountryId],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgSystemUserRole_I
ON dbo.[SystemUserRole] FOR insert 
AS 
insert into audit.[SystemUserRole](	 [Id]	 ,[IdentityUserId]	 ,[SystemRoleTypeId]	 ,[CountryId]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IdentityUserId]	 ,i.[SystemRoleTypeId]	 ,i.[CountryId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgSystemUserRole_D
ON dbo.[SystemUserRole] FOR delete 
AS 
insert into audit.[SystemUserRole](	 [Id]	 ,[IdentityUserId]	 ,[SystemRoleTypeId]	 ,[CountryId]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IdentityUserId]	 ,d.[SystemRoleTypeId]	 ,d.[CountryId],'D' from deleted d