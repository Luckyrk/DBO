CREATE TABLE [dbo].[MailMergeDocument] (
    [MailMergeDocumentId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocumentName]        NVARCHAR (500)   NOT NULL,
    [Status]              NVARCHAR (100)   NOT NULL,
    [Comments]            NVARCHAR (500)   NULL,
    [GPSUser]             NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [Country_id]          UNIQUEIDENTIFIER NULL,	
    [Type]				  NVARCHAR (50)	   NULL,
    CONSTRAINT [PK_dbo.MailMergeDocument] PRIMARY KEY CLUSTERED ([MailMergeDocumentId] ASC),
    FOREIGN KEY ([Country_id]) REFERENCES [dbo].[Country] ([CountryId])
);








GO
CREATE TRIGGER dbo.trgMailMergeDocument_U 
ON dbo.[MailMergeDocument] FOR update 
AS 
insert into audit.[MailMergeDocument](	 [MailMergeDocumentId]	 ,[DocumentName]	 ,[Status]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_id]	 ,[Type]	 ,AuditOperation) select 	 d.[MailMergeDocumentId]	 ,d.[DocumentName]	 ,d.[Status]	 ,d.[Comments]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.MailMergeDocumentId = i.MailMergeDocumentId 
insert into audit.[MailMergeDocument](	 [MailMergeDocumentId]	 ,[DocumentName]	 ,[Status]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_id]	 ,[Type]	 ,AuditOperation) select 	 i.[MailMergeDocumentId]	 ,i.[DocumentName]	 ,i.[Status]	 ,i.[Comments]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.MailMergeDocumentId = i.MailMergeDocumentId
GO
CREATE TRIGGER dbo.trgMailMergeDocument_I
ON dbo.[MailMergeDocument] FOR insert 
AS 
insert into audit.[MailMergeDocument](	 [MailMergeDocumentId]	 ,[DocumentName]	 ,[Status]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_id]	 ,[Type]	 ,AuditOperation) select 	 i.[MailMergeDocumentId]	 ,i.[DocumentName]	 ,i.[Status]	 ,i.[Comments]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_id]
	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgMailMergeDocument_D
ON dbo.[MailMergeDocument] FOR delete 
AS 
insert into audit.[MailMergeDocument](	 [MailMergeDocumentId]	 ,[DocumentName]	 ,[Status]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_id]	 ,[Type]	 ,AuditOperation) select 	 d.[MailMergeDocumentId]	 ,d.[DocumentName]	 ,d.[Status]	 ,d.[Comments]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_id]	 ,d.[Type],'D' from deleted d