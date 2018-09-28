CREATE TABLE [dbo].[StockKitOrderType] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    
	[StockKit_Id]        UNIQUEIDENTIFIER NOT NULL,
	[OrderType_Id]       UNIQUEIDENTIFIER NOT NULL,
	
    CONSTRAINT [PK_dbo.StockKitOrderType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),	
	CONSTRAINT [FK_dbo.StockKitOrderType_dbo.StockKit_Id] FOREIGN KEY ([StockKit_Id]) REFERENCES [dbo].[StockKit] ([GuidReference]),
	CONSTRAINT [FK_dbo.StockKitOrderType_dbo.OrderType_Id] FOREIGN KEY ([OrderType_Id]) REFERENCES [dbo].[OrderType] ([Id])
);

GO
CREATE TRIGGER dbo.trgStockKitOrderType_D
ON dbo.[StockKitOrderType] FOR delete 
AS 
INSERT INTO audit.[StockKitOrderType](	[GUIDReference]     ,
	[GPSUser]           ,
	[GPSUpdateTimestamp],
	[CreationTimeStamp] ,	AuditOperation) SELECT 	d.[GUIDReference]     ,
	d.[GPSUser]           ,
	d.[GPSUpdateTimestamp],
	d.[CreationTimeStamp] , 
	'D' FROM deleted d