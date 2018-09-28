﻿CREATE TABLE [dbo].[IncentiveSupplier] (
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
insert into audit.[IncentiveSupplier](
insert into audit.[IncentiveSupplier](
GO
CREATE TRIGGER dbo.trgIncentiveSupplier_I
ON dbo.[IncentiveSupplier] FOR insert 
AS 
insert into audit.[IncentiveSupplier](
GO
CREATE TRIGGER dbo.trgIncentiveSupplier_D
ON dbo.[IncentiveSupplier] FOR delete 
AS 
insert into audit.[IncentiveSupplier](