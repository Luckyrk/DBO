CREATE TYPE [dbo].[DiaryEntryImport] AS TABLE (
    [Rownumber]       INT            NULL,
    [Year]            NVARCHAR (100) NULL,
    [Period]          NVARCHAR (100) NULL,
    [Week]            NVARCHAR (100) NULL,
    [PanelCode]       NVARCHAR (100) NULL,
    [BusinessId]      VARCHAR (50)   NULL,
    [IncentiveCode]   NVARCHAR (100) NULL,
    [IncentiveReason] NVARCHAR (400) NULL,
    [Points]          NVARCHAR (100) NULL,
    [ReceivedDate]    NVARCHAR (100) NULL,
    [Source]          VARCHAR (100)  NULL,
    [FullRow]         NVARCHAR (MAX) NULL,
    [GACode]          NVARCHAR (100) NULL);

