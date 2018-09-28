﻿CREATE TABLE [dbo].[OrderType] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Code]               INT              NOT NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [ActionTaskType_Id]  UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.OrderType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.OrderType_dbo.ActionTaskType_ActionTaskType_Id] FOREIGN KEY ([ActionTaskType_Id]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.OrderType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.OrderType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[OrderType]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTaskType_Id]
    ON [dbo].[OrderType]([ActionTaskType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[OrderType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgOrderType_U 
ON dbo.[OrderType] FOR update 
AS 
insert into audit.[OrderType](
insert into audit.[OrderType](
GO
CREATE TRIGGER dbo.trgOrderType_I
ON dbo.[OrderType] FOR insert 
AS 
insert into audit.[OrderType](
GO
CREATE TRIGGER dbo.trgOrderType_D
ON dbo.[OrderType] FOR delete 
AS 
insert into audit.[OrderType](