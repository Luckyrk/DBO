﻿CREATE TABLE [dbo].[QueryExport] (
    [Id]               UNIQUEIDENTIFIER NOT NULL,
    [PaddingCharacter] NVARCHAR (1)     NULL,
    [Type]             NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.QueryExport] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgQueryExport_U 
ON dbo.[QueryExport] FOR update 
AS 
insert into audit.[QueryExport](
insert into audit.[QueryExport](
GO
CREATE TRIGGER dbo.trgQueryExport_I
ON dbo.[QueryExport] FOR insert 
AS 
insert into audit.[QueryExport](
GO
CREATE TRIGGER dbo.trgQueryExport_D
ON dbo.[QueryExport] FOR delete 
AS 
insert into audit.[QueryExport](