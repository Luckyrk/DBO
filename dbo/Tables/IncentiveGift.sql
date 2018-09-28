﻿CREATE TABLE [dbo].[IncentiveGift] (
    [IncentiveGiftId]    UNIQUEIDENTIFIER NOT NULL,
    [DisplayableGiftNo]  INT              NULL,
    [GiftDescription]    NVARCHAR (50)    NULL,
    [PointsRequired]     INT              NOT NULL,
    [DateGiftWithdrawn]  DATETIME         NULL,
    [GiftWeight]         INT              NULL,
    [GiftPrice]          MONEY            NULL,
    [CurrencyCodeISO3A]  NVARCHAR (3)     NULL,
    [GiftValidFromDate]  DATETIME         NULL,
    [TranslationGUID]    UNIQUEIDENTIFIER NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [UpdateReasonCode]   NVARCHAR (50)    NULL,
    [GPSIsCurrent]       NVARCHAR (20)    NULL,
    [GPSDataSourceCode]  NVARCHAR (3)     NULL,
    [GPSSystemCode]      NVARCHAR (10)    NULL,
    [GPSCountryGUID]     UNIQUEIDENTIFIER NULL,
    [GiftRewardType_Id]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.IncentiveGift] PRIMARY KEY CLUSTERED ([IncentiveGiftId] ASC),
    CONSTRAINT [FK_dbo.IncentiveGift_dbo.Country_GPSCountryGUID] FOREIGN KEY ([GPSCountryGUID]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IncentiveGift_dbo.GiftRewardType_GiftRewardType_Id] FOREIGN KEY ([GiftRewardType_Id]) REFERENCES [dbo].[GiftRewardType] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_GPSCountryGUID]
    ON [dbo].[IncentiveGift]([GPSCountryGUID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_GiftRewardType_Id]
    ON [dbo].[IncentiveGift]([GiftRewardType_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveGift_U 
ON dbo.[IncentiveGift] FOR update 
AS 
insert into audit.[IncentiveGift](
insert into audit.[IncentiveGift](
GO
CREATE TRIGGER dbo.trgIncentiveGift_I
ON dbo.[IncentiveGift] FOR insert 
AS 
insert into audit.[IncentiveGift](
GO
CREATE TRIGGER dbo.trgIncentiveGift_D
ON dbo.[IncentiveGift] FOR delete 
AS 
insert into audit.[IncentiveGift](