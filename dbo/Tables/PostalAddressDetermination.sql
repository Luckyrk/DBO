﻿CREATE TABLE [dbo].[PostalAddressDetermination] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [AddressLine1]       NVARCHAR (100)   NULL,
    [AddressLine2]       NVARCHAR (100)   NULL,
    [AddressLine3]       NVARCHAR (100)   NULL,
    [AddressLine4]       NVARCHAR (100)   NULL,
    [PostCode]           NVARCHAR (50)    NULL,
    [GPSUser]            NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GeographicArea_Id]  UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PostalAddressDetermination] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.PostalAddressDetermination_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PostalAddressDetermination_dbo.GeographicArea_GeographicArea_Id] FOREIGN KEY ([GeographicArea_Id]) REFERENCES [dbo].[GeographicArea] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_GeographicArea_Id]
    ON [dbo].[PostalAddressDetermination]([GeographicArea_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PostalAddressDetermination]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgPostalAddressDetermination_U 
ON dbo.[PostalAddressDetermination] FOR update 
AS 
insert into audit.[PostalAddressDetermination](
insert into audit.[PostalAddressDetermination](
GO
CREATE TRIGGER dbo.trgPostalAddressDetermination_I
ON dbo.[PostalAddressDetermination] FOR insert 
AS 
insert into audit.[PostalAddressDetermination](
GO
CREATE TRIGGER dbo.trgPostalAddressDetermination_D
ON dbo.[PostalAddressDetermination] FOR delete 
AS 
insert into audit.[PostalAddressDetermination](