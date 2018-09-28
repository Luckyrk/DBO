CREATE TABLE [dbo].[SqlJobRuleActionAudit] (
    [RuleActionAuditId]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [JobAuditId]         BIGINT        NOT NULL,
    [RuleActionName]     NVARCHAR (50) NOT NULL,
    [BusinessId]         NVARCHAR (50) NOT NULL,
    [PanelCode]          INT           NULL,
    [CountryCode]        NVARCHAR (2)  NOT NULL,
    [EntityName]         NVARCHAR (50) NOT NULL,
    [CorrelationToken]   NVARCHAR (50) NOT NULL,
    [GPSUser]            NVARCHAR (50) NULL,
    [GPSUpdateTimestamp] DATETIME      NULL,
    [CreationTimeStamp]  DATETIME      NULL,
    CONSTRAINT [PK_SqlJobRuleActionAudit] PRIMARY KEY CLUSTERED ([RuleActionAuditId] ASC),
    CONSTRAINT [FK_SqlJobRuleActionAudit_SqlJobAudit] FOREIGN KEY ([JobAuditId]) REFERENCES [dbo].[SqlJobAudit] ([JobAuditId])
);

GO
CREATE NONCLUSTERED INDEX [IX_Correlation]
ON [dbo].[SqlJobRuleActionAudit] ([CorrelationToken])