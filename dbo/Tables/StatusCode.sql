CREATE TABLE [dbo].[StatusCode] (
    [Status] NVARCHAR (50) NOT NULL,
    [Code]   INT           NOT NULL,
    CONSTRAINT [PK_StatusCode] PRIMARY KEY CLUSTERED ([Code] ASC)
);

