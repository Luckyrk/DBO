﻿CREATE TABLE [dbo].[OrderItem] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [StockItemId]        UNIQUEIDENTIFIER NULL,
    [Quantity]           INT              NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [Order_Id]           BIGINT           NULL,
    [Order_Country_Id]   UNIQUEIDENTIFIER NULL,
    [StockType_Id]       UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.OrderItem] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.OrderItem_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.OrderItem_dbo.Order_Order_Id_Order_Country_Id] FOREIGN KEY ([Order_Id], [Order_Country_Id]) REFERENCES [dbo].[Order] ([OrderId], [Country_Id]),
    CONSTRAINT [FK_dbo.OrderItem_dbo.StockItem_StockItemId] FOREIGN KEY ([StockItemId]) REFERENCES [dbo].[StockItem] ([GUIDReference]),
    CONSTRAINT [FK_dbo.OrderItem_dbo.StockType_StockType_Id] FOREIGN KEY ([StockType_Id]) REFERENCES [dbo].[StockType] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_StockItemId]
    ON [dbo].[OrderItem]([StockItemId] ASC);


GO



GO
CREATE NONCLUSTERED INDEX [IX_StockType_Id]
    ON [dbo].[OrderItem]([StockType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[OrderItem]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Order_Id_Order_Country_Id]
    ON [dbo].[OrderItem]([Order_Id] ASC, [Order_Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgOrderItem_U 
ON dbo.[OrderItem] FOR update 
AS 
insert into audit.[OrderItem](
insert into audit.[OrderItem](
GO
CREATE TRIGGER dbo.trgOrderItem_I
ON dbo.[OrderItem] FOR insert 
AS 
insert into audit.[OrderItem](
GO
CREATE TRIGGER dbo.trgOrderItem_D
ON dbo.[OrderItem] FOR delete 
AS 
insert into audit.[OrderItem](