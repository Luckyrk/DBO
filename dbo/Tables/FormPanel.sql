CREATE TABLE [dbo].[FormPanel] (
    [Form_Id]  UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.FormPanel] PRIMARY KEY CLUSTERED ([Form_Id] ASC, [Panel_Id] ASC),
    CONSTRAINT [FK_dbo.FormPanel_dbo.Form_Form_Id] FOREIGN KEY ([Form_Id]) REFERENCES [dbo].[Form] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.FormPanel_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Form_Id]
    ON [dbo].[FormPanel]([Form_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[FormPanel]([Panel_Id] ASC);


GO
CREATE TRIGGER dbo.trgFormPanel_U 
ON dbo.[FormPanel] FOR update 
AS 
insert into audit.[FormPanel](	 [Form_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[Form_Id]	 ,d.[Panel_Id],'O'  from 	 deleted d join inserted i on d.Form_Id = i.Form_Id	 and d.Panel_Id = i.Panel_Id 
insert into audit.[FormPanel](	 [Form_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[Form_Id]	 ,i.[Panel_Id],'N'  from 	 deleted d join inserted i on d.Form_Id = i.Form_Id	 and d.Panel_Id = i.Panel_Id
GO
CREATE TRIGGER dbo.trgFormPanel_I
ON dbo.[FormPanel] FOR insert 
AS 
insert into audit.[FormPanel](	 [Form_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[Form_Id]	 ,i.[Panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgFormPanel_D
ON dbo.[FormPanel] FOR delete 
AS 
insert into audit.[FormPanel](	 [Form_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[Form_Id]	 ,d.[Panel_Id],'D' from deleted d