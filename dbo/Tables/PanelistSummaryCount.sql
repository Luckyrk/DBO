﻿CREATE TABLE [dbo].[PanelistSummaryCount] (
    [GUIDReference]               UNIQUEIDENTIFIER NOT NULL,
    [PanelistId]                  UNIQUEIDENTIFIER NOT NULL,
    [SummaryCategoryId]           UNIQUEIDENTIFIER NULL,
    [CallLength]                  TIME (7)         NULL,
    [GPSUser]                     NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]          DATETIME         NULL,
    [CreationTimeStamp]           DATETIME         NULL,
    [SummaryCount]                INT              NOT NULL,
    [Panel_Id]                    UNIQUEIDENTIFIER NOT NULL,
    [CalendarPeriod_CalendarId]   UNIQUEIDENTIFIER NOT NULL,
    [CalendarPeriod_PeriodId]     UNIQUEIDENTIFIER NOT NULL,
    [CollaborationMethodology_Id] UNIQUEIDENTIFIER NULL,
    [Country_Id]                  UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PanelistSummaryCount] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.PanelistSummaryCount_dbo.CalendarPeriod_CalendarPeriod_CalendarId_CalendarPeriod_PeriodId] FOREIGN KEY ([CalendarPeriod_CalendarId], [CalendarPeriod_PeriodId]) REFERENCES [dbo].[CalendarPeriod] ([CalendarId], [PeriodId]),
    CONSTRAINT [FK_dbo.PanelistSummaryCount_dbo.CollaborationMethodology_CollaborationMethodology_Id] FOREIGN KEY ([CollaborationMethodology_Id]) REFERENCES [dbo].[CollaborationMethodology] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelistSummaryCount_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PanelistSummaryCount_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelistSummaryCount_dbo.Panelist_PanelistId] FOREIGN KEY ([PanelistId]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelistSummaryCount_dbo.Summary_Category_SummaryCategoryId] FOREIGN KEY ([SummaryCategoryId]) REFERENCES [dbo].[Summary_Category] ([SummaryCategoryId]),
    CONSTRAINT [UniquePanelistSummaryCount] UNIQUE NONCLUSTERED ([Panel_Id] ASC, [CalendarPeriod_CalendarId] ASC, [CalendarPeriod_PeriodId] ASC, [Country_Id] ASC, [PanelistId] ASC, [SummaryCategoryId] ASC, [CollaborationMethodology_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[PanelistSummaryCount]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarPeriod_CalendarId_CalendarPeriod_PeriodId]
    ON [dbo].[PanelistSummaryCount]([CalendarPeriod_CalendarId] ASC, [CalendarPeriod_PeriodId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SummaryCategoryId]
    ON [dbo].[PanelistSummaryCount]([SummaryCategoryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CollaborationMethodology_Id]
    ON [dbo].[PanelistSummaryCount]([CollaborationMethodology_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PanelistSummaryCount]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PanelistId]
    ON [dbo].[PanelistSummaryCount]([PanelistId] ASC);


GO
CREATE TRIGGER dbo.trgPanelistSummaryCount_U 
ON dbo.[PanelistSummaryCount] FOR update 
AS 
insert into audit.[PanelistSummaryCount](
insert into audit.[PanelistSummaryCount](
GO
CREATE TRIGGER dbo.trgPanelistSummaryCount_I
ON dbo.[PanelistSummaryCount] FOR insert 
AS 
insert into audit.[PanelistSummaryCount](
GO
CREATE TRIGGER dbo.trgPanelistSummaryCount_D
ON dbo.[PanelistSummaryCount] FOR delete 
AS 
insert into audit.[PanelistSummaryCount](