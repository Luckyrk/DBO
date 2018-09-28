CREATE TABLE [dbo].[SSISLog] (
    [EventID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [EventType]         VARCHAR (50)  NOT NULL,
    [CountryCode]       VARCHAR (10)  NULL,
    [ImportType]        VARCHAR (100) NULL,
    [PackageName]       VARCHAR (100) NOT NULL,
    [FileName]          VARCHAR (500) NULL,
    [TaskName]          VARCHAR (200) NOT NULL,
    [EventCode]         VARCHAR (20)  NULL,
    [EventDescription]  VARCHAR (MAX) NULL,
    [PackageDuration]   BIGINT        NULL,
    [ContainerDuration] BIGINT        NULL,
    [InsertCount]       BIGINT        NULL,
    [UpdateCount]       BIGINT        NULL,
    [DeleteCount]       BIGINT        NULL,
    [Host]              VARCHAR (50)  NULL,
    [LogDate]           DATETIME      CONSTRAINT [DF_SSISLog_LogDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__SSISLog__7944C8702FC40D47] PRIMARY KEY CLUSTERED ([EventID] ASC)
);



