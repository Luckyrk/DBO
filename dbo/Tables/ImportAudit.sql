CREATE TABLE [dbo].[ImportAudit] (
    [GUIDReference]       UNIQUEIDENTIFIER NOT NULL,
    [Error]               BIT              NOT NULL,
    [IsInvalid]           BIT              NOT NULL,
    [Message]             NVARCHAR (1000)  NULL,
    [Date]                DATETIME         NOT NULL,
    [SerializedRowData]   NVARCHAR (MAX)   NULL,
    [SerializedRowErrors] NVARCHAR (MAX)   NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [File_Id]             UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ImportAudit] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ImportAudit_dbo.ImportFile_File_Id] FOREIGN KEY ([File_Id]) REFERENCES [dbo].[ImportFile] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_File_Id]
    ON [dbo].[ImportAudit]([File_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportAudit_U 
ON dbo.[ImportAudit] FOR update 
AS 
insert into audit.[ImportAudit](	 [GUIDReference]	 ,[Error]	 ,[IsInvalid]	 ,[Message]	 ,[Date]	 ,[SerializedRowData]	 ,[SerializedRowErrors]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[File_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Error]	 ,d.[IsInvalid]	 ,d.[Message]	 ,d.[Date]	 ,d.[SerializedRowData]	 ,d.[SerializedRowErrors]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[File_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ImportAudit](	 [GUIDReference]	 ,[Error]	 ,[IsInvalid]	 ,[Message]	 ,[Date]	 ,[SerializedRowData]	 ,[SerializedRowErrors]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[File_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Error]	 ,i.[IsInvalid]	 ,i.[Message]	 ,i.[Date]	 ,i.[SerializedRowData]	 ,i.[SerializedRowErrors]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[File_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgImportAudit_I
ON dbo.[ImportAudit] FOR insert 
AS 
insert into audit.[ImportAudit](	 [GUIDReference]	 ,[Error]	 ,[IsInvalid]	 ,[Message]	 ,[Date]	 ,[SerializedRowData]	 ,[SerializedRowErrors]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[File_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Error]	 ,i.[IsInvalid]	 ,i.[Message]	 ,i.[Date]	 ,i.[SerializedRowData]	 ,i.[SerializedRowErrors]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[File_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgImportAudit_D
ON dbo.[ImportAudit] FOR delete 
AS 
insert into audit.[ImportAudit](	 [GUIDReference]	 ,[Error]	 ,[IsInvalid]	 ,[Message]	 ,[Date]	 ,[SerializedRowData]	 ,[SerializedRowErrors]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[File_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Error]	 ,d.[IsInvalid]	 ,d.[Message]	 ,d.[Date]	 ,d.[SerializedRowData]	 ,d.[SerializedRowErrors]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[File_Id],'D' from deleted d