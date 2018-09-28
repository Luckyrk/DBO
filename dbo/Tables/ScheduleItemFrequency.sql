CREATE TABLE [dbo].[ScheduleItemFrequency] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Hour]               NVARCHAR (5)     NULL,
    [TimeZoneId]         NVARCHAR (500)   NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.ScheduleItemFrequency] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);




GO
CREATE TRIGGER dbo.trgScheduleItemFrequency_U 
ON dbo.[ScheduleItemFrequency] FOR update 
AS 
insert into audit.[ScheduleItemFrequency](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Hour]	 ,[TimeZoneId]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Hour]	 ,d.[TimeZoneId]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ScheduleItemFrequency](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Hour]	 ,[TimeZoneId]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Hour]	 ,i.[TimeZoneId]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgScheduleItemFrequency_I
ON dbo.[ScheduleItemFrequency] FOR insert 
AS 
insert into audit.[ScheduleItemFrequency](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Hour]	 ,[TimeZoneId]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Hour]	 ,i.[TimeZoneId]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgScheduleItemFrequency_D
ON dbo.[ScheduleItemFrequency] FOR delete 
AS 
insert into audit.[ScheduleItemFrequency](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Hour]	 ,[TimeZoneId]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Hour]	 ,d.[TimeZoneId]	 ,d.[Type],'D' from deleted d