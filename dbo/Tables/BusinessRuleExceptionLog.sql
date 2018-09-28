CREATE TABLE [dbo].[BusinessRuleExceptionLog] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [BusinessId]      NVARCHAR (60)    NOT NULL,
    [PanelCode]       INT              NULL,
    [CountryCode]     NCHAR (4)        NOT NULL,
    [BusinessRule]    NVARCHAR (1000)  NOT NULL,
    [ApplicationName] NCHAR (200)      NOT NULL,
    [Version]         INT              NOT NULL,
    [ExceptionDetail] VARCHAR (MAX)    NULL,
    [CreateTimeStamp] DATETIME         NOT NULL,
    [GPSUser]         NCHAR (100)      NOT NULL,
    [JobAuditId]      BIGINT           NOT NULL,
    CONSTRAINT [PK_BusinessRuleExceptionLog] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BusinessRuleExceptionLog_SqlJobAudit] FOREIGN KEY ([JobAuditId]) REFERENCES [dbo].[SqlJobAudit] ([JobAuditId])
);

