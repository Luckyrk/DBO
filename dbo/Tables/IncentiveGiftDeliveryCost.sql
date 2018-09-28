﻿CREATE TABLE [dbo].[IncentiveGiftDeliveryCost] (
    [IncentiveGiftDeliveryCostId] UNIQUEIDENTIFIER NOT NULL,
    [ValidFromDate]               DATETIME         NULL,
    [DeliveryCostZone]            INT              NULL,
    [DeliveryMethodCode]          INT              NOT NULL,
    [DeliverCost]                 MONEY            NULL,
    [CurrencyCodeIS03A]           NVARCHAR (3)     NULL,
    [ValidToDate]                 DATETIME         NULL,
    [GPSUser]                     NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]          DATETIME         NULL,
    [CreationTimeStamp]           DATETIME         NULL,
    [UpdateReasonCode]            INT              NULL,
    [GPSIsCurrent]                INT              NULL,
    [GPSDataSourceCode]           NVARCHAR (3)     NULL,
    [GPSSystemCode]               NVARCHAR (10)    NULL,
    [Country_Id]                  UNIQUEIDENTIFIER NOT NULL,
    [Gift_Id]                     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.IncentiveGiftDeliveryCost] PRIMARY KEY CLUSTERED ([IncentiveGiftDeliveryCostId] ASC),
    CONSTRAINT [FK_dbo.IncentiveGiftDeliveryCost_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IncentiveGiftDeliveryCost_dbo.IncentiveGift_Gift_Id] FOREIGN KEY ([Gift_Id]) REFERENCES [dbo].[IncentiveGift] ([IncentiveGiftId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IncentiveGiftDeliveryCost]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Gift_Id]
    ON [dbo].[IncentiveGiftDeliveryCost]([Gift_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveGiftDeliveryCost_U 
ON dbo.[IncentiveGiftDeliveryCost] FOR update 
AS 
insert into audit.[IncentiveGiftDeliveryCost](
insert into audit.[IncentiveGiftDeliveryCost](
GO
CREATE TRIGGER dbo.trgIncentiveGiftDeliveryCost_I
ON dbo.[IncentiveGiftDeliveryCost] FOR insert 
AS 
insert into audit.[IncentiveGiftDeliveryCost](
GO
CREATE TRIGGER dbo.trgIncentiveGiftDeliveryCost_D
ON dbo.[IncentiveGiftDeliveryCost] FOR delete 
AS 
insert into audit.[IncentiveGiftDeliveryCost](