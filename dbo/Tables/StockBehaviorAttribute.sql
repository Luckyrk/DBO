﻿CREATE TABLE [dbo].[StockBehaviorAttribute] (
    [StockBehavior_Id] UNIQUEIDENTIFIER NOT NULL,
    [Attribute_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockBehaviorAttribute] PRIMARY KEY CLUSTERED ([StockBehavior_Id] ASC, [Attribute_Id] ASC),
    CONSTRAINT [FK_dbo.StockBehaviorAttribute_dbo.Attribute_Attribute_Id] FOREIGN KEY ([Attribute_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.StockBehaviorAttribute_dbo.StockBehavior_StockBehavior_Id] FOREIGN KEY ([StockBehavior_Id]) REFERENCES [dbo].[StockBehavior] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_StockBehavior_Id]
    ON [dbo].[StockBehaviorAttribute]([StockBehavior_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Attribute_Id]
    ON [dbo].[StockBehaviorAttribute]([Attribute_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockBehaviorAttribute_U 
ON dbo.[StockBehaviorAttribute] FOR update 
AS 
insert into audit.[StockBehaviorAttribute](
insert into audit.[StockBehaviorAttribute](
GO
CREATE TRIGGER dbo.trgStockBehaviorAttribute_I
ON dbo.[StockBehaviorAttribute] FOR insert 
AS 
insert into audit.[StockBehaviorAttribute](
GO
CREATE TRIGGER dbo.trgStockBehaviorAttribute_D
ON dbo.[StockBehaviorAttribute] FOR delete 
AS 
insert into audit.[StockBehaviorAttribute](