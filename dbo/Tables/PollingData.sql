CREATE TABLE [dbo].[PollingData] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [BusinessId]   NVARCHAR (30) NOT NULL,
    [PanelCode]    INT           NOT NULL,
    [LastPollDate] DATETIME      NOT NULL
);

