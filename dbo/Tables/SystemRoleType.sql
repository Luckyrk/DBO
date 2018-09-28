CREATE TABLE [dbo].[SystemRoleType] (
    [SystemRoleTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SystemRoleType] PRIMARY KEY CLUSTERED ([SystemRoleTypeId] ASC)
);




GO
CREATE TRIGGER dbo.trgSystemRoleType_U 
ON dbo.[SystemRoleType] FOR update 
AS 
insert into audit.[SystemRoleType](	 [SystemRoleTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[SystemRoleTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.SystemRoleTypeId = i.SystemRoleTypeId 
insert into audit.[SystemRoleType](	 [SystemRoleTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[SystemRoleTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.SystemRoleTypeId = i.SystemRoleTypeId
GO
CREATE TRIGGER dbo.trgSystemRoleType_I
ON dbo.[SystemRoleType] FOR insert 
AS 
insert into audit.[SystemRoleType](	 [SystemRoleTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[SystemRoleTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgSystemRoleType_D
ON dbo.[SystemRoleType] FOR delete 
AS 
insert into audit.[SystemRoleType](	 [SystemRoleTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[SystemRoleTypeId]	 ,d.[Description],'D' from deleted d