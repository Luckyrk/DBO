CREATE TABLE [dbo].[StockItemHistory] (
    [StockItemHistoryID] INT              IDENTITY (1, 1) NOT NULL,
    [StockItemID]        UNIQUEIDENTIFIER NOT NULL,
    [DateOfChange]       DATETIME         NOT NULL,
    [PanelistID]         UNIQUEIDENTIFIER NULL,
    [StockLocationId]    UNIQUEIDENTIFIER NULL,
    [IsChangeOfLocation] BIT              NOT NULL,
    [IsChangeOfPanelist] BIT              NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockItemHistoryID] PRIMARY KEY CLUSTERED ([StockItemHistoryID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_dbo.StockItemHistory_dbo.Panelist_PanelistID] FOREIGN KEY ([PanelistID]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockItemHistory_dbo.StockItem_StockItemID] FOREIGN KEY ([StockItemID]) REFERENCES [dbo].[StockItem] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockItemHistory_dbo.StockLocation_StockLocationID] FOREIGN KEY ([StockLocationId]) REFERENCES [dbo].[StockLocation] ([GUIDReference])
);


GO
