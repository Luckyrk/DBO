﻿CREATE TABLE [dbo].[Summary_Category] (
    [SummaryCategoryId]  UNIQUEIDENTIFIER NOT NULL,
    [Description]        NVARCHAR (200)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Code] NVARCHAR(20) NULL, 
    CONSTRAINT [PK_dbo.Summary_Category] PRIMARY KEY CLUSTERED ([SummaryCategoryId] ASC),
    CONSTRAINT [FK_dbo.Summary_Category_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Summary_Category]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgSummary_Category_U 
ON dbo.[Summary_Category] FOR update 
AS 
insert into audit.[Summary_Category](
insert into audit.[Summary_Category](
GO
CREATE TRIGGER dbo.trgSummary_Category_I
ON dbo.[Summary_Category] FOR insert 
AS 
insert into audit.[Summary_Category](
GO
CREATE TRIGGER dbo.trgSummary_Category_D
ON dbo.[Summary_Category] FOR delete 
AS 
insert into audit.[Summary_Category](