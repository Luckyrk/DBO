CREATE TABLE [dbo].[ImportFilePendingRecordItem] (
    [Id]                         UNIQUEIDENTIFIER NOT NULL,
    [PropertyName]               NVARCHAR (500)   NULL,
    [PropertyValue]              NVARCHAR (MAX)   NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    [ImportFilePendingRecord_Id] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.ImportFilePendingRecordItem] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ImportFilePendingRecordItem_dbo.ImportFilePendingRecord_ImportFilePendingRecord_Id] FOREIGN KEY ([ImportFilePendingRecord_Id]) REFERENCES [dbo].[ImportFilePendingRecord] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_ImportFilePendingRecord_Id]
    ON [dbo].[ImportFilePendingRecordItem]([ImportFilePendingRecord_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportFilePendingRecordItem_U 
ON dbo.[ImportFilePendingRecordItem] FOR update 
AS 
insert into audit.[ImportFilePendingRecordItem](	 [Id]	 ,[PropertyName]	 ,[PropertyValue]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ImportFilePendingRecord_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[PropertyName]	 ,d.[PropertyValue]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ImportFilePendingRecord_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[ImportFilePendingRecordItem](	 [Id]	 ,[PropertyName]	 ,[PropertyValue]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ImportFilePendingRecord_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[PropertyName]	 ,i.[PropertyValue]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ImportFilePendingRecord_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgImportFilePendingRecordItem_I
ON dbo.[ImportFilePendingRecordItem] FOR insert 
AS 
insert into audit.[ImportFilePendingRecordItem](	 [Id]	 ,[PropertyName]	 ,[PropertyValue]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ImportFilePendingRecord_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[PropertyName]	 ,i.[PropertyValue]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ImportFilePendingRecord_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgImportFilePendingRecordItem_D
ON dbo.[ImportFilePendingRecordItem] FOR delete 
AS 
insert into audit.[ImportFilePendingRecordItem](	 [Id]	 ,[PropertyName]	 ,[PropertyValue]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ImportFilePendingRecord_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[PropertyName]	 ,d.[PropertyValue]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ImportFilePendingRecord_Id],'D' from deleted d