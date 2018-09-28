﻿CREATE TABLE [dbo].[GenericStockLocation] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Location]      NVARCHAR (50)    NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.GenericStockLocation] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.GenericStockLocation_dbo.StockLocation_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[StockLocation] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[GenericStockLocation]([GUIDReference] ASC);


GO
CREATE TRIGGER dbo.trgGenericStockLocation_U 
ON dbo.[GenericStockLocation] FOR update 
AS 
insert into audit.[GenericStockLocation](
insert into audit.[GenericStockLocation](
GO
CREATE TRIGGER dbo.trgGenericStockLocation_I
ON dbo.[GenericStockLocation] FOR insert 
AS 
insert into audit.[GenericStockLocation](
GO
CREATE TRIGGER dbo.trgGenericStockLocation_D
ON dbo.[GenericStockLocation] FOR delete 
AS 
insert into audit.[GenericStockLocation](