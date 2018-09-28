CREATE TABLE [dbo].[DynamicRole] (
    [DynamicRoleId]  UNIQUEIDENTIFIER NOT NULL,
    [Code]           INT              NOT NULL,
    [Translation_Id] UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.DynamicRole] PRIMARY KEY CLUSTERED ([DynamicRoleId] ASC),
    CONSTRAINT [FK_dbo.DynamicRole_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.DynamicRole_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);


GO
CREATE TRIGGER dbo.trgDynamicRole_U 
ON dbo.[DynamicRole] FOR update 
AS 
insert into audit.[DynamicRole](	 [DynamicRoleId]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[DynamicRoleId]	 ,d.[Code]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.DynamicRoleId = i.DynamicRoleId 
insert into audit.[DynamicRole](	 [DynamicRoleId]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[DynamicRoleId]	 ,i.[Code]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.DynamicRoleId = i.DynamicRoleId
GO
CREATE TRIGGER dbo.trgDynamicRole_I
ON dbo.[DynamicRole] FOR insert 
AS 
insert into audit.[DynamicRole](	 [DynamicRoleId]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[DynamicRoleId]	 ,i.[Code]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDynamicRole_D
ON dbo.[DynamicRole] FOR delete 
AS 
insert into audit.[DynamicRole](	 [DynamicRoleId]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[DynamicRoleId]	 ,d.[Code]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d