﻿CREATE TABLE [dbo].[BusinessProcess] (
    [GUIDReference]            UNIQUEIDENTIFIER NOT NULL,
    [Label_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [CurrentPeriod_CalendarId] UNIQUEIDENTIFIER NOT NULL,
    [CurrentPeriod_PeriodId]   UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]               UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.BusinessProcess] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.BusinessProcess_dbo.CalendarPeriod_CurrentPeriod_CalendarId_CurrentPeriod_PeriodId] FOREIGN KEY ([CurrentPeriod_CalendarId], [CurrentPeriod_PeriodId]) REFERENCES [dbo].[CalendarPeriod] ([CalendarId], [PeriodId]),
    CONSTRAINT [FK_dbo.BusinessProcess_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.BusinessProcess_dbo.Translation_Label_Id] FOREIGN KEY ([Label_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Label_Id]
    ON [dbo].[BusinessProcess]([Label_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CurrentPeriod_CalendarId_CurrentPeriod_PeriodId]
    ON [dbo].[BusinessProcess]([CurrentPeriod_CalendarId] ASC, [CurrentPeriod_PeriodId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[BusinessProcess]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgBusinessProcess_U 
ON dbo.[BusinessProcess] FOR update 
AS 
insert into audit.[BusinessProcess](
insert into audit.[BusinessProcess](
GO
CREATE TRIGGER dbo.trgBusinessProcess_I
ON dbo.[BusinessProcess] FOR insert 
AS 
insert into audit.[BusinessProcess](
GO
CREATE TRIGGER dbo.trgBusinessProcess_D
ON dbo.[BusinessProcess] FOR delete 
AS 
insert into audit.[BusinessProcess](