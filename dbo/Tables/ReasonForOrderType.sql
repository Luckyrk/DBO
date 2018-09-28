﻿CREATE TABLE [dbo].[ReasonForOrderType] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Code]               INT              NOT NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [OrderType_Id]       UNIQUEIDENTIFIER NULL,	
    [StockKitOrderType_Id]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.ReasonForOrderType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.OrderType_OrderType_Id] FOREIGN KEY ([OrderType_Id]) REFERENCES [dbo].[OrderType] ([Id]),	
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.OrderType_StockKitOrderType_Id] FOREIGN KEY ([StockKitOrderType_Id]) REFERENCES [dbo].[StockKitOrderType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ReasonForOrderType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ReasonForOrderType]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ReasonForOrderType]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderType_Id]
    ON [dbo].[ReasonForOrderType]([OrderType_Id] ASC);


GO
CREATE TRIGGER dbo.trgReasonForOrderType_U 
ON dbo.[ReasonForOrderType] FOR update 
AS 
insert into audit.[ReasonForOrderType](
insert into audit.[ReasonForOrderType](
GO
CREATE TRIGGER dbo.trgReasonForOrderType_I
ON dbo.[ReasonForOrderType] FOR insert 
AS 
insert into audit.[ReasonForOrderType](
	 ,i.[StockKitOrderType_Id]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgReasonForOrderType_D
ON dbo.[ReasonForOrderType] FOR delete 
AS 
insert into audit.[ReasonForOrderType](