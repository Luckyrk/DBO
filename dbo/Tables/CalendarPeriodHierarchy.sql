﻿CREATE TABLE [dbo].[CalendarPeriodHierarchy] (
    [CalendarId]              UNIQUEIDENTIFIER NOT NULL,
    [ParentPeriodTypeId]      UNIQUEIDENTIFIER NOT NULL,
    [ChildPeriodTypeId]       UNIQUEIDENTIFIER NOT NULL,
    [SequenceWithinHierarchy] INT              NOT NULL,
    [GPSUser]                 NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]      DATETIME         NULL,
    [CreationTimeStamp]       DATETIME         NULL,
    [OwnerCountry_Id]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.CalendarPeriodHierarchy] PRIMARY KEY CLUSTERED ([CalendarId] ASC, [ParentPeriodTypeId] ASC, [ChildPeriodTypeId] ASC),
    CONSTRAINT [FK_dbo.CalendarPeriodHierarchy_dbo.Calendar_CalendarId] FOREIGN KEY ([CalendarId]) REFERENCES [dbo].[Calendar] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CalendarPeriodHierarchy_dbo.Country_OwnerCountry_Id] FOREIGN KEY ([OwnerCountry_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CalendarPeriodHierarchy_dbo.PeriodType_ChildPeriodTypeId] FOREIGN KEY ([ChildPeriodTypeId]) REFERENCES [dbo].[PeriodType] ([PeriodTypeId]),
    CONSTRAINT [FK_dbo.CalendarPeriodHierarchy_dbo.PeriodType_ParentPeriodTypeId] FOREIGN KEY ([ParentPeriodTypeId]) REFERENCES [dbo].[PeriodType] ([PeriodTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CalendarId]
    ON [dbo].[CalendarPeriodHierarchy]([CalendarId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ParentPeriodTypeId]
    ON [dbo].[CalendarPeriodHierarchy]([ParentPeriodTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ChildPeriodTypeId]
    ON [dbo].[CalendarPeriodHierarchy]([ChildPeriodTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountry_Id]
    ON [dbo].[CalendarPeriodHierarchy]([OwnerCountry_Id] ASC);


GO
CREATE TRIGGER dbo.trgCalendarPeriodHierarchy_U 
ON dbo.[CalendarPeriodHierarchy] FOR update 
AS 
insert into audit.[CalendarPeriodHierarchy](
insert into audit.[CalendarPeriodHierarchy](
GO
CREATE TRIGGER dbo.trgCalendarPeriodHierarchy_I
ON dbo.[CalendarPeriodHierarchy] FOR insert 
AS 
insert into audit.[CalendarPeriodHierarchy](
GO
CREATE TRIGGER dbo.trgCalendarPeriodHierarchy_D
ON dbo.[CalendarPeriodHierarchy] FOR delete 
AS 
insert into audit.[CalendarPeriodHierarchy](