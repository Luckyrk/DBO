CREATE TABLE [dbo].[IncentiveAccount] (
    [IncentiveAccountId] UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Beneficiary_Id]     UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (100)   NOT NULL,
	[Country_Id]		 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.IncentiveAccount] PRIMARY KEY CLUSTERED ([IncentiveAccountId] ASC),
    CONSTRAINT [FK_dbo.IncentiveAccount_dbo.Individual_Beneficiary_Id] FOREIGN KEY ([Beneficiary_Id]) REFERENCES [dbo].[Individual] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentiveAccount_dbo.Individual_IncentiveAccountId] FOREIGN KEY ([IncentiveAccountId]) REFERENCES [dbo].[Individual] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_IncentiveAccountId]
    ON [dbo].[IncentiveAccount]([IncentiveAccountId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Beneficiary_Id]
    ON [dbo].[IncentiveAccount]([Beneficiary_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveAccount_U 
ON dbo.[IncentiveAccount] FOR update 
AS 
insert into audit.[IncentiveAccount](	 [IncentiveAccountId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Beneficiary_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveAccountId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Beneficiary_Id]	 ,d.[Type],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.IncentiveAccountId = i.IncentiveAccountId 
insert into audit.[IncentiveAccount](	 [IncentiveAccountId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Beneficiary_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveAccountId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Beneficiary_Id]	 ,i.[Type],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.IncentiveAccountId = i.IncentiveAccountId
GO
CREATE TRIGGER dbo.trgIncentiveAccount_I
ON dbo.[IncentiveAccount] FOR insert 
AS 
insert into audit.[IncentiveAccount](	 [IncentiveAccountId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Beneficiary_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveAccountId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Beneficiary_Id]	 ,i.[Type],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentiveAccount_D
ON dbo.[IncentiveAccount] FOR delete 
AS 
insert into audit.[IncentiveAccount](	 [IncentiveAccountId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Beneficiary_Id]	 ,[Type]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveAccountId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Beneficiary_Id]	 ,d.[Type],d.[Country_Id],'D' from deleted d