CREATE TABLE [dbo].[IncentivePoint] (
    [GUIDReference]        UNIQUEIDENTIFIER NOT NULL,
    [Code]                 INT              NOT NULL,
    [Value]                INT              NOT NULL,
    [ValidFrom]            DATETIME         NULL,
    [ValidTo]              DATETIME         NULL,
    [HasUpdateableValue]   BIT              NULL,
    [HasAllPanels]         BIT              NULL,
    [Type_Id]              UNIQUEIDENTIFIER NOT NULL,
    [Description_Id]       UNIQUEIDENTIFIER NULL,
    [GPSUser]              NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]   DATETIME         NULL,
    [CreationTimeStamp]    DATETIME         NULL,
    [RewardCode]           INT              NULL,
    [GiftPrice]            FLOAT (53)       NULL,
    [CostPrice]            DECIMAL (18, 2)  NULL,
    [RewardSource]         INT              NULL,
    [SupplierId]           UNIQUEIDENTIFIER NULL,
    [HasStockControl]      BIT              NULL,
    [StockLevel]           INT              NULL,
    [Type]                 NVARCHAR (100)   NOT NULL,
    [Minimum]              INT              NULL,
    [Maximum]              INT              NULL,
    [DealtByCommunication] BIT              DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.IncentivePoint] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IncentivePoint_dbo.IncentivePointAccountEntryType_Type_Id] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[IncentivePointAccountEntryType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentivePoint_dbo.IncentiveSupplier_SupplierId] FOREIGN KEY ([SupplierId]) REFERENCES [dbo].[IncentiveSupplier] ([IncentiveSupplierId]),
    CONSTRAINT [FK_dbo.IncentivePoint_dbo.Respondent_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Respondent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentivePoint_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniquePointName] UNIQUE NONCLUSTERED ([Type_Id] ASC, [Description_Id] ASC)
);







GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[IncentivePoint]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Type_Id]
    ON [dbo].[IncentivePoint]([Type_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[IncentivePoint]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SupplierId]
    ON [dbo].[IncentivePoint]([SupplierId] ASC);

GO
CREATE TRIGGER dbo.setMaximumRewardCode ON [dbo].[IncentivePoint]
INSTEAD OF INSERT
AS
BEGIN

	declare @PointId uniqueidentifier;
	declare @RewardCode int;

	DECLARE PointsCursor CURSOR FOR SELECT GUIDReference, RewardCode FROM  INSERTED

	OPEN PointsCursor   
	FETCH NEXT FROM PointsCursor INTO @PointId, @RewardCode

	WHILE @@FETCH_STATUS = 0   
		BEGIN  
			IF(@RewardCode IS NOT NULL AND EXISTS (select * from IncentivePoint Where RewardCode = @RewardCode))
			BEGIN 
				SET @RewardCode = (select MAX(RewardCode) + 1 from [IncentivePoint])
			END
			
			INSERT INTO[dbo].[IncentivePoint]([GUIDReference],[Code],[Value],[ValidFrom],[ValidTo],[HasUpdateableValue],[HasAllPanels],[Type_Id],
			[Description_Id],[GPSUser],[GPSUpdateTimestamp],[CreationTimeStamp],[RewardCode],[GiftPrice],[CostPrice],[RewardSource],[SupplierId],
			[HasStockControl],[StockLevel],[Type],[Minimum],[Maximum],[DealtByCommunication])
			SELECT [GUIDReference],[Code],[Value],[ValidFrom],[ValidTo],[HasUpdateableValue],[HasAllPanels],[Type_Id],
			[Description_Id],[GPSUser],[GPSUpdateTimestamp],[CreationTimeStamp], @RewardCode,[GiftPrice],[CostPrice],[RewardSource],[SupplierId],
			[HasStockControl],[StockLevel],[Type],[Minimum],[Maximum],[DealtByCommunication]
			FROM INSERTED WHERE [GUIDReference] = @PointId

			FETCH NEXT FROM PointsCursor INTO @PointId, @RewardCode
		END  

	CLOSE PointsCursor   
	DEALLOCATE PointsCursor
END

GO
CREATE TRIGGER dbo.trgIncentivePoint_U 
ON dbo.[IncentivePoint] FOR update 
AS 
insert into audit.[IncentivePoint](	 [GUIDReference]	 ,[Code]	 ,[Value]	 ,[ValidFrom]	 ,[ValidTo]	 ,[HasUpdateableValue]	 ,[HasAllPanels]	 ,[Type_Id]	 ,[Description_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RewardCode]	 ,[GiftPrice]	 ,[CostPrice]	 ,[RewardSource]	 ,[SupplierId]	 ,[HasStockControl]	 ,[StockLevel]	 ,[Type]	 ,[Minimum]	 ,[Maximum]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[Value]	 ,d.[ValidFrom]	 ,d.[ValidTo]	 ,d.[HasUpdateableValue]	 ,d.[HasAllPanels]	 ,d.[Type_Id]	 ,d.[Description_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[RewardCode]	 ,d.[GiftPrice]	 ,d.[CostPrice]	 ,d.[RewardSource]	 ,d.[SupplierId]	 ,d.[HasStockControl]	 ,d.[StockLevel]	 ,d.[Type]	 ,d.[Minimum]	 ,d.[Maximum],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[IncentivePoint](	 [GUIDReference]	 ,[Code]	 ,[Value]	 ,[ValidFrom]	 ,[ValidTo]	 ,[HasUpdateableValue]	 ,[HasAllPanels]	 ,[Type_Id]	 ,[Description_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RewardCode]	 ,[GiftPrice]	 ,[CostPrice]	 ,[RewardSource]	 ,[SupplierId]	 ,[HasStockControl]	 ,[StockLevel]	 ,[Type]	 ,[Minimum]	 ,[Maximum]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[Value]	 ,i.[ValidFrom]	 ,i.[ValidTo]	 ,i.[HasUpdateableValue]	 ,i.[HasAllPanels]	 ,i.[Type_Id]	 ,i.[Description_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[RewardCode]	 ,i.[GiftPrice]	 ,i.[CostPrice]	 ,i.[RewardSource]	 ,i.[SupplierId]	 ,i.[HasStockControl]	 ,i.[StockLevel]	 ,i.[Type]	 ,i.[Minimum]	 ,i.[Maximum],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgIncentivePoint_I
ON dbo.[IncentivePoint] FOR insert 
AS 
insert into audit.[IncentivePoint](	 [GUIDReference]	 ,[Code]	 ,[Value]	 ,[ValidFrom]	 ,[ValidTo]	 ,[HasUpdateableValue]	 ,[HasAllPanels]	 ,[Type_Id]	 ,[Description_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RewardCode]	 ,[GiftPrice]	 ,[CostPrice]	 ,[RewardSource]	 ,[SupplierId]	 ,[HasStockControl]	 ,[StockLevel]	 ,[Type]	 ,[Minimum]	 ,[Maximum]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[Value]	 ,i.[ValidFrom]	 ,i.[ValidTo]	 ,i.[HasUpdateableValue]	 ,i.[HasAllPanels]	 ,i.[Type_Id]	 ,i.[Description_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[RewardCode]	 ,i.[GiftPrice]	 ,i.[CostPrice]	 ,i.[RewardSource]	 ,i.[SupplierId]	 ,i.[HasStockControl]	 ,i.[StockLevel]	 ,i.[Type]	 ,i.[Minimum]	 ,i.[Maximum],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentivePoint_D
ON dbo.[IncentivePoint] FOR delete 
AS 
insert into audit.[IncentivePoint](	 [GUIDReference]	 ,[Code]	 ,[Value]	 ,[ValidFrom]	 ,[ValidTo]	 ,[HasUpdateableValue]	 ,[HasAllPanels]	 ,[Type_Id]	 ,[Description_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RewardCode]	 ,[GiftPrice]	 ,[CostPrice]	 ,[RewardSource]	 ,[SupplierId]	 ,[HasStockControl]	 ,[StockLevel]	 ,[Type]	 ,[Minimum]	 ,[Maximum]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[Value]	 ,d.[ValidFrom]	 ,d.[ValidTo]	 ,d.[HasUpdateableValue]	 ,d.[HasAllPanels]	 ,d.[Type_Id]	 ,d.[Description_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[RewardCode]	 ,d.[GiftPrice]	 ,d.[CostPrice]	 ,d.[RewardSource]	 ,d.[SupplierId]	 ,d.[HasStockControl]	 ,d.[StockLevel]	 ,d.[Type]	 ,d.[Minimum]	 ,d.[Maximum],'D' from deleted d
GO
CREATE STATISTICS [_dta_stat_1085298976_1_20]
    ON [dbo].[IncentivePoint]([GUIDReference], [Type]);

