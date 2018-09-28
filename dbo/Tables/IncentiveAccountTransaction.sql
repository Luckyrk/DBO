CREATE TABLE [dbo].[IncentiveAccountTransaction] (
    [IncentiveAccountTransactionId] UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]                  DATETIME         NOT NULL,
    [SynchronisationDate]           DATETIME         NULL,
    [TransactionDate]               DATETIME         NOT NULL,
    [Comments]                      NVARCHAR (500)   NULL,
    [Balance]                       INT              NOT NULL,
    [GPSUser]                       NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp]            DATETIME         NOT NULL,
    [CreationTimeStamp]             DATETIME         NULL,
    [PackageId]                     UNIQUEIDENTIFIER NULL,
    [TransactionInfo_Id]            UNIQUEIDENTIFIER NOT NULL,
    [TransactionSource_Id]          UNIQUEIDENTIFIER NULL,
    [Depositor_Id]                  UNIQUEIDENTIFIER NULL,
    [Panel_Id]                      UNIQUEIDENTIFIER NULL,
    [DeliveryAddress_Id]            UNIQUEIDENTIFIER NULL,
    [Account_Id]                    UNIQUEIDENTIFIER NOT NULL,
    [Type]                          NVARCHAR (100)   NOT NULL,
    [Country_Id]                    UNIQUEIDENTIFIER NULL,
    [GiftPrice]                     FLOAT (53)       NULL,
    [CostPrice]                     DECIMAL (18, 2)  NULL,
    [ProviderExtractionDate]		DATETIME NULL, 
	[BatchId]						BIGINT NULL, 
	[TransactionId]					BIGINT NULL,
	[ParentTransactionId]			UNIQUEIDENTIFIER
    CONSTRAINT [PK_dbo.IncentiveAccountTransaction] PRIMARY KEY CLUSTERED ([IncentiveAccountTransactionId] ASC),
    CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.Address_DeliveryAddress_Id] FOREIGN KEY ([DeliveryAddress_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.IncentiveAccount_Account_Id] FOREIGN KEY ([Account_Id]) REFERENCES [dbo].[IncentiveAccount] ([IncentiveAccountId]),
    CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.IncentiveAccountTransactionInfo_TransactionInfo_Id] FOREIGN KEY ([TransactionInfo_Id]) REFERENCES [dbo].[IncentiveAccountTransactionInfo] ([IncentiveAccountTransactionInfoId]),
    CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.Individual_Depositor_Id] FOREIGN KEY ([Depositor_Id]) REFERENCES [dbo].[Individual] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.TransactionSource_TransactionSource_Id] FOREIGN KEY ([TransactionSource_Id]) REFERENCES [dbo].[TransactionSource] ([TransactionSourceId]),
	CONSTRAINT [FK_dbo.IncentiveAccountTransaction_dbo.ParentId] FOREIGN KEY ([ParentTransactionId]) REFERENCES [dbo].[IncentiveAccountTransaction]([IncentiveAccountTransactionId])
);








