﻿CREATE TABLE [dbo].[PanelistLogonCode] (
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
insert into audit.[PanelistLogonCode](
	 ,[KeyAppSettingId]     
	 ,[LogonCode]
	 ,d.[LogonCode],'O'  from 
insert into audit.[PanelistLogonCode](
	 ,[LogonCode]
	 ,i.[LogonCode],'N'  from 
GO
CREATE TRIGGER dbo.trgPanelistLogonCode_I
ON dbo.[PanelistLogonCode] FOR insert 
AS 
insert into audit.[PanelistLogonCode](
	 ,[LogonCode]
	 ,i.[LogonCode],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelistLogonCode_D
ON dbo.[PanelistLogonCode] FOR delete 
AS 
insert into audit.[PanelistLogonCode](
	 ,[LogonCode]
	 ,d.[LogonCode],'D' from deleted d