CREATE TABLE [dbo].[CollectiveSequenceBatch] (
    [CollectiveSequenceBatchId] UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CollectiveSequenceBatch] PRIMARY KEY CLUSTERED ([CollectiveSequenceBatchId] ASC),
    CONSTRAINT [FK_dbo.CollectiveSequenceBatch_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CollectiveSequenceBatch]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgCollectiveSequenceBatch_U 
ON dbo.[CollectiveSequenceBatch] FOR update 
AS 
insert into audit.[CollectiveSequenceBatch](	 [CollectiveSequenceBatchId]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[CollectiveSequenceBatchId]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.CollectiveSequenceBatchId = i.CollectiveSequenceBatchId 
insert into audit.[CollectiveSequenceBatch](	 [CollectiveSequenceBatchId]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[CollectiveSequenceBatchId]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.CollectiveSequenceBatchId = i.CollectiveSequenceBatchId
GO
CREATE TRIGGER dbo.trgCollectiveSequenceBatch_I
ON dbo.[CollectiveSequenceBatch] FOR insert 
AS 
insert into audit.[CollectiveSequenceBatch](	 [CollectiveSequenceBatchId]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[CollectiveSequenceBatchId]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCollectiveSequenceBatch_D
ON dbo.[CollectiveSequenceBatch] FOR delete 
AS 
insert into audit.[CollectiveSequenceBatch](	 [CollectiveSequenceBatchId]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[CollectiveSequenceBatchId]	 ,d.[Country_Id],'D' from deleted d