GO
CREATE NONCLUSTERED INDEX [IX_TransactionInfo_Id]
    ON [dbo].[IncentiveAccountTransaction]([TransactionInfo_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TransactionSource_Id]
    ON [dbo].[IncentiveAccountTransaction]([TransactionSource_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Depositor_Id]
    ON [dbo].[IncentiveAccountTransaction]([Depositor_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[IncentiveAccountTransaction]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryAddress_Id]
    ON [dbo].[IncentiveAccountTransaction]([DeliveryAddress_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Account_Id]
    ON [dbo].[IncentiveAccountTransaction]([Account_Id] ASC);

GO
CREATE NONCLUSTERED INDEX IX_TransactionTypeDate
	ON [dbo].[IncentiveAccountTransaction] ([Type],[TransactionDate])
	INCLUDE ([TransactionInfo_Id], [Account_Id])

GO

--create index ix_schdate_filtered on IncentiveAccountTransaction(Account_Id)
--include(type,TransactionInfo_Id,Transactionsource_id,Comments,SynchronisationDate)
--where (type='credit' and SynchronisationDate is null)
----with (drop_existing = on )
--on CountryIdpfscheme_md(country_id)
--GO
CREATE TRIGGER dbo.trgIncentiveAccountTransaction_U 
ON dbo.[IncentiveAccountTransaction] FOR update 
AS 
insert into audit.[IncentiveAccountTransaction](	 [IncentiveAccountTransactionId]	 ,[CreationDate]	 ,[SynchronisationDate]	 ,[TransactionDate]	 ,[Comments]	 ,[Balance]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[PackageId]	 ,[TransactionInfo_Id]	 ,[TransactionSource_Id]	 ,[Depositor_Id]	 ,[Panel_Id]	 ,[DeliveryAddress_Id]	 ,[Account_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveAccountTransactionId]	 ,d.[CreationDate]	 ,d.[SynchronisationDate]	 ,d.[TransactionDate]	 ,d.[Comments]	 ,d.[Balance]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[PackageId]	 ,d.[TransactionInfo_Id]	 ,d.[TransactionSource_Id]	 ,d.[Depositor_Id]	 ,d.[Panel_Id]	 ,d.[DeliveryAddress_Id]	 ,d.[Account_Id]	 ,d.[Type],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.IncentiveAccountTransactionId = i.IncentiveAccountTransactionId 
insert into audit.[IncentiveAccountTransaction](	 [IncentiveAccountTransactionId]	 ,[CreationDate]	 ,[SynchronisationDate]	 ,[TransactionDate]	 ,[Comments]	 ,[Balance]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[PackageId]	 ,[TransactionInfo_Id]	 ,[TransactionSource_Id]	 ,[Depositor_Id]	 ,[Panel_Id]	 ,[DeliveryAddress_Id]	 ,[Account_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveAccountTransactionId]	 ,i.[CreationDate]	 ,i.[SynchronisationDate]	 ,i.[TransactionDate]	 ,i.[Comments]	 ,i.[Balance]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[PackageId]	 ,i.[TransactionInfo_Id]	 ,i.[TransactionSource_Id]	 ,i.[Depositor_Id]	 ,i.[Panel_Id]	 ,i.[DeliveryAddress_Id]	 ,i.[Account_Id]	 ,i.[Type],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.IncentiveAccountTransactionId = i.IncentiveAccountTransactionId
GO
CREATE TRIGGER dbo.trgIncentiveAccountTransaction_I
ON dbo.[IncentiveAccountTransaction] FOR insert 
AS 
insert into audit.[IncentiveAccountTransaction](	 [IncentiveAccountTransactionId]	 ,[CreationDate]	 ,[SynchronisationDate]	 ,[TransactionDate]	 ,[Comments]	 ,[Balance]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[PackageId]	 ,[TransactionInfo_Id]	 ,[TransactionSource_Id]	 ,[Depositor_Id]	 ,[Panel_Id]	 ,[DeliveryAddress_Id]	 ,[Account_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveAccountTransactionId]	 ,i.[CreationDate]	 ,i.[SynchronisationDate]	 ,i.[TransactionDate]	 ,i.[Comments]	 ,i.[Balance]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[PackageId]	 ,i.[TransactionInfo_Id]	 ,i.[TransactionSource_Id]	 ,i.[Depositor_Id]	 ,i.[Panel_Id]	 ,i.[DeliveryAddress_Id]	 ,i.[Account_Id]	 ,i.[Type],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentiveAccountTransaction_D
ON dbo.[IncentiveAccountTransaction] FOR delete 
AS 
insert into audit.[IncentiveAccountTransaction](	 [IncentiveAccountTransactionId]	 ,[CreationDate]	 ,[SynchronisationDate]	 ,[TransactionDate]	 ,[Comments]	 ,[Balance]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[PackageId]	 ,[TransactionInfo_Id]	 ,[TransactionSource_Id]	 ,[Depositor_Id]	 ,[Panel_Id]	 ,[DeliveryAddress_Id]	 ,[Account_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveAccountTransactionId]	 ,d.[CreationDate]	 ,d.[SynchronisationDate]	 ,d.[TransactionDate]	 ,d.[Comments]	 ,d.[Balance]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[PackageId]	 ,d.[TransactionInfo_Id]	 ,d.[TransactionSource_Id]	 ,d.[Depositor_Id]	 ,d.[Panel_Id]	 ,d.[DeliveryAddress_Id]	 ,d.[Account_Id]	 ,d.[Type],d.[Country_Id],'D' from deleted d	 GO
CREATE INDEX IX_BatchTransaction
ON INCENTIVEACCOUNTTRANSACTION (BatchId,TransactionId)