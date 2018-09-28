CREATE TABLE [dbo].[RewardsTransaction] (
    [RewardTransactionGUID]      UNIQUEIDENTIFIER NOT NULL,
    [PointsAwardedRedeemed]      DECIMAL (18)     NULL,
    [RewardTransactionTimestamp] DATETIME         NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    [UpdateReasonCode]           NVARCHAR (50)    NULL,
    [GPSIsCurrent]               NVARCHAR (20)    NULL,
    [GPSDataSourceCode]          NVARCHAR (3)     NULL,
    [GPSSystemCode]              NVARCHAR (50)    NULL,
    [PointsChangeReasonCode]     INT              NOT NULL,
    [GiftGUID_Id]                UNIQUEIDENTIFIER NULL,
    [Country_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [RewardsAccount_Id]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.RewardsTransaction] PRIMARY KEY CLUSTERED ([RewardTransactionGUID] ASC),
    CONSTRAINT [FK_dbo.RewardsTransaction_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.RewardsTransaction_dbo.IncentiveGift_GiftGUID_Id] FOREIGN KEY ([GiftGUID_Id]) REFERENCES [dbo].[IncentiveGift] ([IncentiveGiftId]),
    CONSTRAINT [FK_dbo.RewardsTransaction_dbo.RewardsAccount_RewardsAccount_Id] FOREIGN KEY ([RewardsAccount_Id]) REFERENCES [dbo].[RewardsAccount] ([RewardsAccountGUID])
);






GO
CREATE NONCLUSTERED INDEX [IX_GiftGUID_Id]
    ON [dbo].[RewardsTransaction]([GiftGUID_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[RewardsTransaction]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RewardsAccount_Id]
    ON [dbo].[RewardsTransaction]([RewardsAccount_Id] ASC);


GO
CREATE TRIGGER dbo.trgRewardsTransaction_U 
ON dbo.[RewardsTransaction] FOR update 
AS 
insert into audit.[RewardsTransaction](	 [RewardTransactionGUID]	 ,[PointsAwardedRedeemed]	 ,[RewardTransactionTimestamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[UpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[PointsChangeReasonCode]	 ,[GiftGUID_Id]	 ,[Country_Id]	 ,[RewardsAccount_Id]	 ,AuditOperation) select 	 d.[RewardTransactionGUID]	 ,d.[PointsAwardedRedeemed]	 ,d.[RewardTransactionTimestamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[UpdateReasonCode]	 ,d.[GPSIsCurrent]	 ,d.[GPSDataSourceCode]	 ,d.[GPSSystemCode]	 ,d.[PointsChangeReasonCode]	 ,d.[GiftGUID_Id]	 ,d.[Country_Id]	 ,d.[RewardsAccount_Id],'O'  from 	 deleted d join inserted i on d.RewardTransactionGUID = i.RewardTransactionGUID 
insert into audit.[RewardsTransaction](	 [RewardTransactionGUID]	 ,[PointsAwardedRedeemed]	 ,[RewardTransactionTimestamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[UpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[PointsChangeReasonCode]	 ,[GiftGUID_Id]	 ,[Country_Id]	 ,[RewardsAccount_Id]	 ,AuditOperation) select 	 i.[RewardTransactionGUID]	 ,i.[PointsAwardedRedeemed]	 ,i.[RewardTransactionTimestamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[UpdateReasonCode]	 ,i.[GPSIsCurrent]	 ,i.[GPSDataSourceCode]	 ,i.[GPSSystemCode]	 ,i.[PointsChangeReasonCode]	 ,i.[GiftGUID_Id]	 ,i.[Country_Id]	 ,i.[RewardsAccount_Id],'N'  from 	 deleted d join inserted i on d.RewardTransactionGUID = i.RewardTransactionGUID
GO
CREATE TRIGGER dbo.trgRewardsTransaction_I
ON dbo.[RewardsTransaction] FOR insert 
AS 
insert into audit.[RewardsTransaction](	 [RewardTransactionGUID]	 ,[PointsAwardedRedeemed]	 ,[RewardTransactionTimestamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[UpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[PointsChangeReasonCode]	 ,[GiftGUID_Id]	 ,[Country_Id]	 ,[RewardsAccount_Id]	 ,AuditOperation) select 	 i.[RewardTransactionGUID]	 ,i.[PointsAwardedRedeemed]	 ,i.[RewardTransactionTimestamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[UpdateReasonCode]	 ,i.[GPSIsCurrent]	 ,i.[GPSDataSourceCode]	 ,i.[GPSSystemCode]	 ,i.[PointsChangeReasonCode]	 ,i.[GiftGUID_Id]	 ,i.[Country_Id]	 ,i.[RewardsAccount_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRewardsTransaction_D
ON dbo.[RewardsTransaction] FOR delete 
AS 
insert into audit.[RewardsTransaction](	 [RewardTransactionGUID]	 ,[PointsAwardedRedeemed]	 ,[RewardTransactionTimestamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[UpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[PointsChangeReasonCode]	 ,[GiftGUID_Id]	 ,[Country_Id]	 ,[RewardsAccount_Id]	 ,AuditOperation) select 	 d.[RewardTransactionGUID]	 ,d.[PointsAwardedRedeemed]	 ,d.[RewardTransactionTimestamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[UpdateReasonCode]	 ,d.[GPSIsCurrent]	 ,d.[GPSDataSourceCode]	 ,d.[GPSSystemCode]	 ,d.[PointsChangeReasonCode]	 ,d.[GiftGUID_Id]	 ,d.[Country_Id]	 ,d.[RewardsAccount_Id],'D' from deleted d