﻿CREATE TABLE [dbo].[ReasonForStockKitChange] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ReasonForStockKitChange] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ReasonForStockKitChange_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ReasonForStockKitChange_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ReasonForStockKitChange]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ReasonForStockKitChange]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgReasonForStockKitChange_U 
ON dbo.[ReasonForStockKitChange] FOR update 
AS 
insert into audit.[ReasonForStockKitChange](
insert into audit.[ReasonForStockKitChange](
GO
CREATE TRIGGER dbo.trgReasonForStockKitChange_I
ON dbo.[ReasonForStockKitChange] FOR insert 
AS 
insert into audit.[ReasonForStockKitChange](
GO
CREATE TRIGGER dbo.trgReasonForStockKitChange_D
ON dbo.[ReasonForStockKitChange] FOR delete 
AS 
insert into audit.[ReasonForStockKitChange](