CREATE TABLE [dbo].[SqlBusinessRule] (
    [Id]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [SqlCommand]          NVARCHAR (MAX) NOT NULL,
    [IsOneToManySql]      BIT            NOT NULL,
    [RuleApplicationName] NVARCHAR (100) NOT NULL,
    [RuleName]            NVARCHAR (100) NOT NULL,
    [RuleEntity]          NVARCHAR (100) NOT NULL,
    [RuleVersion]         INT            NOT NULL,
    [CreateTimeStamp]     DATETIME       CONSTRAINT [DF_SqlBusinessRule_CreateTimeStamp] DEFAULT (getdate()) NOT NULL,
    [GPSUpdateTimeStamp]  DATETIME       CONSTRAINT [DF_SqlBusinessRule_GPSUpdateTimeStamp] DEFAULT (getdate()) NOT NULL,
    [GPSUser]             NVARCHAR (50)  NULL,
    [JobType]             NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_SqlBusinessRule] PRIMARY KEY CLUSTERED ([Id] ASC)
);



