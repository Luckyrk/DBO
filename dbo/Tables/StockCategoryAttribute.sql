CREATE TABLE [dbo].[StockCategoryAttribute] (
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
insert into audit.[StockCategoryAttribute](	 [StockCategory_Id]	 ,[Attribute_Id]	 ,AuditOperation) select 	 d.[StockCategory_Id]	 ,d.[Attribute_Id],'O'  from 	 deleted d join inserted i on d.Attribute_Id = i.Attribute_Id	 and d.StockCategory_Id = i.StockCategory_Id 
insert into audit.[StockCategoryAttribute](	 [StockCategory_Id]	 ,[Attribute_Id]	 ,AuditOperation) select 	 i.[StockCategory_Id]	 ,i.[Attribute_Id],'N'  from 	 deleted d join inserted i on d.Attribute_Id = i.Attribute_Id	 and d.StockCategory_Id = i.StockCategory_Id
GO
CREATE TRIGGER dbo.trgStockCategoryAttribute_I
ON dbo.[StockCategoryAttribute] FOR insert 
AS 
insert into audit.[StockCategoryAttribute](	 [StockCategory_Id]	 ,[Attribute_Id]	 ,AuditOperation) select 	 i.[StockCategory_Id]	 ,i.[Attribute_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStockCategoryAttribute_D
ON dbo.[StockCategoryAttribute] FOR delete 
AS 
insert into audit.[StockCategoryAttribute](	 [StockCategory_Id]	 ,[Attribute_Id]	 ,AuditOperation) select 	 d.[StockCategory_Id]	 ,d.[Attribute_Id],'D' from deleted d