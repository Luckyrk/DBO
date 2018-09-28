CREATE TABLE [dbo].[PanelistEligibility] (
    [GUIDReference]              UNIQUEIDENTIFIER NOT NULL,
    [PanelistId]                 UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id]                   UNIQUEIDENTIFIER NOT NULL,
    [EligibilityFailureReasonId] UNIQUEIDENTIFIER NULL,
    [IsEligible]                 BIT              NULL,
    [CalendarPeriod_CalendarId]  UNIQUEIDENTIFIER NOT NULL,
    [CalendarPeriod_PeriodId]    UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [DemographicWeight]          FLOAT (53)       NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelistEligibility] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.PanelistEligibility_dbo.CalendarPeriod_CalendarPeriod_CalendarId_CalendarPeriod_PeriodId] FOREIGN KEY ([CalendarPeriod_CalendarId], [CalendarPeriod_PeriodId]) REFERENCES [dbo].[CalendarPeriod] ([CalendarId], [PeriodId]),
    CONSTRAINT [FK_dbo.PanelistEligibility_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PanelistEligibility_dbo.EligibilityFailureReason_EligibilityFailureReasonId] FOREIGN KEY ([EligibilityFailureReasonId]) REFERENCES [dbo].[EligibilityFailureReason] ([EligibilityFailureReasonId]),
    CONSTRAINT [FK_dbo.PanelistEligibility_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelistEligibility_dbo.Panelist_PanelistId] FOREIGN KEY ([PanelistId]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [UniquePanelistEligibility] UNIQUE NONCLUSTERED ([Panel_Id] ASC, [CalendarPeriod_CalendarId] ASC, [CalendarPeriod_PeriodId] ASC, [Country_Id] ASC, [PanelistId] ASC)
);










GO

CREATE TRIGGER dbo.trgPanelistEligibility_U 
ON dbo.[PanelistEligibility] FOR update 
AS 
insert into audit.[PanelistEligibility](	 [GUIDReference]	 ,[PanelistId]	 ,[Panel_Id]	 ,[EligibilityFailureReasonId]	 ,[IsEligible]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[PanelistId]	 ,d.[Panel_Id]	 ,d.[EligibilityFailureReasonId]	 ,d.[IsEligible]	 ,d.[CalendarPeriod_CalendarId]	 ,d.[CalendarPeriod_PeriodId]	 ,d.[Country_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[PanelistEligibility](	 [GUIDReference]	 ,[PanelistId]	 ,[Panel_Id]	 ,[EligibilityFailureReasonId]	 ,[IsEligible]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[PanelistId]	 ,i.[Panel_Id]	 ,i.[EligibilityFailureReasonId]	 ,i.[IsEligible]	 ,i.[CalendarPeriod_CalendarId]	 ,i.[CalendarPeriod_PeriodId]	 ,i.[Country_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanelistEligibility_I
ON dbo.[PanelistEligibility] FOR insert 
AS 
insert into audit.[PanelistEligibility](	 [GUIDReference]	 ,[PanelistId]	 ,[Panel_Id]	 ,[EligibilityFailureReasonId]	 ,[IsEligible]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[PanelistId]	 ,i.[Panel_Id]	 ,i.[EligibilityFailureReasonId]	 ,i.[IsEligible]	 ,i.[CalendarPeriod_CalendarId]	 ,i.[CalendarPeriod_PeriodId]	 ,i.[Country_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelistEligibility_D
ON dbo.[PanelistEligibility] FOR delete 
AS 
insert into audit.[PanelistEligibility](	 [GUIDReference]	 ,[PanelistId]	 ,[Panel_Id]	 ,[EligibilityFailureReasonId]	 ,[IsEligible]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[Country_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[PanelistId]	 ,d.[Panel_Id]	 ,d.[EligibilityFailureReasonId]	 ,d.[IsEligible]	 ,d.[CalendarPeriod_CalendarId]	 ,d.[CalendarPeriod_PeriodId]	 ,d.[Country_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d