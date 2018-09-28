﻿CREATE TABLE [dbo].[CalendarUnitOfTimeMeasure] (
    [UnitOfTimeMeasureId] UNIQUEIDENTIFIER NOT NULL,
    [IsRealYearMeasure]   BIT              NOT NULL,
    [IsRealMonthMeasure]  BIT              NOT NULL,
    [IsDayMeasure]        BIT              NOT NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [OwnerCountry_Id]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.CalendarUnitOfTimeMeasure] PRIMARY KEY CLUSTERED ([UnitOfTimeMeasureId] ASC),
    CONSTRAINT [FK_dbo.CalendarUnitOfTimeMeasure_dbo.Country_OwnerCountry_Id] FOREIGN KEY ([OwnerCountry_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountry_Id]
    ON [dbo].[CalendarUnitOfTimeMeasure]([OwnerCountry_Id] ASC);


GO
CREATE TRIGGER dbo.trgCalendarUnitOfTimeMeasure_U 
ON dbo.[CalendarUnitOfTimeMeasure] FOR update 
AS 
insert into audit.[CalendarUnitOfTimeMeasure](
insert into audit.[CalendarUnitOfTimeMeasure](
GO
CREATE TRIGGER dbo.trgCalendarUnitOfTimeMeasure_I
ON dbo.[CalendarUnitOfTimeMeasure] FOR insert 
AS 
insert into audit.[CalendarUnitOfTimeMeasure](
GO
CREATE TRIGGER dbo.trgCalendarUnitOfTimeMeasure_D
ON dbo.[CalendarUnitOfTimeMeasure] FOR delete 
AS 
insert into audit.[CalendarUnitOfTimeMeasure](