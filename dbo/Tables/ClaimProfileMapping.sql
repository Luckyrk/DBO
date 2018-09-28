﻿CREATE TABLE [dbo].[ClaimProfileMapping] (
    [AccessContextId]  BIGINT   NOT NULL,
    [ClaimProfileId]   BIGINT   NOT NULL,
    [SystemRoleTypeId] BIGINT   NOT NULL,
    [ActiveFrom]       DATETIME NOT NULL,
    [ActiveTo]         DATETIME NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ClaimProfileMapping] PRIMARY KEY CLUSTERED ([AccessContextId] ASC, [ClaimProfileId] ASC, [SystemRoleTypeId] ASC),
    CONSTRAINT [FK_dbo.ClaimProfileMapping_dbo.AccessContext_AccessContextId] FOREIGN KEY ([AccessContextId]) REFERENCES [dbo].[AccessContext] ([AccessContextId]),
    CONSTRAINT [FK_dbo.ClaimProfileMapping_dbo.ClaimProfile_ClaimProfileId] FOREIGN KEY ([ClaimProfileId]) REFERENCES [dbo].[ClaimProfile] ([ClaimProfileId])
);






GO
CREATE NONCLUSTERED INDEX [IX_AccessContextId]
    ON [dbo].[ClaimProfileMapping]([AccessContextId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ClaimProfileId]
    ON [dbo].[ClaimProfileMapping]([ClaimProfileId] ASC);


GO
CREATE TRIGGER dbo.trgClaimProfileMapping_U 
ON dbo.[ClaimProfileMapping] FOR update 
AS 
insert into audit.[ClaimProfileMapping](
insert into audit.[ClaimProfileMapping](
GO
CREATE TRIGGER dbo.trgClaimProfileMapping_I
ON dbo.[ClaimProfileMapping] FOR insert 
AS 
insert into audit.[ClaimProfileMapping](
GO
CREATE TRIGGER dbo.trgClaimProfileMapping_D
ON dbo.[ClaimProfileMapping] FOR delete 
AS 
insert into audit.[ClaimProfileMapping](