﻿CREATE TABLE [dbo].[ImportFormatPeriod] (
    [GUIDReference]            UNIQUEIDENTIFIER NOT NULL,    
	[Period]                   NVARCHAR(100) NOT NULL,
	[Code]					   INT NOT NULL,	
    [CreationTimeStamp]        DATETIME         NULL,
    [GPSUser]                  NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,    
    CONSTRAINT [PK_dbo.ImportFormatPeriod] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);

GO
CREATE TRIGGER dbo.trgImportFormatPeriod_U 
ON dbo.[ImportFormatPeriod] FOR update 
AS 
insert into audit.[ImportFormatPeriod](
insert into audit.[ImportFormatPeriod](
GO
CREATE TRIGGER dbo.trgImportFormatPeriod_I
ON dbo.[ImportFormatPeriod] FOR insert 
AS 
insert into audit.[ImportFormatPeriod](
GO
CREATE TRIGGER dbo.trgImportFormatPeriod_D
ON dbo.[ImportFormatPeriod] FOR delete 
AS 
insert into audit.[ImportFormatPeriod](