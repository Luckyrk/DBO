﻿CREATE TABLE [dbo].[AuditItem] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [EntityId]           UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [Type]               NVARCHAR (50)    NOT NULL,
    [CreationTimeStamp]  DATETIME         NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Track]              XML              NOT NULL,
    CONSTRAINT [PK_dbo.AuditItem] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);




GO
CREATE TRIGGER dbo.trgAuditItem_U 
ON dbo.[AuditItem] FOR update 
AS 
insert into audit.[AuditItem](
insert into audit.[AuditItem](
GO
CREATE TRIGGER dbo.trgAuditItem_I
ON dbo.[AuditItem] FOR insert 
AS 
insert into audit.[AuditItem](
GO
CREATE TRIGGER dbo.trgAuditItem_D
ON dbo.[AuditItem] FOR delete 
AS 
insert into audit.[AuditItem](