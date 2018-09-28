CREATE TABLE [dbo].[DiaryImportAudit] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [FileName]           NVARCHAR (50)    NULL,
    [FileImportDate]     DATETIME         NULL,
    [ImportTypeId]       TINYINT          NULL,
    [OutcomeId]          TINYINT          NULL,
    [FileRowCount]       INT              NULL,
    [ErrorCode]          INT              NULL,
    [ErrorDescription]   NVARCHAR (500)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Panel_Id]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.DiaryImportAudit] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.DiaryImportAudit_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[DiaryImportAudit]([Panel_Id] ASC);


GO
CREATE TRIGGER dbo.trgDiaryImportAudit_U 
ON dbo.[DiaryImportAudit] FOR update 
AS 
insert into audit.[DiaryImportAudit](	 [Id]	 ,[FileName]	 ,[FileImportDate]	 ,[ImportTypeId]	 ,[OutcomeId]	 ,[FileRowCount]	 ,[ErrorCode]	 ,[ErrorDescription]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[FileName]	 ,d.[FileImportDate]	 ,d.[ImportTypeId]	 ,d.[OutcomeId]	 ,d.[FileRowCount]	 ,d.[ErrorCode]	 ,d.[ErrorDescription]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panel_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[DiaryImportAudit](	 [Id]	 ,[FileName]	 ,[FileImportDate]	 ,[ImportTypeId]	 ,[OutcomeId]	 ,[FileRowCount]	 ,[ErrorCode]	 ,[ErrorDescription]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[FileName]	 ,i.[FileImportDate]	 ,i.[ImportTypeId]	 ,i.[OutcomeId]	 ,i.[FileRowCount]	 ,i.[ErrorCode]	 ,i.[ErrorDescription]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panel_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgDiaryImportAudit_I
ON dbo.[DiaryImportAudit] FOR insert 
AS 
insert into audit.[DiaryImportAudit](	 [Id]	 ,[FileName]	 ,[FileImportDate]	 ,[ImportTypeId]	 ,[OutcomeId]	 ,[FileRowCount]	 ,[ErrorCode]	 ,[ErrorDescription]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[FileName]	 ,i.[FileImportDate]	 ,i.[ImportTypeId]	 ,i.[OutcomeId]	 ,i.[FileRowCount]	 ,i.[ErrorCode]	 ,i.[ErrorDescription]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDiaryImportAudit_D
ON dbo.[DiaryImportAudit] FOR delete 
AS 
insert into audit.[DiaryImportAudit](	 [Id]	 ,[FileName]	 ,[FileImportDate]	 ,[ImportTypeId]	 ,[OutcomeId]	 ,[FileRowCount]	 ,[ErrorCode]	 ,[ErrorDescription]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[FileName]	 ,d.[FileImportDate]	 ,d.[ImportTypeId]	 ,d.[OutcomeId]	 ,d.[FileRowCount]	 ,d.[ErrorCode]	 ,d.[ErrorDescription]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panel_Id],'D' from deleted d