CREATE TABLE [dbo].[Period] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Number]             INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Discriminator]      NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.Period] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgPeriod_U 
ON dbo.[Period] FOR update 
AS 
insert into audit.[Period](	 [Id]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Number]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Discriminator],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[Period](	 [Id]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Number]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Discriminator],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgPeriod_I
ON dbo.[Period] FOR insert 
AS 
insert into audit.[Period](	 [Id]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Number]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Discriminator],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPeriod_D
ON dbo.[Period] FOR delete 
AS 
insert into audit.[Period](	 [Id]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Discriminator]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Number]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Discriminator],'D' from deleted d