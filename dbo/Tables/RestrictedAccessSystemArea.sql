﻿CREATE TABLE [dbo].[RestrictedAccessSystemArea] (
    [RestrictedAccessAreaId] BIGINT         NOT NULL,
    [Path]                   NVARCHAR (MAX) NULL,
    [Name]                   NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RestrictedAccessSystemArea] PRIMARY KEY CLUSTERED ([RestrictedAccessAreaId] ASC),
    CONSTRAINT [FK_dbo.RestrictedAccessSystemArea_dbo.RestrictedAccessArea_RestrictedAccessAreaId] FOREIGN KEY ([RestrictedAccessAreaId]) REFERENCES [dbo].[RestrictedAccessArea] ([RestrictedAccessAreaId])
);






GO
CREATE NONCLUSTERED INDEX [IX_RestrictedAccessAreaId]
    ON [dbo].[RestrictedAccessSystemArea]([RestrictedAccessAreaId] ASC);


GO
CREATE TRIGGER dbo.trgRestrictedAccessSystemArea_U 
ON dbo.[RestrictedAccessSystemArea] FOR update 
AS 
insert into audit.[RestrictedAccessSystemArea](
insert into audit.[RestrictedAccessSystemArea](
GO
CREATE TRIGGER dbo.trgRestrictedAccessSystemArea_I
ON dbo.[RestrictedAccessSystemArea] FOR insert 
AS 
insert into audit.[RestrictedAccessSystemArea](
GO
CREATE TRIGGER dbo.trgRestrictedAccessSystemArea_D
ON dbo.[RestrictedAccessSystemArea] FOR delete 
AS 
insert into audit.[RestrictedAccessSystemArea](