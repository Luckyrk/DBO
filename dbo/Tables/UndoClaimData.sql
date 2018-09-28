CREATE TABLE [dbo].[UndoClaimData] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [DiaryDateYear]      INT              NOT NULL,
    [DiaryDatePeriod]    INT              NOT NULL,
    [DiaryDateWeek]      INT              NOT NULL,
    [DiarySourceFull]    NVARCHAR (40)    NOT NULL,
    [PanelName]          NVARCHAR (200)   NULL,
    [PanelId]            UNIQUEIDENTIFIER NOT NULL,
    [UndoClaimFlag]      INT              NOT NULL,
    [GPSUser]            NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_UndoClaimData] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE TRIGGER dbo.trgUndoClaimData_U 
ON dbo.[UndoClaimData] FOR update 
AS 
insert into audit.[UndoClaimData](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[PanelId]	 ,[UndoClaimFlag]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[DiaryDateYear]	 ,d.[DiaryDatePeriod]	 ,d.[DiaryDateWeek]	 ,d.[DiarySourceFull]	 ,d.[PanelName]	 ,d.[PanelId]	 ,d.[UndoClaimFlag]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[UndoClaimData](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[PanelId]	 ,[UndoClaimFlag]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[DiaryDateYear]	 ,i.[DiaryDatePeriod]	 ,i.[DiaryDateWeek]	 ,i.[DiarySourceFull]	 ,i.[PanelName]	 ,i.[PanelId]	 ,i.[UndoClaimFlag]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgUndoClaimData_D
ON dbo.[UndoClaimData] FOR delete 
AS 
insert into audit.[UndoClaimData](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[PanelId]	 ,[UndoClaimFlag]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[Id]	 ,d.[DiaryDateYear]	 ,d.[DiaryDatePeriod]	 ,d.[DiaryDateWeek]	 ,d.[DiarySourceFull]	 ,d.[PanelName]	 ,d.[PanelId]	 ,d.[UndoClaimFlag]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d
GO
CREATE TRIGGER dbo.trgUndoClaimData_I
ON dbo.[UndoClaimData] FOR insert 
AS 
insert into audit.[UndoClaimData](	 [Id]	 ,[DiaryDateYear]	 ,[DiaryDatePeriod]	 ,[DiaryDateWeek]	 ,[DiarySourceFull]	 ,[PanelName]	 ,[PanelId]	 ,[UndoClaimFlag]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[Id]	 ,i.[DiaryDateYear]	 ,i.[DiaryDatePeriod]	 ,i.[DiaryDateWeek]	 ,i.[DiarySourceFull]	 ,i.[PanelName]	 ,i.[PanelId]	 ,i.[UndoClaimFlag]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i