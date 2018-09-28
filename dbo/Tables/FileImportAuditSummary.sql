CREATE TABLE [dbo].[FileImportAuditSummary] (
    [AuditId]        BIGINT           IDENTITY (1, 1) NOT NULL,
    [ImportType]     VARCHAR (100)    NULL,
    [CountryCode]    NVARCHAR (20)    NULL,
    [PanelID]        UNIQUEIDENTIFIER NULL,
    [PanelName]      NVARCHAR (256)   NULL,
    [Filename]       NVARCHAR (500)   NULL,
    [FileImportDate] DATETIME         NULL,
    [GPSUser]        NVARCHAR (50)    NULL,
    [TotalRows]      BIGINT           NULL,
    [PassedRows]     BIGINT           NULL,
    [Status]         VARCHAR (20)     NULL,
    [Comments]       VARCHAR (400)    NULL,
    [JobId]          VARCHAR (200)    NULL
);

