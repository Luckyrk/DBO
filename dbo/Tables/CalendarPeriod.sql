﻿CREATE TABLE [dbo].[CalendarPeriod] (
    [CalendarId]               UNIQUEIDENTIFIER NOT NULL,
    [PeriodId]                 UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [SequenceWithinPeriodType] INT              NOT NULL,
    [PeriodValue]              INT              NOT NULL,
    [StartDate]                DATETIME         NOT NULL,
    [EndDate]                  DATETIME         NOT NULL,
    [GPSUser]                  NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,
    [CreationTimeStamp]        DATETIME         NULL,
    [PeriodTypeId]             UNIQUEIDENTIFIER NOT NULL,
    [OwnerCountryId]           UNIQUEIDENTIFIER NOT NULL,
    [Id]                       UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CalendarPeriod] PRIMARY KEY CLUSTERED ([CalendarId] ASC, [PeriodId] ASC),
    CONSTRAINT [FK_dbo.CalendarPeriod_dbo.Calendar_CalendarId] FOREIGN KEY ([CalendarId]) REFERENCES [dbo].[Calendar] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CalendarPeriod_dbo.Country_OwnerCountryId] FOREIGN KEY ([OwnerCountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CalendarPeriod_dbo.PeriodType_PeriodTypeId] FOREIGN KEY ([PeriodTypeId]) REFERENCES [dbo].[PeriodType] ([PeriodTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountryId]
    ON [dbo].[CalendarPeriod]([OwnerCountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PeriodTypeId]
    ON [dbo].[CalendarPeriod]([PeriodTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarId]
    ON [dbo].[CalendarPeriod]([CalendarId] ASC);


GO
CREATE TRIGGER dbo.trgCalendarPeriod_U 
ON dbo.[CalendarPeriod] FOR update 
AS 
insert into audit.[CalendarPeriod](
insert into audit.[CalendarPeriod](
GO
CREATE TRIGGER dbo.trgCalendarPeriod_I
ON dbo.[CalendarPeriod] FOR insert 
AS 
insert into audit.[CalendarPeriod](
GO
CREATE TRIGGER dbo.trgCalendarPeriod_D
ON dbo.[CalendarPeriod] FOR delete 
AS 
insert into audit.[CalendarPeriod](