﻿CREATE TABLE [dbo].[ComplianceCategory] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [KeyName]            NVARCHAR (1000)  NOT NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [CreationTimeStamp]  DATETIME         NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NOT NULL,
    CONSTRAINT [PK_dbo.ComplianceCategory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ComplianceCategory_Country] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ComplianceCategory_Translation] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);


GO
CREATE TRIGGER dbo.trgComplianceCategory_U 
ON dbo.[ComplianceCategory] FOR update 
AS 
insert into audit.[ComplianceCategory](
insert into audit.[ComplianceCategory](
GO
CREATE TRIGGER dbo.trgComplianceCategory_D
ON dbo.[ComplianceCategory] FOR delete 
AS 
insert into audit.[ComplianceCategory](
GO
CREATE TRIGGER dbo.trgComplianceCategory_I
ON dbo.[ComplianceCategory] FOR insert 
AS 
insert into audit.[ComplianceCategory](