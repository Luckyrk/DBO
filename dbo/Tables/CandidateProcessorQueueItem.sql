CREATE TABLE [dbo].[CandidateProcessorQueueItem] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Item_Id]            UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CandidateProcessorQueueItem] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CandidateProcessorQueueItem_dbo.Candidate_Item_Id] FOREIGN KEY ([Item_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Item_Id]
    ON [dbo].[CandidateProcessorQueueItem]([Item_Id] ASC);


GO
CREATE TRIGGER dbo.trgCandidateProcessorQueueItem_U 
ON dbo.[CandidateProcessorQueueItem] FOR update 
AS 
insert into audit.[CandidateProcessorQueueItem](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Item_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Item_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[CandidateProcessorQueueItem](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Item_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Item_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgCandidateProcessorQueueItem_I
ON dbo.[CandidateProcessorQueueItem] FOR insert 
AS 
insert into audit.[CandidateProcessorQueueItem](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Item_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Item_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCandidateProcessorQueueItem_D
ON dbo.[CandidateProcessorQueueItem] FOR delete 
AS 
insert into audit.[CandidateProcessorQueueItem](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Item_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Item_Id],'D' from deleted d