CREATE TABLE [dbo].[FileImportErrorLog] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [FileName]         VARCHAR (200)  NOT NULL,
    [CountryCode]      VARCHAR (10)   NULL,
    [PanelCode]        VARCHAR (50)   NULL,
    [ImportType]       VARCHAR (100)  NOT NULL,
    [ErrorSource]      VARCHAR (50)   NULL,
    [ErrorCode]        VARCHAR (10)   NULL,
    [ErrorDescription] NVARCHAR (MAX) NULL,
    [ErrorDate]        DATETIME       NULL,
    [JobId]            VARCHAR (200)  NULL
);

