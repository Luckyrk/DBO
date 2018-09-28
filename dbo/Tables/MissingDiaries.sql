CREATE TABLE [dbo].[MissingDiaries] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [DiaryDateYear]      INT              NOT NULL,
    [DiaryDatePeriod]    INT              NOT NULL,
    [DiaryDateWeek]      INT              NOT NULL,
    [NumberOfDaysLate]   INT              NOT NULL,
    [NumberOfDaysEarly]  INT              NOT NULL,
    [ReceivedDate]       DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [DiaryDateFull]      NVARCHAR (10)    NULL,
    [DiarySourceFull]    NVARCHAR (20)    NULL,
    [PanelName]          NVARCHAR (100)   NULL,
    [BusinessId]         NVARCHAR (50)    NULL,
    [PanelId]            UNIQUEIDENTIFIER NOT NULL,
    [ClaimFlag]          INT              NOT NULL,
	[Country_Id]		 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.MissingDiaries] PRIMARY KEY CLUSTERED ([Id] ASC)
);






GO
CREATE TRIGGER dbo.trgMissingDiaries_U 
ON dbo.[MissingDiaries] FOR update 
AS 
insert into audit.[MissingDiaries](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiaryDateFull]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[BusinessId]	 ,[PanelId]	 ,[ClaimFlag]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[DiaryDateYear]	 ,d.[DiaryDatePeriod]	 ,d.[DiaryDateWeek]	 ,d.[NumberOfDaysLate]	 ,d.[NumberOfDaysEarly]	 ,d.[ReceivedDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[DiaryDateFull]	 ,d.[DiarySourceFull]	 ,d.[PanelName]	 ,d.[BusinessId]	 ,d.[PanelId]	 ,d.[ClaimFlag],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[MissingDiaries](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiaryDateFull]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[BusinessId]	 ,[PanelId]	 ,[ClaimFlag]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[DiaryDateYear]	 ,i.[DiaryDatePeriod]	 ,i.[DiaryDateWeek]	 ,i.[NumberOfDaysLate]	 ,i.[NumberOfDaysEarly]	 ,i.[ReceivedDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[DiaryDateFull]	 ,i.[DiarySourceFull]	 ,i.[PanelName]	 ,i.[BusinessId]	 ,i.[PanelId]	 ,i.[ClaimFlag],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgMissingDiaries_I
ON dbo.[MissingDiaries] FOR insert 
AS 
insert into audit.[MissingDiaries](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiaryDateFull]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[BusinessId]	 ,[PanelId]	 ,[ClaimFlag]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[DiaryDateYear]	 ,i.[DiaryDatePeriod]	 ,i.[DiaryDateWeek]	 ,i.[NumberOfDaysLate]	 ,i.[NumberOfDaysEarly]	 ,i.[ReceivedDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[DiaryDateFull]	 ,i.[DiarySourceFull]	 ,i.[PanelName]	 ,i.[BusinessId]	 ,i.[PanelId]	 ,i.[ClaimFlag],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgMissingDiaries_D
ON dbo.[MissingDiaries] FOR delete 
AS 
insert into audit.[MissingDiaries](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[NumberOfDaysLate]	 ,[NumberOfDaysEarly]	 ,[ReceivedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[DiaryDateFull]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[BusinessId]	 ,[PanelId]	 ,[ClaimFlag]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[DiaryDateYear]	 ,d.[DiaryDatePeriod]	 ,d.[DiaryDateWeek]	 ,d.[NumberOfDaysLate]	 ,d.[NumberOfDaysEarly]	 ,d.[ReceivedDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[DiaryDateFull]	 ,d.[DiarySourceFull]	 ,d.[PanelName]	 ,d.[BusinessId]	 ,d.[PanelId]	 ,d.[ClaimFlag]
	 ,d.[Country_Id]
	 ,'D' from deleted d