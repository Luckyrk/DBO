﻿CREATE TABLE [dbo].[MailMergeData] (
    [MailMergeDataId]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [ToEmail]                      NVARCHAR (200)  NULL,
	[FromEmail]                    NVARCHAR (200)  NULL,
    [Subject]                      NVARCHAR (200)  NULL,
    [EmailContent]                 NVARCHAR (MAX) NULL,
    [EmailSent]                    BIT             NOT NULL,
    [BusinessId]                   NVARCHAR (200)  NULL,
    [GPSUser]                      NVARCHAR (100)  NULL,
    [GPSUpdateTimestamp]           DATETIME        NULL,
    [CreationTimeStamp]            DATETIME        NULL,
    [Document_Id] BIGINT          NULL,
    CONSTRAINT [PK_dbo.MailMergeData] PRIMARY KEY CLUSTERED ([MailMergeDataId] ASC),
    CONSTRAINT [FK_dbo.MailMergeData_dbo.MailMergeDocument_Document_MailMergeDocumentId] FOREIGN KEY ([Document_Id]) REFERENCES [dbo].[MailMergeDocument] ([MailMergeDocumentId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Document_MailMergeDocumentId]
    ON [dbo].[MailMergeData]([Document_Id] ASC);


GO
CREATE TRIGGER dbo.trgMailMergeData_U 
ON dbo.[MailMergeData] FOR update 
AS 
insert into audit.[MailMergeData](
insert into audit.[MailMergeData](
GO
CREATE TRIGGER dbo.trgMailMergeData_I
ON dbo.[MailMergeData] FOR insert 
AS 
insert into audit.[MailMergeData](
GO
CREATE TRIGGER dbo.trgMailMergeData_D
ON dbo.[MailMergeData] FOR delete 
AS 
insert into audit.[MailMergeData](