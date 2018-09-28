﻿CREATE TABLE [dbo].[ImportFilePendingRecordItem] (
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
insert into audit.[ImportFilePendingRecordItem](
insert into audit.[ImportFilePendingRecordItem](
GO
CREATE TRIGGER dbo.trgImportFilePendingRecordItem_I
ON dbo.[ImportFilePendingRecordItem] FOR insert 
AS 
insert into audit.[ImportFilePendingRecordItem](
GO
CREATE TRIGGER dbo.trgImportFilePendingRecordItem_D
ON dbo.[ImportFilePendingRecordItem] FOR delete 
AS 
insert into audit.[ImportFilePendingRecordItem](