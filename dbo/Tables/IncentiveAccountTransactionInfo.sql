CREATE TABLE [dbo].[IncentiveAccountTransactionInfo] (
    [IncentiveAccountTransactionInfoId] UNIQUEIDENTIFIER NOT NULL,
    [Ammount]                           INT              NOT NULL,
    [GPSUser]                           NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp]                DATETIME         NOT NULL,
    [CreationTimeStamp]                 DATETIME         NULL,
    [GiftPrice]                         FLOAT (53)       NULL,
    [Discriminator]                     NVARCHAR (128)   NOT NULL,
    [Point_Id]                          UNIQUEIDENTIFIER NOT NULL,
    [RewardDeliveryType_Id]             UNIQUEIDENTIFIER NULL,
	[Country_Id]						UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.IncentiveAccountTransactionInfo] PRIMARY KEY CLUSTERED ([IncentiveAccountTransactionInfoId] ASC),
    CONSTRAINT [FK_dbo.IncentiveAccountTransactionInfo_dbo.IncentivePoint_Point_Id] FOREIGN KEY ([Point_Id]) REFERENCES [dbo].[IncentivePoint] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentiveAccountTransactionInfo_dbo.RewardDeliveryType_RewardDeliveryType_Id] FOREIGN KEY ([RewardDeliveryType_Id]) REFERENCES [dbo].[RewardDeliveryType] ([RewardDeliveryTypeId])
);








GO
CREATE NONCLUSTERED INDEX [IX_Point_Id]
    ON [dbo].[IncentiveAccountTransactionInfo]([Point_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveAccountTransactionInfo_U 
ON dbo.[IncentiveAccountTransactionInfo] FOR update 
AS 
insert into audit.[IncentiveAccountTransactionInfo](	 [IncentiveAccountTransactionInfoId]	 ,[Ammount]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GiftPrice]	 ,[Discriminator]	 ,[Point_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveAccountTransactionInfoId]	 ,d.[Ammount]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[GiftPrice]	 ,d.[Discriminator]	 ,d.[Point_Id],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.IncentiveAccountTransactionInfoId = i.IncentiveAccountTransactionInfoId 
insert into audit.[IncentiveAccountTransactionInfo](	 [IncentiveAccountTransactionInfoId]	 ,[Ammount]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GiftPrice]	 ,[Discriminator]	 ,[Point_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveAccountTransactionInfoId]	 ,i.[Ammount]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[GiftPrice]	 ,i.[Discriminator]	 ,i.[Point_Id],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.IncentiveAccountTransactionInfoId = i.IncentiveAccountTransactionInfoId
GO
CREATE TRIGGER dbo.trgIncentiveAccountTransactionInfo_I
ON dbo.[IncentiveAccountTransactionInfo] FOR insert 
AS 
insert into audit.[IncentiveAccountTransactionInfo](	 [IncentiveAccountTransactionInfoId]	 ,[Ammount]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GiftPrice]	 ,[Discriminator]	 ,[Point_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveAccountTransactionInfoId]	 ,i.[Ammount]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[GiftPrice]	 ,i.[Discriminator]	 ,i.[Point_Id],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentiveAccountTransactionInfo_D
ON dbo.[IncentiveAccountTransactionInfo] FOR delete 
AS 
insert into audit.[IncentiveAccountTransactionInfo](	 [IncentiveAccountTransactionInfoId]	 ,[Ammount]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[GiftPrice]	 ,[Discriminator]	 ,[Point_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveAccountTransactionInfoId]	 ,d.[Ammount]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[GiftPrice]	 ,d.[Discriminator]	 ,d.[Point_Id],d.[Country_Id],'D' from deleted d