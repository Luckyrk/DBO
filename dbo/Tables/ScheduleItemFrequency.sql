﻿CREATE TABLE [dbo].[ScheduleItemFrequency] (
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
insert into audit.[ScheduleItemFrequency](
insert into audit.[ScheduleItemFrequency](
GO
CREATE TRIGGER dbo.trgScheduleItemFrequency_I
ON dbo.[ScheduleItemFrequency] FOR insert 
AS 
insert into audit.[ScheduleItemFrequency](
GO
CREATE TRIGGER dbo.trgScheduleItemFrequency_D
ON dbo.[ScheduleItemFrequency] FOR delete 
AS 
insert into audit.[ScheduleItemFrequency](