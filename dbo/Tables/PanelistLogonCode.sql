CREATE TABLE [dbo].[PanelistLogonCode] (
    [PanelistId]                UNIQUEIDENTIFIER NOT NULL,
	[KeyAppSettingId]			UNIQUEIDENTIFIER NOT NULL,
    [LogonCode]					NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_dbo.PanelistLogonCode_dbo.Panelist_Panelist_Id] FOREIGN KEY ([PanelistId]) REFERENCES [dbo].[Panelist] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.PanelistLogonCode_dbo.KeyAppSetting_KeyAppSetting_Id] FOREIGN KEY ([KeyAppSettingId]) REFERENCES [dbo].[KeyAppSetting] ([GUIDReference]) ON DELETE CASCADE,
);

GO
CREATE TRIGGER dbo.trgPanelistLogonCode_U 
ON dbo.[PanelistLogonCode] FOR update 
AS 
insert into audit.[PanelistLogonCode](	 [PanelistId]               
	 ,[KeyAppSettingId]     
	 ,[LogonCode]	 ,AuditOperation) select 	 d.[PanelistId]	 ,d.[KeyAppSettingId]     
	 ,d.[LogonCode],'O'  from 	 deleted d join inserted i on d.PanelistId = i.PanelistId 
insert into audit.[PanelistLogonCode](	 [PanelistId]	 ,[KeyAppSettingId]     
	 ,[LogonCode]	 ,AuditOperation) select 	 i.[PanelistId]	 ,i.[KeyAppSettingId]     
	 ,i.[LogonCode],'N'  from 	 deleted d join inserted i on d.PanelistId = i.PanelistId
GO
CREATE TRIGGER dbo.trgPanelistLogonCode_I
ON dbo.[PanelistLogonCode] FOR insert 
AS 
insert into audit.[PanelistLogonCode](	 [PanelistId]	 ,[KeyAppSettingId]     
	 ,[LogonCode]	 ,AuditOperation) select 	 i.[PanelistId]	 ,i.[KeyAppSettingId]     
	 ,i.[LogonCode],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelistLogonCode_D
ON dbo.[PanelistLogonCode] FOR delete 
AS 
insert into audit.[PanelistLogonCode](	 [PanelistId]	 ,[KeyAppSettingId]     
	 ,[LogonCode]	 ,AuditOperation) select 	 d.[PanelistId]	 ,d.[KeyAppSettingId]     
	 ,d.[LogonCode],'D' from deleted d