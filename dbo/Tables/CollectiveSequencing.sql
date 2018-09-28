CREATE TABLE [dbo].[CollectiveSequencing] (
    [CollectiveSequencingId] UNIQUEIDENTIFIER NOT NULL,
    [Sequence]               INT              NOT NULL,
    [GroupSequenceBatch_Id]  UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CollectiveSequencing] PRIMARY KEY CLUSTERED ([CollectiveSequencingId] ASC),
    CONSTRAINT [FK_dbo.CollectiveSequencing_dbo.CollectiveSequenceBatch_GroupSequenceBatch_Id] FOREIGN KEY ([GroupSequenceBatch_Id]) REFERENCES [dbo].[CollectiveSequenceBatch] ([CollectiveSequenceBatchId]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_GroupSequenceBatch_Id]
    ON [dbo].[CollectiveSequencing]([GroupSequenceBatch_Id] ASC);


GO
CREATE TRIGGER dbo.trgCollectiveSequencing_U 
ON dbo.[CollectiveSequencing] FOR update 
AS 
insert into audit.[CollectiveSequencing](	 [CollectiveSequencingId]	 ,[Sequence]	 ,[GroupSequenceBatch_Id]	 ,AuditOperation) select 	 d.[CollectiveSequencingId]	 ,d.[Sequence]	 ,d.[GroupSequenceBatch_Id],'O'  from 	 deleted d join inserted i on d.CollectiveSequencingId = i.CollectiveSequencingId 
insert into audit.[CollectiveSequencing](	 [CollectiveSequencingId]	 ,[Sequence]	 ,[GroupSequenceBatch_Id]	 ,AuditOperation) select 	 i.[CollectiveSequencingId]	 ,i.[Sequence]	 ,i.[GroupSequenceBatch_Id],'N'  from 	 deleted d join inserted i on d.CollectiveSequencingId = i.CollectiveSequencingId
GO
CREATE TRIGGER dbo.trgCollectiveSequencing_I
ON dbo.[CollectiveSequencing] FOR insert 
AS 
insert into audit.[CollectiveSequencing](	 [CollectiveSequencingId]	 ,[Sequence]	 ,[GroupSequenceBatch_Id]	 ,AuditOperation) select 	 i.[CollectiveSequencingId]	 ,i.[Sequence]	 ,i.[GroupSequenceBatch_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCollectiveSequencing_D
ON dbo.[CollectiveSequencing] FOR delete 
AS 
insert into audit.[CollectiveSequencing](	 [CollectiveSequencingId]	 ,[Sequence]	 ,[GroupSequenceBatch_Id]	 ,AuditOperation) select 	 d.[CollectiveSequencingId]	 ,d.[Sequence]	 ,d.[GroupSequenceBatch_Id],'D' from deleted d