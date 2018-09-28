CREATE TABLE [dbo].[PreallocatedBatch] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]       DATETIME         NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.PreallocatedBatch] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgPreallocatedBatch_U 
ON dbo.[PreallocatedBatch] FOR update 
AS 
insert into audit.[PreallocatedBatch](	 [Id]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[CreationDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[PreallocatedBatch](	 [Id]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[CreationDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgPreallocatedBatch_I
ON dbo.[PreallocatedBatch] FOR insert 
AS 
insert into audit.[PreallocatedBatch](	 [Id]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[CreationDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPreallocatedBatch_D
ON dbo.[PreallocatedBatch] FOR delete 
AS 
insert into audit.[PreallocatedBatch](	 [Id]	 ,[CreationDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[CreationDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d