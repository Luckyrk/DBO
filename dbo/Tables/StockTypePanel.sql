CREATE TABLE [dbo].[StockTypePanel] (
    [StockType_Id] UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockTypePanel] PRIMARY KEY CLUSTERED ([StockType_Id] ASC, [Panel_Id] ASC),
    CONSTRAINT [FK_dbo.StockTypePanel_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.StockTypePanel_dbo.StockType_StockType_Id] FOREIGN KEY ([StockType_Id]) REFERENCES [dbo].[StockType] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_StockType_Id]
    ON [dbo].[StockTypePanel]([StockType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[StockTypePanel]([Panel_Id] ASC);


GO
CREATE TRIGGER dbo.trgStockTypePanel_U 
ON dbo.[StockTypePanel] FOR update 
AS 
insert into audit.[StockTypePanel](	 [StockType_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[StockType_Id]	 ,d.[Panel_Id],'O'  from 	 deleted d join inserted i on d.Panel_Id = i.Panel_Id	 and d.StockType_Id = i.StockType_Id 
insert into audit.[StockTypePanel](	 [StockType_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[StockType_Id]	 ,i.[Panel_Id],'N'  from 	 deleted d join inserted i on d.Panel_Id = i.Panel_Id	 and d.StockType_Id = i.StockType_Id
GO
CREATE TRIGGER dbo.trgStockTypePanel_I
ON dbo.[StockTypePanel] FOR insert 
AS 
insert into audit.[StockTypePanel](	 [StockType_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[StockType_Id]	 ,i.[Panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStockTypePanel_D
ON dbo.[StockTypePanel] FOR delete 
AS 
insert into audit.[StockTypePanel](	 [StockType_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[StockType_Id]	 ,d.[Panel_Id],'D' from deleted d