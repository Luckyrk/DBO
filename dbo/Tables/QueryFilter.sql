﻿CREATE TABLE [dbo].[QueryFilter] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Index]              INT              NOT NULL,
    [Name]               NVARCHAR (150)   NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Type]               NVARCHAR (200)   NULL,
    [Model]              NVARCHAR (500)   NULL,
    [Discriminator]      NVARCHAR (128)   NOT NULL,
    [Enum_Id]            UNIQUEIDENTIFIER NULL,
    [BaseQuery_Id]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.QueryFilter] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.QueryFilter_dbo.Attribute_Enum_Id] FOREIGN KEY ([Enum_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.QueryFilter_dbo.PreDefinedQuery_BaseQuery_Id] FOREIGN KEY ([BaseQuery_Id]) REFERENCES [dbo].[PreDefinedQuery] ([PreDefinedQueryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Enum_Id]
    ON [dbo].[QueryFilter]([Enum_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_BaseQuery_Id]
    ON [dbo].[QueryFilter]([BaseQuery_Id] ASC);


GO
CREATE TRIGGER dbo.trgQueryFilter_U 
ON dbo.[QueryFilter] FOR update 
AS 
insert into audit.[QueryFilter](
insert into audit.[QueryFilter](
GO
CREATE TRIGGER dbo.trgQueryFilter_I
ON dbo.[QueryFilter] FOR insert 
AS 
insert into audit.[QueryFilter](
GO
CREATE TRIGGER dbo.trgQueryFilter_D
ON dbo.[QueryFilter] FOR delete 
AS 
insert into audit.[QueryFilter](