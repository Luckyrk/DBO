CREATE TABLE [dbo].[DiaryEntry] (
    [Id]                         UNIQUEIDENTIFIER NOT NULL,
    [Points]                     INT              NOT NULL,
    [DiaryDateYear]              INT              NOT NULL,
    [DiaryDatePeriod]            INT              NOT NULL,
    [DiaryDateWeek]              INT              NOT NULL,
    [NumberOfDaysLate]           INT              NOT NULL,
    [NumberOfDaysEarly]          INT              NOT NULL,
    [DiaryState]                 NVARCHAR (150)   NULL,
    [ReceivedDate]               DATETIME         NOT NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    [DiarySourceFull]            NVARCHAR (30)    NULL,
    [BusinessId]                 NVARCHAR (50)    NULL,
    [Together]                   INT              NOT NULL,
    [PanelId]                    UNIQUEIDENTIFIER NOT NULL,
    [IncentiveCode]              INT              NOT NULL,
    [ClaimFlag]                  INT              NOT NULL,
    [ConsecutiveEntriesReceived] INT              NULL,
	[Country_Id]			     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.DiaryEntry] PRIMARY KEY CLUSTERED ([Id] ASC)
);












GO



GO
CREATE TRIGGER dbo.trgDiaryEntry_U 
ON dbo.[DiaryEntry] FOR update 
AS 
insert into audit.[DiaryEntry](	 [Id]	 ,[Points]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[DiaryState]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiarySourceFull]	 ,[BusinessId]	 ,[Together]	 ,[PanelId]	 ,[IncentiveCode]	 ,[ClaimFlag]	 ,[ConsecutiveEntriesReceived]	 ,Country_Id	 ,AuditOperation) select 	 d.[Id]	 ,d.[Points]	 ,d.[DiaryDateYear]	 ,d.[DiaryDatePeriod]	 ,d.[DiaryDateWeek]	 ,d.[NumberOfDaysLate]	 ,d.[NumberOfDaysEarly]	 ,d.[DiaryState]	 ,d.[ReceivedDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[DiarySourceFull]	 ,d.[BusinessId]	 ,d.[Together]	 ,d.[PanelId]	 ,d.[IncentiveCode]	 ,d.[ClaimFlag]	 ,d.[ConsecutiveEntriesReceived],d.Country_Id,'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[DiaryEntry](	 [Id]	 ,[Points]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[DiaryState]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiarySourceFull]	 ,[BusinessId]	 ,[Together]	 ,[PanelId]	 ,[IncentiveCode]	 ,[ClaimFlag]	 ,[ConsecutiveEntriesReceived]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Points]	 ,i.[DiaryDateYear]	 ,i.[DiaryDatePeriod]	 ,i.[DiaryDateWeek]	 ,i.[NumberOfDaysLate]	 ,i.[NumberOfDaysEarly]	 ,i.[DiaryState]	 ,i.[ReceivedDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[DiarySourceFull]	 ,i.[BusinessId]	 ,i.[Together]	 ,i.[PanelId]	 ,i.[IncentiveCode]	 ,i.[ClaimFlag]	 ,i.[ConsecutiveEntriesReceived],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgDiaryEntry_I
ON dbo.[DiaryEntry] FOR insert 
AS 
insert into audit.[DiaryEntry](	 [Id]	 ,[Points]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[DiaryState]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiarySourceFull]	 ,[BusinessId]	 ,[Together]	 ,[PanelId]	 ,[IncentiveCode]	 ,[ClaimFlag]	 ,[ConsecutiveEntriesReceived]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Points]	 ,i.[DiaryDateYear]	 ,i.[DiaryDatePeriod]	 ,i.[DiaryDateWeek]	 ,i.[NumberOfDaysLate]	 ,i.[NumberOfDaysEarly]	 ,i.[DiaryState]	 ,i.[ReceivedDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[DiarySourceFull]	 ,i.[BusinessId]	 ,i.[Together]	 ,i.[PanelId]	 ,i.[IncentiveCode]	 ,i.[ClaimFlag]	 ,i.[ConsecutiveEntriesReceived],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDiaryEntry_D
ON dbo.[DiaryEntry] FOR delete 
AS 
insert into audit.[DiaryEntry](	 [Id]	 ,[Points]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[DiaryState]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiarySourceFull]	 ,[BusinessId]	 ,[Together]	 ,[PanelId]	 ,[IncentiveCode]	 ,[ClaimFlag]	 ,[ConsecutiveEntriesReceived]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Points]	 ,d.[DiaryDateYear]	 ,d.[DiaryDatePeriod]	 ,d.[DiaryDateWeek]	 ,d.[NumberOfDaysLate]	 ,d.[NumberOfDaysEarly]	 ,d.[DiaryState]	 ,d.[ReceivedDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[DiarySourceFull]	 ,d.[BusinessId]	 ,d.[Together]	 ,d.[PanelId]	 ,d.[IncentiveCode]	 ,d.[ClaimFlag]	 ,d.[ConsecutiveEntriesReceived],d.[Country_Id],'D' from deleted d