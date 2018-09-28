CREATE TABLE [dbo].[AuditItem] (
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
insert into audit.[AuditItem](	 [GUIDReference]	 ,[EntityId]	 ,[GPSUser]	 ,[Type]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Track]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[EntityId]	 ,d.[GPSUser]	 ,d.[Type]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp]	 ,d.[Track],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[AuditItem](	 [GUIDReference]	 ,[EntityId]	 ,[GPSUser]	 ,[Type]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Track]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[EntityId]	 ,i.[GPSUser]	 ,i.[Type]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp]	 ,i.[Track],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgAuditItem_I
ON dbo.[AuditItem] FOR insert 
AS 
insert into audit.[AuditItem](	 [GUIDReference]	 ,[EntityId]	 ,[GPSUser]	 ,[Type]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Track]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[EntityId]	 ,i.[GPSUser]	 ,i.[Type]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp]	 ,i.[Track],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAuditItem_D
ON dbo.[AuditItem] FOR delete 
AS 
insert into audit.[AuditItem](	 [GUIDReference]	 ,[EntityId]	 ,[GPSUser]	 ,[Type]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,[Track]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[EntityId]	 ,d.[GPSUser]	 ,d.[Type]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp]	 ,d.[Track],'D' from deleted d