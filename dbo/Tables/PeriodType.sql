﻿CREATE TABLE [dbo].[PeriodType] (
    [PeriodTypeId]                          UNIQUEIDENTIFIER NOT NULL,
    [PeriodTypeCode]                        NVARCHAR (1)     NULL,
    [PeriodTypeDescription]                 NVARCHAR (256)   NULL,
    [DefaultQuantityOfUnits]                INT              NOT NULL,
    [GPSUser]                               NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]                    DATETIME         NULL,
    [CreationTimeStamp]                     DATETIME         NULL,
    [PeriodGroup]                           INT              NOT NULL,
    [PeriodGroupSequence]                   INT              NOT NULL,
    [OwnerCountry_Id]                       UNIQUEIDENTIFIER NULL,
    [UnitOfTimeMeasure_UnitOfTimeMeasureId] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.PeriodType] PRIMARY KEY CLUSTERED ([PeriodTypeId] ASC),
    CONSTRAINT [FK_dbo.PeriodType_dbo.CalendarUnitOfTimeMeasure_UnitOfTimeMeasure_UnitOfTimeMeasureId] FOREIGN KEY ([UnitOfTimeMeasure_UnitOfTimeMeasureId]) REFERENCES [dbo].[CalendarUnitOfTimeMeasure] ([UnitOfTimeMeasureId]),
    CONSTRAINT [FK_dbo.PeriodType_dbo.Country_OwnerCountry_Id] FOREIGN KEY ([OwnerCountry_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountry_Id]
    ON [dbo].[PeriodType]([OwnerCountry_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UnitOfTimeMeasure_UnitOfTimeMeasureId]
    ON [dbo].[PeriodType]([UnitOfTimeMeasure_UnitOfTimeMeasureId] ASC);


GO
CREATE TRIGGER dbo.trgPeriodType_U 
ON dbo.[PeriodType] FOR update 
AS 
insert into audit.[PeriodType](
insert into audit.[PeriodType](
GO
CREATE TRIGGER dbo.trgPeriodType_I
ON dbo.[PeriodType] FOR insert 
AS 
insert into audit.[PeriodType](
GO
CREATE TRIGGER dbo.trgPeriodType_D
ON dbo.[PeriodType] FOR delete 
AS 
insert into audit.[PeriodType](