CREATE TABLE [dbo].[IncentiveSupplier] (
    [IncentiveSupplierId] UNIQUEIDENTIFIER NOT NULL,
    [Code]                INT              NOT NULL,
    [Description]         NVARCHAR (100)   NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [Country_Id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IncentiveSupplier] PRIMARY KEY CLUSTERED ([IncentiveSupplierId] ASC),
    CONSTRAINT [FK_dbo.IncentiveSupplier_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IncentiveSupplier]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveSupplier_U 
ON dbo.[IncentiveSupplier] FOR update 
AS 
insert into audit.[IncentiveSupplier](	 [IncentiveSupplierId]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveSupplierId]	 ,d.[Code]	 ,d.[Description]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.IncentiveSupplierId = i.IncentiveSupplierId 
insert into audit.[IncentiveSupplier](	 [IncentiveSupplierId]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveSupplierId]	 ,i.[Code]	 ,i.[Description]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.IncentiveSupplierId = i.IncentiveSupplierId
GO
CREATE TRIGGER dbo.trgIncentiveSupplier_I
ON dbo.[IncentiveSupplier] FOR insert 
AS 
insert into audit.[IncentiveSupplier](	 [IncentiveSupplierId]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[IncentiveSupplierId]	 ,i.[Code]	 ,i.[Description]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentiveSupplier_D
ON dbo.[IncentiveSupplier] FOR delete 
AS 
insert into audit.[IncentiveSupplier](	 [IncentiveSupplierId]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[IncentiveSupplierId]	 ,d.[Code]	 ,d.[Description]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'D' from deleted d