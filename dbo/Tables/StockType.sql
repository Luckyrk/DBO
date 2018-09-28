﻿CREATE TABLE [dbo].[StockType] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Category_Id]        UNIQUEIDENTIFIER NULL,
    [Behavior_Id]        UNIQUEIDENTIFIER NULL,
    [Code]               NVARCHAR (30)    NULL,
    [CountryId]          UNIQUEIDENTIFIER NOT NULL,
    [Name]               NVARCHAR (50)    NULL,
    [Quantity]           INT              NULL,
    [WarningLimit]       INT              NULL,
	[ReportsId]		     UNIQUEIDENTIFIER NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StockType_dbo.Respondent_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Respondent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockType_dbo.StockBehavior_Behavior_Id] FOREIGN KEY ([Behavior_Id]) REFERENCES [dbo].[StockBehavior] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StockType_dbo.StockCategory_Category_Id] FOREIGN KEY ([Category_Id]) REFERENCES [dbo].[StockCategory] ([GUIDReference]),
    CONSTRAINT [UniqueStockTypeCode] UNIQUE NONCLUSTERED ([Code] ASC, [CountryId] ASC),
	CONSTRAINT [FK_dbo.StockType_dbo.Reports_ReportsId] FOREIGN KEY ([ReportsId]) REFERENCES [dbo].[Reports] (ReportsId),

);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[StockType]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Category_Id]
    ON [dbo].[StockType]([Category_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Behavior_Id]
    ON [dbo].[StockType]([Behavior_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockType_U 
ON dbo.[StockType] FOR update 
AS 
insert into audit.[StockType](
insert into audit.[StockType](
GO
CREATE TRIGGER dbo.trgStockType_I
ON dbo.[StockType] FOR insert 
AS 
insert into audit.[StockType](
GO
CREATE TRIGGER dbo.trgStockType_D
ON dbo.[StockType] FOR delete 
AS 
insert into audit.[StockType](