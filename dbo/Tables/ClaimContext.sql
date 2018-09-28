﻿CREATE TABLE [dbo].[ClaimContext] (
    [ClaimContextId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [ActiveFrom]     DATETIME       NOT NULL,
    [ActiveTo]       DATETIME       NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ClaimContext] PRIMARY KEY CLUSTERED ([ClaimContextId] ASC)
);




GO
CREATE TRIGGER dbo.trgClaimContext_U 
ON dbo.[ClaimContext] FOR update 
AS 
insert into audit.[ClaimContext](
insert into audit.[ClaimContext](
GO
CREATE TRIGGER dbo.trgClaimContext_I
ON dbo.[ClaimContext] FOR insert 
AS 
insert into audit.[ClaimContext](
GO
CREATE TRIGGER dbo.trgClaimContext_D
ON dbo.[ClaimContext] FOR delete 
AS 
insert into audit.[ClaimContext](