CREATE TABLE [dbo].[CalendarDenorm] (
    [YearPeriodWeek]                 NVARCHAR (17)    NULL,
    [OwnerCountryID]                 UNIQUEIDENTIFIER NOT NULL,
    [CountryISO2A]                   NVARCHAR (2)     NOT NULL,
    [CalendarID]                     UNIQUEIDENTIFIER NOT NULL,
    [CalendarDescription]            NVARCHAR (256)   NULL,
    [PanelID]                        UNIQUEIDENTIFIER NULL,
    [yearPeriodID]                   UNIQUEIDENTIFIER NOT NULL,
    [periodPeriodID]                 UNIQUEIDENTIFIER NOT NULL,
    [weekPeriodID]                   UNIQUEIDENTIFIER NOT NULL,
    [yearSequenceWithinPeriodType]   INT              NOT NULL,
    [PeriodSequenceWithinPeriodType] INT              NOT NULL,
    [weekSequenceWithinPeriodType]   INT              NOT NULL,
    [yearPeriodValue]                INT              NOT NULL,
    [periodPeriodValue]              INT              NOT NULL,
    [weekPeriodValue]                INT              NOT NULL,
    [yearStartDate]                  DATETIME         NOT NULL,
    [yearEndDate]                    DATETIME         NOT NULL,
    [periodStartDate]                DATETIME         NOT NULL,
    [periodEndDate]                  DATETIME         NOT NULL,
    [weekStartDate]                  DATETIME         NOT NULL,
    [weekEndDate]                    DATETIME         NOT NULL,
    [yearPeriodTypeCode]             NVARCHAR (1)     NULL,
    [periodPeriodTypeCode]           NVARCHAR (1)     NULL,
    [weekPeriodTypeCode]             NVARCHAR (1)     NULL,
    [yearPeriodTypeDescription]      NVARCHAR (256)   NULL,
    [periodPeriodTypeDescription]    NVARCHAR (256)   NULL,
    [weekPeriodTypeDescription]      NVARCHAR (256)   NULL,
    [yearQuantityOfUnits]            INT              NOT NULL,
    [periodQuantityOfUnits]          INT              NOT NULL,
    [weekQuantityOfUnits]            INT              NOT NULL,
    [yearParentTypeID]               UNIQUEIDENTIFIER NOT NULL,
    [yearChildPeriodTypeID]          UNIQUEIDENTIFIER NOT NULL,
    [periodParentTypeID]             UNIQUEIDENTIFIER NOT NULL,
    [periodChildPeriodTypeID]        UNIQUEIDENTIFIER NOT NULL,
    [weekParentTypeID]               UNIQUEIDENTIFIER NOT NULL,
    [weekChildPeriodTypeID]          UNIQUEIDENTIFIER NOT NULL,
    [yearPeriodGroup]                INT              NOT NULL,
    [periodPeriodGroup]              INT              NOT NULL,
    [weekPeriodGroup]                INT              NOT NULL,
    [yearSequenceWithinHierarchy]    INT              NOT NULL,
    [periodSequenceWithinHierarchy]  INT              NOT NULL,
    [weekSequenceWithinHierarchy]    INT              NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarDenorm_weekStartEndDate]
    ON [dbo].[CalendarDenorm]([weekStartDate] ASC, [weekEndDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarDenorm_PanelID]
    ON [dbo].[CalendarDenorm]([PanelID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarDenorm_CalendarID_CountryISO2A]
    ON [dbo].[CalendarDenorm]([CalendarID] ASC, [CountryISO2A] ASC, [YearPeriodWeek] ASC);

