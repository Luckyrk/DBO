﻿CREATE TABLE [dbo].[CandidateProcessorQueueItem] (
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
insert into audit.[CandidateProcessorQueueItem](
insert into audit.[CandidateProcessorQueueItem](
GO
CREATE TRIGGER dbo.trgCandidateProcessorQueueItem_I
ON dbo.[CandidateProcessorQueueItem] FOR insert 
AS 
insert into audit.[CandidateProcessorQueueItem](
GO
CREATE TRIGGER dbo.trgCandidateProcessorQueueItem_D
ON dbo.[CandidateProcessorQueueItem] FOR delete 
AS 
insert into audit.[CandidateProcessorQueueItem](