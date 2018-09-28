﻿CREATE TABLE [dbo].[MissingDiaries] (
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
insert into audit.[MissingDiaries](
insert into audit.[MissingDiaries](
GO
CREATE TRIGGER dbo.trgMissingDiaries_I
ON dbo.[MissingDiaries] FOR insert 
AS 
insert into audit.[MissingDiaries](
GO
CREATE TRIGGER dbo.trgMissingDiaries_D
ON dbo.[MissingDiaries] FOR delete 
AS 
insert into audit.[MissingDiaries](
	 ,d.[Country_Id]
	 ,'D' from deleted d