﻿CREATE TABLE [dbo].[CalendarEvent] (
    [Id]            UNIQUEIDENTIFIER NOT NULL,
    [Date]          DATETIME         NULL,
    [Discriminator] NVARCHAR (128)   NOT NULL,
    [Frequency_Id]  UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CalendarEvent] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.CalendarEvent_dbo.EventFrequency_Frequency_Id] FOREIGN KEY ([Frequency_Id]) REFERENCES [dbo].[EventFrequency] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Frequency_Id]
    ON [dbo].[CalendarEvent]([Frequency_Id] ASC);


GO
CREATE TRIGGER dbo.trgCalendarEvent_U 
ON dbo.[CalendarEvent] FOR update 
AS 
insert into audit.[CalendarEvent](
insert into audit.[CalendarEvent](
GO
CREATE TRIGGER dbo.trgCalendarEvent_I
ON dbo.[CalendarEvent] FOR insert 
AS 
insert into audit.[CalendarEvent](
GO
CREATE TRIGGER dbo.trgCalendarEvent_D
ON dbo.[CalendarEvent] FOR delete 
AS 
insert into audit.[CalendarEvent](