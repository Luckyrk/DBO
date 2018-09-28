﻿CREATE TABLE [dbo].[StockKitHistory] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [From_Id]            UNIQUEIDENTIFIER NULL,
    [To_Id]              UNIQUEIDENTIFIER NOT NULL,
    [Reason_Id]          UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Panelist_Id]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.StockKitHistory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.StockKitHistory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StockKitHistory_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockKitHistory_dbo.ReasonForStockKitChange_Reason_Id] FOREIGN KEY ([Reason_Id]) REFERENCES [dbo].[ReasonForStockKitChange] ([Id]),
    CONSTRAINT [FK_dbo.StockKitHistory_dbo.StockKit_From_Id] FOREIGN KEY ([From_Id]) REFERENCES [dbo].[StockKit] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockKitHistory_dbo.StockKit_To_Id] FOREIGN KEY ([To_Id]) REFERENCES [dbo].[StockKit] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_From_Id]
    ON [dbo].[StockKitHistory]([From_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_To_Id]
    ON [dbo].[StockKitHistory]([To_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Reason_Id]
    ON [dbo].[StockKitHistory]([Reason_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StockKitHistory]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[StockKitHistory]([Panelist_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockKitHistory_U 
ON dbo.[StockKitHistory] FOR update 
AS 
insert into audit.[StockKitHistory](
insert into audit.[StockKitHistory](
GO
CREATE TRIGGER dbo.trgStockKitHistory_I
ON dbo.[StockKitHistory] FOR insert 
AS 
insert into audit.[StockKitHistory](
GO
CREATE TRIGGER dbo.trgStockKitHistory_D
ON dbo.[StockKitHistory] FOR delete 
AS 
insert into audit.[StockKitHistory](