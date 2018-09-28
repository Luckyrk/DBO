CREATE TABLE [dbo].[PanelistEligibilityConfig] (
    [PanelCode]   INT            NOT NULL,
    [PanelName]   NVARCHAR (20)  NULL,
    [FilePath]    NVARCHAR (200) NULL,
    [ImportFlag]  TINYINT        NULL,
    [CountryCode] CHAR (10)      NULL
);

