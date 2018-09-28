﻿CREATE TABLE [dbo].[ClaimRole] (
    [ClaimRoleId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    [ActiveFrom]  DATETIME       NOT NULL,
    [ActiveTo]    DATETIME       NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ClaimRole] PRIMARY KEY CLUSTERED ([ClaimRoleId] ASC)
);




GO
CREATE TRIGGER dbo.trgClaimRole_U 
ON dbo.[ClaimRole] FOR update 
AS 
insert into audit.[ClaimRole](
insert into audit.[ClaimRole](
GO
CREATE TRIGGER dbo.trgClaimRole_I
ON dbo.[ClaimRole] FOR insert 
AS 
insert into audit.[ClaimRole](
GO
CREATE TRIGGER dbo.trgClaimRole_D
ON dbo.[ClaimRole] FOR delete 
AS 
insert into audit.[ClaimRole](