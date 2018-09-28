﻿CREATE TABLE [dbo].[BusinessRulesContext] (
    [GUIDReference]         UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]          DATETIME         NOT NULL,
    [ValidationsFolderPath] NVARCHAR (500)   NOT NULL,
    [Name]                  NVARCHAR (250)   NOT NULL,
    [GPSUser]               NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]    DATETIME         NULL,
    [CreationTimeStamp]     DATETIME         NULL,
    [Country_Id]            UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.BusinessRulesContext] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.BusinessRulesContext_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[BusinessRulesContext]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgBusinessRulesContext_U 
ON dbo.[BusinessRulesContext] FOR update 
AS 
insert into audit.[BusinessRulesContext](
insert into audit.[BusinessRulesContext](
GO
CREATE TRIGGER dbo.trgBusinessRulesContext_I
ON dbo.[BusinessRulesContext] FOR insert 
AS 
insert into audit.[BusinessRulesContext](
GO
CREATE TRIGGER dbo.trgBusinessRulesContext_D
ON dbo.[BusinessRulesContext] FOR delete 
AS 
insert into audit.[BusinessRulesContext](