CREATE TABLE [dbo].[SqlJob] (
    [Id]                 BIGINT           IDENTITY (1, 1) NOT NULL,
    [Code]               NVARCHAR (50)    NOT NULL,
    [IsActive]           BIT              NOT NULL,
    [SQLBusinessRuleID]  BIGINT           NOT NULL,
    [Description]        NVARCHAR (200)   NOT NULL,
    [CountryId]          UNIQUEIDENTIFIER NOT NULL,
    [CreationTimeStamp]  DATETIME         CONSTRAINT [DF_SqlJob_CreationTimeStamp] DEFAULT (getdate()) NOT NULL,
    [GPSUpdateTimestamp] DATETIME         CONSTRAINT [DF_SqlJob_GPSUpdateTimestamp] DEFAULT (getdate()) NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    CONSTRAINT [PK_SqlJob] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SqlBusinessRule_SQLBusinessRuleID] FOREIGN KEY ([SQLBusinessRuleID]) REFERENCES [dbo].[SqlBusinessRule] ([Id])
);



