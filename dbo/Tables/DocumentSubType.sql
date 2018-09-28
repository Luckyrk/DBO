CREATE TABLE [dbo].[DocumentSubType] (
    [DocumentSubTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [DocumentTypeId]    BIGINT         NOT NULL,
    [Description]       NVARCHAR (200) NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DocumentSubType] PRIMARY KEY CLUSTERED ([DocumentSubTypeId] ASC),
    CONSTRAINT [FK_dbo.DocumentSubType_dbo.DocumentType_DocumentTypeId] FOREIGN KEY ([DocumentTypeId]) REFERENCES [dbo].[DocumentType] ([DocumentTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_DocumentTypeId]
    ON [dbo].[DocumentSubType]([DocumentTypeId] ASC);


GO
CREATE TRIGGER dbo.trgDocumentSubType_U 
ON dbo.[DocumentSubType] FOR update 
AS 
insert into audit.[DocumentSubType](	 [DocumentSubTypeId]	 ,[DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[DocumentSubTypeId]	 ,d.[DocumentTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.DocumentSubTypeId = i.DocumentSubTypeId 
insert into audit.[DocumentSubType](	 [DocumentSubTypeId]	 ,[DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[DocumentSubTypeId]	 ,i.[DocumentTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.DocumentSubTypeId = i.DocumentSubTypeId
GO
CREATE TRIGGER dbo.trgDocumentSubType_I
ON dbo.[DocumentSubType] FOR insert 
AS 
insert into audit.[DocumentSubType](	 [DocumentSubTypeId]	 ,[DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[DocumentSubTypeId]	 ,i.[DocumentTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDocumentSubType_D
ON dbo.[DocumentSubType] FOR delete 
AS 
insert into audit.[DocumentSubType](	 [DocumentSubTypeId]	 ,[DocumentTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[DocumentSubTypeId]	 ,d.[DocumentTypeId]	 ,d.[Description],'D' from deleted d