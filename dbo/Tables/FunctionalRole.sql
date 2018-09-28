CREATE TABLE [dbo].[FunctionalRole] (
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
insert into audit.[FunctionalRole](	 [FunctionalRoleId]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[OwnerCountry_Id]	 ,[Description]	 ,[ParentFunctionalRoleId]	 ,[Parent_Id]	 ,AuditOperation) select 	 d.[FunctionalRoleId]	 ,d.[Name]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[OwnerCountry_Id]	 ,d.[Description]	 ,d.[ParentFunctionalRoleId]	 ,d.[Parent_Id],'O'  from 	 deleted d join inserted i on d.FunctionalRoleId = i.FunctionalRoleId 
insert into audit.[FunctionalRole](	 [FunctionalRoleId]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[OwnerCountry_Id]	 ,[Description]	 ,[ParentFunctionalRoleId]	 ,[Parent_Id]	 ,AuditOperation) select 	 i.[FunctionalRoleId]	 ,i.[Name]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[OwnerCountry_Id]	 ,i.[Description]	 ,i.[ParentFunctionalRoleId]	 ,i.[Parent_Id],'N'  from 	 deleted d join inserted i on d.FunctionalRoleId = i.FunctionalRoleId
GO
CREATE TRIGGER dbo.trgFunctionalRole_I
ON dbo.[FunctionalRole] FOR insert 
AS 
insert into audit.[FunctionalRole](	 [FunctionalRoleId]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[OwnerCountry_Id]	 ,[Description]	 ,[ParentFunctionalRoleId]	 ,[Parent_Id]	 ,AuditOperation) select 	 i.[FunctionalRoleId]	 ,i.[Name]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[OwnerCountry_Id]	 ,i.[Description]	 ,i.[ParentFunctionalRoleId]	 ,i.[Parent_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgFunctionalRole_D
ON dbo.[FunctionalRole] FOR delete 
AS 
insert into audit.[FunctionalRole](	 [FunctionalRoleId]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[OwnerCountry_Id]	 ,[Description]	 ,[ParentFunctionalRoleId]	 ,[Parent_Id]	 ,AuditOperation) select 	 d.[FunctionalRoleId]	 ,d.[Name]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[OwnerCountry_Id]	 ,d.[Description]	 ,d.[ParentFunctionalRoleId]	 ,d.[Parent_Id],'D' from deleted d