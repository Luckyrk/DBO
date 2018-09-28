﻿CREATE TABLE [dbo].[FailedDiaryEntryStage] (
    [DiaryEntryStgId]    UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [NPAN]               NVARCHAR (20)    NULL,
    [DiarySourceValue]   TINYINT          NOT NULL,
    [ReceivedDate]       DATETIME         NOT NULL,
    [Points]             INT              NULL,
    [PanelId]            TINYINT          NOT NULL,
    [FileName]           NVARCHAR (70)    NOT NULL,
    [GPSUser]            NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [CountryCode]        NVARCHAR (MAX)   NULL,
    [UId]                NVARCHAR (100)   NULL,
    CONSTRAINT [PK_dbo.FailedDiaryEntryStage] PRIMARY KEY CLUSTERED ([DiaryEntryStgId] ASC)
);






GO
CREATE TRIGGER dbo.trgFailedDiaryEntryStage_U 
ON dbo.[FailedDiaryEntryStage] FOR update 
AS 
insert into audit.[FailedDiaryEntryStage](
insert into audit.[FailedDiaryEntryStage](
GO
CREATE TRIGGER dbo.trgFailedDiaryEntryStage_I
ON dbo.[FailedDiaryEntryStage] FOR insert 
AS 
insert into audit.[FailedDiaryEntryStage](
	 ,i.[UId]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgFailedDiaryEntryStage_D
ON dbo.[FailedDiaryEntryStage] FOR delete 
AS 
insert into audit.[FailedDiaryEntryStage](