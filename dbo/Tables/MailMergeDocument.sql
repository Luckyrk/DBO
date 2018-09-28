﻿CREATE TABLE [dbo].[MailMergeDocument] (
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
insert into audit.[MailMergeDocument](
insert into audit.[MailMergeDocument](
GO
CREATE TRIGGER dbo.trgMailMergeDocument_I
ON dbo.[MailMergeDocument] FOR insert 
AS 
insert into audit.[MailMergeDocument](
	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgMailMergeDocument_D
ON dbo.[MailMergeDocument] FOR delete 
AS 
insert into audit.[MailMergeDocument](