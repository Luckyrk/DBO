CREATE TABLE [dbo].[RewardDeliveryType] (
    [RewardDeliveryTypeId]  UNIQUEIDENTIFIER NOT NULL,
    [Code]                  INT              NOT NULL,
    [Translation_Id]        UNIQUEIDENTIFIER NOT NULL,
    [AffectsAccountBalance] BIT              NOT NULL,
    [IsFirstDelivery]       BIT              NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RewardDeliveryType] PRIMARY KEY CLUSTERED ([RewardDeliveryTypeId] ASC),
    CONSTRAINT [FK_RewardDeliveryType_RewardDeliveryType] FOREIGN KEY ([RewardDeliveryTypeId]) REFERENCES [dbo].[RewardDeliveryType] ([RewardDeliveryTypeId]),
    CONSTRAINT [FK_RewardDeliveryType_Translation] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);


GO
CREATE TRIGGER dbo.trgRewardDeliveryType_U 
ON dbo.[RewardDeliveryType] FOR update 
AS 
insert into audit.[RewardDeliveryType](	 [RewardDeliveryTypeId]	 ,[Code]	 ,[Translation_Id]	 ,[AffectsAccountBalance]	 ,[IsFirstDelivery]	 ,AuditOperation) select 	 d.[RewardDeliveryTypeId]	 ,d.[Code]	 ,d.[Translation_Id]	 ,d.[AffectsAccountBalance]	 ,d.[IsFirstDelivery],'O'  from 	 deleted d join inserted i on d.RewardDeliveryTypeId = i.RewardDeliveryTypeId 
insert into audit.[RewardDeliveryType](	 [RewardDeliveryTypeId]	 ,[Code]	 ,[Translation_Id]	 ,[AffectsAccountBalance]	 ,[IsFirstDelivery]	 ,AuditOperation) select 	 i.[RewardDeliveryTypeId]	 ,i.[Code]	 ,i.[Translation_Id]	 ,i.[AffectsAccountBalance]	 ,i.[IsFirstDelivery],'N'  from 	 deleted d join inserted i on d.RewardDeliveryTypeId = i.RewardDeliveryTypeId
GO
CREATE TRIGGER dbo.trgRewardDeliveryType_I
ON dbo.[RewardDeliveryType] FOR insert 
AS 
insert into audit.[RewardDeliveryType](	 [RewardDeliveryTypeId]	 ,[Code]	 ,[Translation_Id]	 ,[AffectsAccountBalance]	 ,[IsFirstDelivery]	 ,AuditOperation) select 	 i.[RewardDeliveryTypeId]	 ,i.[Code]	 ,i.[Translation_Id]	 ,i.[AffectsAccountBalance]	 ,i.[IsFirstDelivery],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRewardDeliveryType_D
ON dbo.[RewardDeliveryType] FOR delete 
AS 
insert into audit.[RewardDeliveryType](	 [RewardDeliveryTypeId]	 ,[Code]	 ,[Translation_Id]	 ,[AffectsAccountBalance]	 ,[IsFirstDelivery]	 ,AuditOperation) select 	 d.[RewardDeliveryTypeId]	 ,d.[Code]	 ,d.[Translation_Id]	 ,d.[AffectsAccountBalance]	 ,d.[IsFirstDelivery],'D' from deleted d