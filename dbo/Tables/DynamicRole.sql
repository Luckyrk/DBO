﻿CREATE TABLE [dbo].[DynamicRole] (
    [DynamicRoleId]  UNIQUEIDENTIFIER NOT NULL,
    [Code]           INT              NOT NULL,
    [Translation_Id] UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.DynamicRole] PRIMARY KEY CLUSTERED ([DynamicRoleId] ASC),
    CONSTRAINT [FK_dbo.DynamicRole_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.DynamicRole_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);


GO
CREATE TRIGGER dbo.trgDynamicRole_U 
ON dbo.[DynamicRole] FOR update 
AS 
insert into audit.[DynamicRole](
insert into audit.[DynamicRole](
GO
CREATE TRIGGER dbo.trgDynamicRole_I
ON dbo.[DynamicRole] FOR insert 
AS 
insert into audit.[DynamicRole](
GO
CREATE TRIGGER dbo.trgDynamicRole_D
ON dbo.[DynamicRole] FOR delete 
AS 
insert into audit.[DynamicRole](