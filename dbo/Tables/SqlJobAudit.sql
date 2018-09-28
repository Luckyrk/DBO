CREATE TABLE [dbo].[SqlJobAudit] (
    [JobAuditId]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [JobId]              BIGINT         NOT NULL,
    [JobRunDate]         DATETIME       NOT NULL,
    [StatusCode]         INT            NOT NULL,
    [EllapsedTime]       TIME (7)       NULL,
    [Error_Info]         NVARCHAR (MAX) NULL,
    [GPSUser]            NVARCHAR (50)  NULL,
    [GPSUpdateTimestamp] DATETIME       NULL,
    [CreationTimeStamp]  DATETIME       NULL,
    CONSTRAINT [PK_SqlJobAudit] PRIMARY KEY CLUSTERED ([JobAuditId] ASC),
    CONSTRAINT [FK_SqlJobAudit_SqlJob] FOREIGN KEY ([JobId]) REFERENCES [dbo].[SqlJob] ([Id]),
    CONSTRAINT [FK_SqlJobAudit_StatusCode] FOREIGN KEY ([StatusCode]) REFERENCES [dbo].[StatusCode] ([Code])
);



