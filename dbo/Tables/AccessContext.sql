CREATE TABLE [dbo].[AccessContext] (
    [AccessContextId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]     NVARCHAR (MAX) NULL,
	[GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    CONSTRAINT [PK_dbo.AccessContext] PRIMARY KEY CLUSTERED ([AccessContextId] ASC)
);




GO
CREATE TRIGGER dbo.trgAccessContext_U 
ON dbo.[AccessContext] FOR update 
AS 
insert into audit.[AccessContext](	 [AccessContextId]	 ,[Description]	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 	 d.[AccessContextId]	 ,d.[Description],'O',d.GPSUser,d.GPSUpdateTimestamp,d.CreationTimeStamp  from 	 deleted d join inserted i on d.AccessContextId = i.AccessContextId 
insert into audit.[AccessContext](	 [AccessContextId]	 ,[Description]	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 	 i.[AccessContextId]	 ,i.[Description],'N',d.GPSUser,d.GPSUpdateTimestamp,d.CreationTimeStamp  from 	 deleted d join inserted i on d.AccessContextId = i.AccessContextId
GO
CREATE TRIGGER dbo.trgAccessContext_I
ON dbo.[AccessContext] FOR insert 
AS 
insert into audit.[AccessContext](	 [AccessContextId]	 ,[Description]	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 	 i.[AccessContextId]	 ,i.[Description],'I',i.GPSUser,i.GPSUpdateTimestamp,i.CreationTimeStamp from inserted i
GO
CREATE TRIGGER dbo.trgAccessContext_D
ON dbo.[AccessContext] FOR delete 
AS 
insert into audit.[AccessContext](	 [AccessContextId]	 ,[Description]	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 	 d.[AccessContextId]	 ,d.[Description],'D',d.GPSUser,d.GPSUpdateTimestamp,d.CreationTimeStamp from deleted d