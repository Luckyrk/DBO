﻿CREATE TABLE [dbo].[BusinessRule] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [BusinessRule]       NVARCHAR (500)   NOT NULL,
    [CreationDate]       DATETIME         NOT NULL,
    [LastModification]   DATETIME         NOT NULL,
    [Name]               NVARCHAR (250)   NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Context_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    [ApplicationName]    NVARCHAR (200)   NULL,
    [Version]            INT              DEFAULT ((1)) NOT NULL,
    [EntityName]         NVARCHAR (200)   NULL,
    CONSTRAINT [PK_dbo.BusinessRule] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.BusinessRule_dbo.BusinessRulesContext_Context_Id] FOREIGN KEY ([Context_Id]) REFERENCES [dbo].[BusinessRulesContext] ([GUIDReference]),
    CONSTRAINT [FK_dbo.BusinessRule_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);








GO
CREATE NONCLUSTERED INDEX [IX_Context_Id]
    ON [dbo].[BusinessRule]([Context_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[BusinessRule]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgBusinessRule_U 
ON dbo.[BusinessRule] FOR update 
AS 
insert into audit.[BusinessRule](
insert into audit.[BusinessRule](
GO
CREATE TRIGGER dbo.trgBusinessRule_I
ON dbo.[BusinessRule] FOR insert 
AS 
insert into audit.[BusinessRule](
GO
CREATE TRIGGER dbo.trgBusinessRule_D
ON dbo.[BusinessRule] FOR delete 
AS 
insert into audit.[BusinessRule](