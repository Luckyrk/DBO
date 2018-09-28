CREATE TABLE [dbo].[DocumentType] (
    [DocumentTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]    NVARCHAR (200) NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DocumentType] PRIMARY KEY CLUSTERED ([DocumentTypeId] ASC)
);




GO
CREATE TRIGGER dbo.trgDocumentType_U 
ON dbo.[DocumentType] FOR update 
AS 
insert into audit.[DocumentType](	 [DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[DocumentTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.DocumentTypeId = i.DocumentTypeId 
insert into audit.[DocumentType](	 [DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[DocumentTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.DocumentTypeId = i.DocumentTypeId
GO
CREATE TRIGGER dbo.trgDocumentType_I
ON dbo.[DocumentType] FOR insert 
AS 
insert into audit.[DocumentType](	 [DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[DocumentTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDocumentType_D
ON dbo.[DocumentType] FOR delete 
AS 
insert into audit.[DocumentType](	 [DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[DocumentTypeId]	 ,d.[Description],'D' from deleted d