﻿CREATE TABLE [dbo].[StockCategoryAttribute] (
    [StockCategory_Id] UNIQUEIDENTIFIER NOT NULL,
    [Attribute_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockCategoryAttribute] PRIMARY KEY CLUSTERED ([StockCategory_Id] ASC, [Attribute_Id] ASC),
    CONSTRAINT [FK_dbo.StockCategoryAttribute_dbo.Attribute_Attribute_Id] FOREIGN KEY ([Attribute_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.StockCategoryAttribute_dbo.StockCategory_StockCategory_Id] FOREIGN KEY ([StockCategory_Id]) REFERENCES [dbo].[StockCategory] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_StockCategory_Id]
    ON [dbo].[StockCategoryAttribute]([StockCategory_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Attribute_Id]
    ON [dbo].[StockCategoryAttribute]([Attribute_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockCategoryAttribute_U 
ON dbo.[StockCategoryAttribute] FOR update 
AS 
insert into audit.[StockCategoryAttribute](
insert into audit.[StockCategoryAttribute](
GO
CREATE TRIGGER dbo.trgStockCategoryAttribute_I
ON dbo.[StockCategoryAttribute] FOR insert 
AS 
insert into audit.[StockCategoryAttribute](
GO
CREATE TRIGGER dbo.trgStockCategoryAttribute_D
ON dbo.[StockCategoryAttribute] FOR delete 
AS 
insert into audit.[StockCategoryAttribute](