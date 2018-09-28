﻿CREATE TABLE [dbo].[GenericEventAudit] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [EventType]          NVARCHAR (300)   NULL,
    [Status]             NVARCHAR (100)   NULL,
    [TransactionId]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [ProcessorType]      NVARCHAR (100)   NULL,
    CONSTRAINT [PK_dbo.GenericEventAudit] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);




GO
CREATE TRIGGER dbo.trgGenericEventAudit_U 
ON dbo.[GenericEventAudit] FOR update 
AS 
insert into audit.[GenericEventAudit](
insert into audit.[GenericEventAudit](
GO
CREATE TRIGGER dbo.trgGenericEventAudit_I
ON dbo.[GenericEventAudit] FOR insert 
AS 
insert into audit.[GenericEventAudit](
GO
CREATE TRIGGER dbo.trgGenericEventAudit_D
ON dbo.[GenericEventAudit] FOR delete 
AS 
insert into audit.[GenericEventAudit](