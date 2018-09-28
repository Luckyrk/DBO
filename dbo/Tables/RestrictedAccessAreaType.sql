﻿CREATE TABLE [dbo].[RestrictedAccessAreaType] (
    [RestrictedAccessAreaTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]                NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RestrictedAccessAreaType] PRIMARY KEY CLUSTERED ([RestrictedAccessAreaTypeId] ASC)
);




GO
CREATE TRIGGER dbo.trgRestrictedAccessAreaType_U 
ON dbo.[RestrictedAccessAreaType] FOR update 
AS 
insert into audit.[RestrictedAccessAreaType](
insert into audit.[RestrictedAccessAreaType](
GO
CREATE TRIGGER dbo.trgRestrictedAccessAreaType_I
ON dbo.[RestrictedAccessAreaType] FOR insert 
AS 
insert into audit.[RestrictedAccessAreaType](
GO
CREATE TRIGGER dbo.trgRestrictedAccessAreaType_D
ON dbo.[RestrictedAccessAreaType] FOR delete 
AS 
insert into audit.[RestrictedAccessAreaType](