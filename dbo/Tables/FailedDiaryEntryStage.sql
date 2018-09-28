CREATE TABLE [dbo].[FailedDiaryEntryStage] (
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
insert into audit.[FailedDiaryEntryStage](	 [DiaryEntryStgId]	 ,[NPAN]	 ,[DiarySourceValue]	 ,[ReceivedDate]	 ,[Points]	 ,[PanelId]	 ,[FileName]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[CountryCode]	 ,[UId]	 ,AuditOperation) select 	 d.[DiaryEntryStgId]	 ,d.[NPAN]	 ,d.[DiarySourceValue]	 ,d.[ReceivedDate]	 ,d.[Points]	 ,d.[PanelId]	 ,d.[FileName]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[CountryCode]	 ,d.[UId],'O'  from 	 deleted d join inserted i on d.DiaryEntryStgId = i.DiaryEntryStgId 
insert into audit.[FailedDiaryEntryStage](	 [DiaryEntryStgId]	 ,[NPAN]	 ,[DiarySourceValue]	 ,[ReceivedDate]	 ,[Points]	 ,[PanelId]	 ,[FileName]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[CountryCode]	 ,[UId]	 ,AuditOperation) select 	 i.[DiaryEntryStgId]	 ,i.[NPAN]	 ,i.[DiarySourceValue]	 ,i.[ReceivedDate]	 ,i.[Points]	 ,i.[PanelId]	 ,i.[FileName]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[CountryCode]	 ,i.[UId]	 ,'N'  from 	 deleted d join inserted i on d.DiaryEntryStgId = i.DiaryEntryStgId
GO
CREATE TRIGGER dbo.trgFailedDiaryEntryStage_I
ON dbo.[FailedDiaryEntryStage] FOR insert 
AS 
insert into audit.[FailedDiaryEntryStage](	 [DiaryEntryStgId]	 ,[NPAN]	 ,[DiarySourceValue]	 ,[ReceivedDate]	 ,[Points]	 ,[PanelId]	 ,[FileName]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[CountryCode]	 ,[UId]	 ,AuditOperation) select 	 i.[DiaryEntryStgId]	 ,i.[NPAN]	 ,i.[DiarySourceValue]	 ,i.[ReceivedDate]	 ,i.[Points]	 ,i.[PanelId]	 ,i.[FileName]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[CountryCode]
	 ,i.[UId]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgFailedDiaryEntryStage_D
ON dbo.[FailedDiaryEntryStage] FOR delete 
AS 
insert into audit.[FailedDiaryEntryStage](	 [DiaryEntryStgId]	 ,[NPAN]	 ,[DiarySourceValue]	 ,[ReceivedDate]	 ,[Points]	 ,[PanelId]	 ,[FileName]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[CountryCode]	 ,[UId]	 ,AuditOperation) select 	 d.[DiaryEntryStgId]	 ,d.[NPAN]	 ,d.[DiarySourceValue]	 ,d.[ReceivedDate]	 ,d.[Points]	 ,d.[PanelId]	 ,d.[FileName]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[CountryCode]	 ,d.[UId]	 ,'D' from deleted d