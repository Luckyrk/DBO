CREATE TABLE [dbo].[GiftRewardType] (
    [GUIDReference]           UNIQUEIDENTIFIER NOT NULL,
    [GiftRewardTypeCode]      INT              NOT NULL,
    [GiftRewardValidFromDate] DATETIME         NULL,
    [GiftRewardCategoryTag]   NVARCHAR (10)    NULL,
    [GiftRewardCategory]      NVARCHAR (50)    NULL,
    [ValidToDate]             DATETIME         NULL,
    [TranslationGUID]         UNIQUEIDENTIFIER NULL,
    [GPSUser]                 NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]      DATETIME         NULL,
    [CreationTimeStamp]       DATETIME         NULL,
    [GPSUpdateReasonCode]     INT              NOT NULL,
    [GPSIsCurrent]            INT              NOT NULL,
    [GPSDataSourceCode]       NVARCHAR (3)     NULL,
    [GPSSystemCode]           NVARCHAR (50)    NULL,
    [Country_Id]              UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.GiftRewardType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.GiftRewardType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[GiftRewardType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgGiftRewardType_U 
ON dbo.[GiftRewardType] FOR update 
AS 
insert into audit.[GiftRewardType](	 [GUIDReference]	 ,[GiftRewardTypeCode]	 ,[GiftRewardValidFromDate]	 ,[GiftRewardCategoryTag]	 ,[GiftRewardCategory]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GiftRewardTypeCode]	 ,d.[GiftRewardValidFromDate]	 ,d.[GiftRewardCategoryTag]	 ,d.[GiftRewardCategory]	 ,d.[ValidToDate]	 ,d.[TranslationGUID]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateReasonCode]	 ,d.[GPSIsCurrent]	 ,d.[GPSDataSourceCode]	 ,d.[GPSSystemCode]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[GiftRewardType](	 [GUIDReference]	 ,[GiftRewardTypeCode]	 ,[GiftRewardValidFromDate]	 ,[GiftRewardCategoryTag]	 ,[GiftRewardCategory]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GiftRewardTypeCode]	 ,i.[GiftRewardValidFromDate]	 ,i.[GiftRewardCategoryTag]	 ,i.[GiftRewardCategory]	 ,i.[ValidToDate]	 ,i.[TranslationGUID]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateReasonCode]	 ,i.[GPSIsCurrent]	 ,i.[GPSDataSourceCode]	 ,i.[GPSSystemCode]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgGiftRewardType_I
ON dbo.[GiftRewardType] FOR insert 
AS 
insert into audit.[GiftRewardType](	 [GUIDReference]	 ,[GiftRewardTypeCode]	 ,[GiftRewardValidFromDate]	 ,[GiftRewardCategoryTag]	 ,[GiftRewardCategory]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GiftRewardTypeCode]	 ,i.[GiftRewardValidFromDate]	 ,i.[GiftRewardCategoryTag]	 ,i.[GiftRewardCategory]	 ,i.[ValidToDate]	 ,i.[TranslationGUID]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateReasonCode]	 ,i.[GPSIsCurrent]	 ,i.[GPSDataSourceCode]	 ,i.[GPSSystemCode]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgGiftRewardType_D
ON dbo.[GiftRewardType] FOR delete 
AS 
insert into audit.[GiftRewardType](	 [GUIDReference]	 ,[GiftRewardTypeCode]	 ,[GiftRewardValidFromDate]	 ,[GiftRewardCategoryTag]	 ,[GiftRewardCategory]	 ,[ValidToDate]	 ,[TranslationGUID]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GPSUpdateReasonCode]	 ,[GPSIsCurrent]	 ,[GPSDataSourceCode]	 ,[GPSSystemCode]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GiftRewardTypeCode]	 ,d.[GiftRewardValidFromDate]	 ,d.[GiftRewardCategoryTag]	 ,d.[GiftRewardCategory]	 ,d.[ValidToDate]	 ,d.[TranslationGUID]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateReasonCode]	 ,d.[GPSIsCurrent]	 ,d.[GPSDataSourceCode]	 ,d.[GPSSystemCode]	 ,d.[Country_Id],'D' from deleted d