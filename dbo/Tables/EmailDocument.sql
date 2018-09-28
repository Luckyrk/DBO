CREATE TABLE [dbo].[EmailDocument] (
    [DocumentId]         BIGINT         NOT NULL,
    [EmailDate]          DATETIME       NOT NULL,
    [Subject]            NVARCHAR (400) NOT NULL,
    [From]               NVARCHAR (200) NOT NULL,
    [To]                 NVARCHAR (200) NOT NULL,
    [EmailContent]       NVARCHAR (MAX) NOT NULL,
    [Unusable]           BIT            NULL,
    [GPSUser]            NVARCHAR (50)  NOT NULL,
    [GPSUpdateTimestamp] DATETIME       NULL,
    [CreationTimeStamp]  DATETIME       NULL,
    CONSTRAINT [PK_dbo.EmailDocument] PRIMARY KEY CLUSTERED ([DocumentId] ASC),
    CONSTRAINT [FK_dbo.EmailDocument_dbo.Document_DocumentId] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[Document] ([DocumentId])
);






GO
CREATE NONCLUSTERED INDEX [IX_DocumentId]
    ON [dbo].[EmailDocument]([DocumentId] ASC);

GO
CREATE NONCLUSTERED INDEX IX_From ON [dbo].[EmailDocument] ([From])


GO
CREATE TRIGGER dbo.trgEmailDocument_U 
ON dbo.[EmailDocument] FOR update 
AS 
insert into audit.[EmailDocument](
	 [DocumentId]
	 ,[EmailDate]
	 ,[Subject]
	 ,[From]
	 ,[To]
	 ,[EmailContent]
	 ,[Unusable]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 d.[DocumentId]
	 ,d.[EmailDate]
	 ,d.[Subject]
	 ,d.[From]
	 ,d.[To]
	 ,d.[EmailContent]
	 ,d.[Unusable]
	 ,d.[GPSUser]
	 ,d.[GPSUpdateTimestamp]
	 ,d.[CreationTimeStamp],'O'  from 
	 deleted d join inserted i on d.DocumentId = i.DocumentId 
insert into audit.[EmailDocument](
	 [DocumentId]
	 ,[EmailDate]
	 ,[Subject]
	 ,[From]
	 ,[To]
	 ,[EmailContent]
	 ,[Unusable]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 i.[DocumentId]
	 ,i.[EmailDate]
	 ,i.[Subject]
	 ,i.[From]
	 ,i.[To]
	 ,i.[EmailContent]
	 ,i.[Unusable]
	 ,i.[GPSUser]
	 ,i.[GPSUpdateTimestamp]
	 ,i.[CreationTimeStamp],'N'  from 
	 deleted d join inserted i on d.DocumentId = i.DocumentId
GO
CREATE TRIGGER dbo.trgEmailDocument_I
ON dbo.[EmailDocument] FOR insert 
AS 
insert into audit.[EmailDocument](
	 [DocumentId]
	 ,[EmailDate]
	 ,[Subject]
	 ,[From]
	 ,[To]
	 ,[EmailContent]
	 ,[Unusable]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 i.[DocumentId]
	 ,i.[EmailDate]
	 ,i.[Subject]
	 ,i.[From]
	 ,i.[To]
	 ,i.[EmailContent]
	 ,i.[Unusable]
	 ,i.[GPSUser]
	 ,i.[GPSUpdateTimestamp]
	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgEmailDocument_D
ON dbo.[EmailDocument] FOR delete 
AS 
insert into audit.[EmailDocument](
	 [DocumentId]
	 ,[EmailDate]
	 ,[Subject]
	 ,[From]
	 ,[To]
	 ,[EmailContent]
	 ,[Unusable]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,AuditOperation) select 
	 d.[DocumentId]
	 ,d.[EmailDate]
	 ,d.[Subject]
	 ,d.[From]
	 ,d.[To]
	 ,d.[EmailContent]
	 ,d.[Unusable]
	 ,d.[GPSUser]
	 ,d.[GPSUpdateTimestamp]
	 ,d.[CreationTimeStamp],'D' from deleted d