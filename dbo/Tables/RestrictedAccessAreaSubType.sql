﻿CREATE TABLE [dbo].[RestrictedAccessAreaSubType] (
    [RestrictedAccessAreaSubTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [RestrictedAccessAreaTypeId]    BIGINT         NOT NULL,
    [Description]                   NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RestrictedAccessAreaSubType] PRIMARY KEY CLUSTERED ([RestrictedAccessAreaSubTypeId] ASC),
    CONSTRAINT [FK_dbo.RestrictedAccessAreaSubType_dbo.RestrictedAccessAreaType_RestrictedAccessAreaTypeId] FOREIGN KEY ([RestrictedAccessAreaTypeId]) REFERENCES [dbo].[RestrictedAccessAreaType] ([RestrictedAccessAreaTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_RestrictedAccessAreaTypeId]
    ON [dbo].[RestrictedAccessAreaSubType]([RestrictedAccessAreaTypeId] ASC);


GO
CREATE TRIGGER dbo.trgRestrictedAccessAreaSubType_U 
ON dbo.[RestrictedAccessAreaSubType] FOR update 
AS 
insert into audit.[RestrictedAccessAreaSubType](
insert into audit.[RestrictedAccessAreaSubType](
GO
CREATE TRIGGER dbo.trgRestrictedAccessAreaSubType_I
ON dbo.[RestrictedAccessAreaSubType] FOR insert 
AS 
insert into audit.[RestrictedAccessAreaSubType](
GO
CREATE TRIGGER dbo.trgRestrictedAccessAreaSubType_D
ON dbo.[RestrictedAccessAreaSubType] FOR delete 
AS 
insert into audit.[RestrictedAccessAreaSubType](