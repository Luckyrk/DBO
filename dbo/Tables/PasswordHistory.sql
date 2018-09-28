CREATE TABLE [dbo].[PasswordHistory] (
    [Id]                UNIQUEIDENTIFIER NOT NULL,
    [IdentityUserID]    UNIQUEIDENTIFIER NOT NULL,
    [OldPassword]       NVARCHAR (50)    NULL,
    [GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PasswordHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgPasswordHistory_U 
ON dbo.[PasswordHistory] FOR update 
AS 
insert into audit.[PasswordHistory](	 [Id]	 ,[IdentityUserID]	 ,[OldPassword]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IdentityUserID]	 ,d.[OldPassword]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[PasswordHistory](	 [Id]	 ,[IdentityUserID]	 ,[OldPassword]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IdentityUserID]	 ,i.[OldPassword]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgPasswordHistory_I
ON dbo.[PasswordHistory] FOR insert 
AS 
insert into audit.[PasswordHistory](	 [Id]	 ,[IdentityUserID]	 ,[OldPassword]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IdentityUserID]	 ,i.[OldPassword]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPasswordHistory_D
ON dbo.[PasswordHistory] FOR delete 
AS 
insert into audit.[PasswordHistory](	 [Id]	 ,[IdentityUserID]	 ,[OldPassword]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IdentityUserID]	 ,d.[OldPassword]	 ,d.[CreationTimeStamp],'D' from deleted d