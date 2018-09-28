﻿CREATE TABLE [dbo].[SystemOperation] (
    [SystemOperationId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]       NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SystemOperation] PRIMARY KEY CLUSTERED ([SystemOperationId] ASC)
);




GO
CREATE TRIGGER dbo.trgSystemOperation_U 
ON dbo.[SystemOperation] FOR update 
AS 
insert into audit.[SystemOperation](
insert into audit.[SystemOperation](
GO
CREATE TRIGGER dbo.trgSystemOperation_I
ON dbo.[SystemOperation] FOR insert 
AS 
insert into audit.[SystemOperation](
GO
CREATE TRIGGER dbo.trgSystemOperation_D
ON dbo.[SystemOperation] FOR delete 
AS 
insert into audit.[SystemOperation](