﻿CREATE TABLE [dbo].[StockKit] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
	[Code]				 INT NOT NULL DEFAULT 0,
    [Name]               NVARCHAR (50)    NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
	[IsActive]           BIT NOT NULL DEFAULT 1,      
    CONSTRAINT [PK_dbo.StockKit] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockKit_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StockKit]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockKit_U 
ON dbo.[StockKit] FOR update 
AS 
insert into audit.[StockKit](
insert into audit.[StockKit](
GO
CREATE TRIGGER dbo.trgStockKit_I
ON dbo.[StockKit] FOR insert 
AS 
insert into audit.[StockKit](
GO
CREATE TRIGGER dbo.trgStockKit_D
ON dbo.[StockKit] FOR delete 
AS 
insert into audit.[StockKit](