﻿CREATE TABLE [dbo].[DiaryEntry] (
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
insert into audit.[DiaryEntry](
insert into audit.[DiaryEntry](
GO
CREATE TRIGGER dbo.trgDiaryEntry_I
ON dbo.[DiaryEntry] FOR insert 
AS 
insert into audit.[DiaryEntry](
GO
CREATE TRIGGER dbo.trgDiaryEntry_D
ON dbo.[DiaryEntry] FOR delete 
AS 
insert into audit.[DiaryEntry](