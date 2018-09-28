﻿CREATE TABLE [dbo].[QueryAction] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [ElementType]        NVARCHAR (150)   NOT NULL,
    [Name]               NVARCHAR (150)   NOT NULL,
    [IsGlobal]           BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Key]                NVARCHAR (200)   NULL,
    [FunctionName]       NVARCHAR (200)   NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Rule_Id]            UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.QueryAction] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.QueryAction_dbo.BusinessRule_Rule_Id] FOREIGN KEY ([Rule_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference]),
    CONSTRAINT [FK_dbo.QueryAction_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [UniqueQueryActionNameByCountry] UNIQUE NONCLUSTERED ([Name] ASC, [ElementType] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[QueryAction]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Rule_Id]
    ON [dbo].[QueryAction]([Rule_Id] ASC);


GO
CREATE TRIGGER dbo.trgQueryAction_U 
ON dbo.[QueryAction] FOR update 
AS 
insert into audit.[QueryAction](
insert into audit.[QueryAction](
GO
CREATE TRIGGER dbo.trgQueryAction_I
ON dbo.[QueryAction] FOR insert 
AS 
insert into audit.[QueryAction](
GO
CREATE TRIGGER dbo.trgQueryAction_D
ON dbo.[QueryAction] FOR delete 
AS 
insert into audit.[QueryAction](