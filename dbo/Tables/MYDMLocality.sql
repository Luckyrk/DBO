CREATE TABLE [dbo].[MYDMLocality] (
    [LocalityID]          NVARCHAR (20) NOT NULL,
    [DMID]                NVARCHAR (20) NOT NULL,
    [LocalityDescription] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LocalityID] PRIMARY KEY CLUSTERED ([LocalityID] ASC)
);

