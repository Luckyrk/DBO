﻿CREATE TABLE [dbo].[Period] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Number]             INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Discriminator]      NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.Period] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgPeriod_U 
ON dbo.[Period] FOR update 
AS 
insert into audit.[Period](
insert into audit.[Period](
GO
CREATE TRIGGER dbo.trgPeriod_I
ON dbo.[Period] FOR insert 
AS 
insert into audit.[Period](
GO
CREATE TRIGGER dbo.trgPeriod_D
ON dbo.[Period] FOR delete 
AS 
insert into audit.[Period](