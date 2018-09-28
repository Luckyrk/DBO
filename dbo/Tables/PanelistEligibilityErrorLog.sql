CREATE TABLE [dbo].[PanelistEligibilityErrorLog] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [FileName]         VARCHAR (100)  NULL,
    [PanelCode]        VARCHAR (20)   NULL,
    [ErrorSource]      VARCHAR (50)   NULL,
    [ErrorCode]        VARCHAR (10)   NULL,
    [ErrorDescription] NVARCHAR (400) NULL,
    [ErrorDate]        DATETIME       NULL
);

