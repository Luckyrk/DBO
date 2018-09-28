CREATE TABLE [dbo].[FormPage] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Number]             INT              NOT NULL,
	[Translation_Id]     UNIQUEIDENTIFIER NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Form_Id]            UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.FormPage] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.FormPage_dbo.Form_Form_Id] FOREIGN KEY ([Form_Id]) REFERENCES [dbo].[Form] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Form_Id]
    ON [dbo].[FormPage]([Form_Id] ASC);


GO
CREATE TRIGGER dbo.trgFormPage_U 
ON dbo.[FormPage] FOR update 
AS 
insert into audit.[FormPage](	 [Id]	 ,[Number]	 ,[Translation_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Form_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Number]	 ,d.[Translation_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Form_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[FormPage](	 [Id]	 ,[Number]	 ,[Translation_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Form_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Number]	 ,i.[Translation_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Form_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgFormPage_I
ON dbo.[FormPage] FOR insert 
AS 
insert into audit.[FormPage](	 [Id]	 ,[Number]	 ,[Translation_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Form_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Number]	 ,i.[Translation_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Form_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgFormPage_D
ON dbo.[FormPage] FOR delete 
AS 
insert into audit.[FormPage](	 [Id]	 ,[Number]	 ,[Translation_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Form_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Number]	 ,d.[Translation_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Form_Id],'D' from deleted d