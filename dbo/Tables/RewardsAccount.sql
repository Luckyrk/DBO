CREATE TABLE [dbo].[RewardsAccount] (
    [RewardsAccountGUID]          UNIQUEIDENTIFIER NOT NULL,
    [DisplayableRewardsAccountNo] INT              NULL,
    [RewardsAccountName]          NVARCHAR (60)    NULL,
    [LastRewardsRedemptionDate]   DATETIME         NULL,
    [CreditPointsBalance]         INT              NULL,
    [ValidFromDate]               DATETIME         NULL,
    [ValidToDate]                 DATETIME         NULL,
    [TranslationGUID]             UNIQUEIDENTIFIER NULL,
    [GPSUser]                     NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]          DATETIME         NULL,
    [CreationTimeStamp]           DATETIME         NULL,
    [GPSUpdateReasonCode]         INT              NOT NULL,
    [GPSIsCurrent]                INT              NOT NULL,
    [GPSDataSourceCode]           NVARCHAR (3)     NULL,
    [GPSSystemCode]               NVARCHAR (50)    NULL,
    [Country_Id]                  UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.RewardsAccount] PRIMARY KEY CLUSTERED ([RewardsAccountGUID] ASC),
    CONSTRAINT [FK_dbo.RewardsAccount_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[RewardsAccount]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgRewardsAccount_U 
ON dbo.[RewardsAccount] FOR update 
AS 
insert into audit.[RewardsAccount](	 [RewardsAccountGUID]	 ,[DisplayableRewardsAccountNo]	 ,[RewardsAccountName]	 ,[LastRewardsRedemptionDate]	 ,[CreditPointsBalance]	 ,[ValidFromDate]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[RewardsAccountGUID]	 ,d.[DisplayableRewardsAccountNo]	 ,d.[RewardsAccountName]	 ,d.[LastRewardsRedemptionDate]	 ,d.[CreditPointsBalance]	 ,d.[ValidFromDate]	 ,d.[ValidToDate]	 ,d.[TranslationGUID]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateReasonCode]	 ,d.[GPSIsCurrent]	 ,d.[GPSDataSourceCode]	 ,d.[GPSSystemCode]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.RewardsAccountGUID = i.RewardsAccountGUID 
insert into audit.[RewardsAccount](	 [RewardsAccountGUID]	 ,[DisplayableRewardsAccountNo]	 ,[RewardsAccountName]	 ,[LastRewardsRedemptionDate]	 ,[CreditPointsBalance]	 ,[ValidFromDate]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[RewardsAccountGUID]	 ,i.[DisplayableRewardsAccountNo]	 ,i.[RewardsAccountName]	 ,i.[LastRewardsRedemptionDate]	 ,i.[CreditPointsBalance]	 ,i.[ValidFromDate]	 ,i.[ValidToDate]	 ,i.[TranslationGUID]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateReasonCode]	 ,i.[GPSIsCurrent]	 ,i.[GPSDataSourceCode]	 ,i.[GPSSystemCode]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.RewardsAccountGUID = i.RewardsAccountGUID
GO
CREATE TRIGGER dbo.trgRewardsAccount_I
ON dbo.[RewardsAccount] FOR insert 
AS 
insert into audit.[RewardsAccount](	 [RewardsAccountGUID]	 ,[DisplayableRewardsAccountNo]	 ,[RewardsAccountName]	 ,[LastRewardsRedemptionDate]	 ,[CreditPointsBalance]	 ,[ValidFromDate]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[RewardsAccountGUID]	 ,i.[DisplayableRewardsAccountNo]	 ,i.[RewardsAccountName]	 ,i.[LastRewardsRedemptionDate]	 ,i.[CreditPointsBalance]	 ,i.[ValidFromDate]	 ,i.[ValidToDate]	 ,i.[TranslationGUID]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateReasonCode]	 ,i.[GPSIsCurrent]	 ,i.[GPSDataSourceCode]	 ,i.[GPSSystemCode]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRewardsAccount_D
ON dbo.[RewardsAccount] FOR delete 
AS 
insert into audit.[RewardsAccount](	 [RewardsAccountGUID]	 ,[DisplayableRewardsAccountNo]	 ,[RewardsAccountName]	 ,[LastRewardsRedemptionDate]	 ,[CreditPointsBalance]	 ,[ValidFromDate]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[RewardsAccountGUID]	 ,d.[DisplayableRewardsAccountNo]	 ,d.[RewardsAccountName]	 ,d.[LastRewardsRedemptionDate]	 ,d.[CreditPointsBalance]	 ,d.[ValidFromDate]	 ,d.[ValidToDate]	 ,d.[TranslationGUID]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateReasonCode]	 ,d.[GPSIsCurrent]	 ,d.[GPSDataSourceCode]	 ,d.[GPSSystemCode]	 ,d.[Country_Id],'D' from deleted d