﻿CREATE TABLE [dbo].[StockPanelistLocation] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Panelist_Id]   UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockPanelistLocation] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockPanelistLocation_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockPanelistLocation_dbo.StockLocation_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[StockLocation] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[StockPanelistLocation]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[StockPanelistLocation]([Panelist_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockPanelistLocation_U 
ON dbo.[StockPanelistLocation] FOR update 
AS 
insert into audit.[StockPanelistLocation](
insert into audit.[StockPanelistLocation](
GO
CREATE TRIGGER dbo.trgStockPanelistLocation_I
ON dbo.[StockPanelistLocation] FOR insert 
AS 
insert into audit.[StockPanelistLocation](
GO
CREATE TRIGGER dbo.trgStockPanelistLocation_D
ON dbo.[StockPanelistLocation] FOR delete 
AS 
insert into audit.[StockPanelistLocation](