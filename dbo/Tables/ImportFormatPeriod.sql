CREATE TABLE [dbo].[ImportFormatPeriod] (
    [GUIDReference]            UNIQUEIDENTIFIER NOT NULL,    
	[Period]                   NVARCHAR(100) NOT NULL,
	[Code]					   INT NOT NULL,	
    [CreationTimeStamp]        DATETIME         NULL,
    [GPSUser]                  NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,    
    CONSTRAINT [PK_dbo.ImportFormatPeriod] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);

GO
CREATE TRIGGER dbo.trgImportFormatPeriod_U 
ON dbo.[ImportFormatPeriod] FOR update 
AS 
insert into audit.[ImportFormatPeriod](	 [GUIDReference]    	 ,[Period]           	 ,[Code]             	 ,[GPSUser]          	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	  d.[GUIDReference]    	 ,d.[Period]           	 ,d.[Code]             	 ,d.[GPSUser]          	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ImportFormatPeriod](	 [GUIDReference]    	 ,[Period]           	 ,[Code]             	 ,[GPSUser]          	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	  i.[GUIDReference]    	 ,i.[Period]           	 ,i.[Code]             	 ,i.[GPSUser]          	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgImportFormatPeriod_I
ON dbo.[ImportFormatPeriod] FOR insert 
AS 
insert into audit.[ImportFormatPeriod](	 [GUIDReference]    	 ,[Period]           	 ,[Code]             	 ,[GPSUser]          	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	  i.[GUIDReference]    	 ,i.[Period]           	 ,i.[Code]             	 ,i.[GPSUser]          	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgImportFormatPeriod_D
ON dbo.[ImportFormatPeriod] FOR delete 
AS 
insert into audit.[ImportFormatPeriod](	 [GUIDReference]    	 ,[Period]           	 ,[Code]             	 ,[GPSUser]          	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	  d.[GUIDReference]    	 ,d.[Period]           	 ,d.[Code]             	 ,d.[GPSUser]          	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d