﻿CREATE TABLE [dbo].[StockStateDefinitionHistory] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Location_Id]   UNIQUEIDENTIFIER NOT NULL,
    [StockItem_Id]  UNIQUEIDENTIFIER NOT NULL,
	[Panelist_Id]   UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockStateDefinitionHistory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockStateDefinitionHistory_dbo.StateDefinitionHistory_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[StateDefinitionHistory] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockStateDefinitionHistory_dbo.StockItem_StockItem_Id] FOREIGN KEY ([StockItem_Id]) REFERENCES [dbo].[StockItem] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockStateDefinitionHistory_dbo.StockLocation_Location_Id] FOREIGN KEY ([Location_Id]) REFERENCES [dbo].[StockLocation] ([GUIDReference]),
	CONSTRAINT [FK_dbo.StockStateDefinitionHistory_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference])
);


GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[StockStateDefinitionHistory]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Location_Id]
    ON [dbo].[StockStateDefinitionHistory]([Location_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StockItem_Id]
    ON [dbo].[StockStateDefinitionHistory]([StockItem_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockStateDefinitionHistory_U 
ON dbo.[StockStateDefinitionHistory] FOR update 
AS 
insert into audit.[StockStateDefinitionHistory](
insert into audit.[StockStateDefinitionHistory](
GO
CREATE TRIGGER dbo.trgStockStateDefinitionHistory_I
ON dbo.[StockStateDefinitionHistory] FOR insert 
AS 
insert into audit.[StockStateDefinitionHistory](
GO
CREATE TRIGGER dbo.trgStockStateDefinitionHistory_D
ON dbo.[StockStateDefinitionHistory] FOR delete 
AS 
insert into audit.[StockStateDefinitionHistory](