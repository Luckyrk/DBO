CREATE TABLE [dbo].[OrderTypeStockKitItem] (
	[GUIDReference]			UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]				NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]	DATETIME         NULL,
    [CreationTimeStamp]		DATETIME         NULL,
	[StockKitOrderType_Id]  UNIQUEIDENTIFIER NOT NULL,
	[StockKitItem_Id]		UNIQUEIDENTIFIER NOT NULL,
	[SelectedByDefault]		BIT NOT NULL,
	
    CONSTRAINT [PK_dbo.OrderTypeStockKitItem] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
	
    CONSTRAINT [FK_dbo.OrderType_dbo.StockKitOrderType_Id] FOREIGN KEY ([StockKitOrderType_Id]) REFERENCES [dbo].[StockKitOrderType] ([GUIDReference]),
	CONSTRAINT [FK_dbo.OrderType_dbo.StockKitItem_Id] FOREIGN KEY ([StockKitItem_Id]) REFERENCES [dbo].[StockKitItem] ([GUIDReference])
);


GO
CREATE TRIGGER dbo.trgOrderTypeStockKitItem_D
ON dbo.[OrderTypeStockKitItem] FOR DELETE 
AS 
INSERT INTO audit.[OrderTypeStockKitItem](	[GUIDReference]			,
	[GPSUser]				,
	[GPSUpdateTimestamp]	,
	[CreationTimeStamp]		,
	[StockKitOrderType_Id]  ,
	[StockKitItem_Id]		,	[SelectedByDefault]		,	AuditOperation)SELECT	d.[GUIDReference]			,
	d.[GPSUser]					,
	d.[GPSUpdateTimestamp]		,
	d.[CreationTimeStamp]		,
	d.[StockKitOrderType_Id]	,
	d.[StockKitItem_Id]			,	d.[SelectedByDefault]		,	'D' FROM deleted d