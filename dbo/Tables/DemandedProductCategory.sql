﻿CREATE TABLE [dbo].[DemandedProductCategory] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [ProductCode]        NVARCHAR (10)    NOT NULL,
    [ProductDescription] NVARCHAR (150)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.DemandedProductCategory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.DemandedProductCategory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);








GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[DemandedProductCategory]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemandedProductCategory_U 
ON dbo.[DemandedProductCategory] FOR update 
AS 
insert into audit.[DemandedProductCategory](
insert into audit.[DemandedProductCategory](
GO
CREATE TRIGGER dbo.trgDemandedProductCategory_I
ON dbo.[DemandedProductCategory] FOR insert 
AS 
insert into audit.[DemandedProductCategory](
GO
CREATE TRIGGER dbo.trgDemandedProductCategory_D
ON dbo.[DemandedProductCategory] FOR delete 
AS 
insert into audit.[DemandedProductCategory](