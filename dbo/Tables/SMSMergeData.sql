CREATE TABLE [dbo].[SMSMergeData] (
    [SMSMergeDataId]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [PhoneId]            NVARCHAR (200) NULL,
    [Content]            NVARCHAR (MAX) NULL,
    [SMSSent]            BIT            NOT NULL,
    [BusinessId]         NVARCHAR (200) NULL,
    [GPSUser]            NVARCHAR (100) NULL,
    [GPSUpdateTimestamp] DATETIME       NULL,
    [CreationTimeStamp]  DATETIME       NULL,
    [Document_Id]        BIGINT         NULL,
    CONSTRAINT [PK_dbo.SMSMergeData] PRIMARY KEY CLUSTERED ([SMSMergeDataId] ASC),
    CONSTRAINT [FK_dbo.SMSMergeData_dbo.SMSMergeDocument_Document_SMSMergeDocumentId] FOREIGN KEY ([Document_Id]) REFERENCES [dbo].[MailMergeDocument] ([MailMergeDocumentId])
);

