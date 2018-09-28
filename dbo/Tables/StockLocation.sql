﻿CREATE TABLE [dbo].[StockLocation] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.StockLocation] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockLocation_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StockLocation]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockLocation_U 
ON dbo.[StockLocation] FOR update 
AS 
insert into audit.[StockLocation](
insert into audit.[StockLocation](
GO
CREATE TRIGGER dbo.trgStockLocation_I
ON dbo.[StockLocation] FOR insert 
AS 
insert into audit.[StockLocation](
GO
CREATE TRIGGER dbo.trgStockLocation_D
ON dbo.[StockLocation] FOR delete 
AS 
insert into audit.[StockLocation](