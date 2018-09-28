CREATE TABLE [dbo].[MailMergeError] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [BusinessId]        NVARCHAR (100) NULL,
    [CountryCode]       NVARCHAR (3)   NULL,
    [TemplateId]        BIGINT         NULL,
    [CommunicationType] VARCHAR (10)   NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    [ErrorMessage]      NVARCHAR (MAX) NULL
);

