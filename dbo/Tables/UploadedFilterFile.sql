CREATE TABLE [dbo].[UploadedFilterFile] (
    [Id]       UNIQUEIDENTIFIER NOT NULL,
    [Date]     DATETIME         NOT NULL,
    [DataType] NVARCHAR (200)   NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.UploadedFilterFile] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgUploadedFilterFile_U 
ON dbo.[UploadedFilterFile] FOR update 
AS 
insert into audit.[UploadedFilterFile](	 [Id]	 ,[Date]	 ,[DataType]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Date]	 ,d.[DataType],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[UploadedFilterFile](	 [Id]	 ,[Date]	 ,[DataType]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Date]	 ,i.[DataType],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgUploadedFilterFile_I
ON dbo.[UploadedFilterFile] FOR insert 
AS 
insert into audit.[UploadedFilterFile](	 [Id]	 ,[Date]	 ,[DataType]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Date]	 ,i.[DataType],'I' from inserted i
GO
CREATE TRIGGER dbo.trgUploadedFilterFile_D
ON dbo.[UploadedFilterFile] FOR delete 
AS 
insert into audit.[UploadedFilterFile](	 [Id]	 ,[Date]	 ,[DataType]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Date]	 ,d.[DataType],'D' from deleted d