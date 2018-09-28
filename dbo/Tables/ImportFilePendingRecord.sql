﻿CREATE TABLE [dbo].[ImportFilePendingRecord] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [RelatedEntityId]    NVARCHAR (50)    NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [File_Id]            UNIQUEIDENTIFIER NULL,
    [State_Id]           UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ImportFilePendingRecord] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ImportFilePendingRecord_dbo.ImportFile_File_Id] FOREIGN KEY ([File_Id]) REFERENCES [dbo].[ImportFile] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ImportFilePendingRecord_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_File_Id]
    ON [dbo].[ImportFilePendingRecord]([File_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[ImportFilePendingRecord]([State_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportFilePendingRecord_U 
ON dbo.[ImportFilePendingRecord] FOR update 
AS 
insert into audit.[ImportFilePendingRecord](
insert into audit.[ImportFilePendingRecord](
GO
CREATE TRIGGER dbo.trgImportFilePendingRecord_I
ON dbo.[ImportFilePendingRecord] FOR insert 
AS 
insert into audit.[ImportFilePendingRecord](
GO
CREATE TRIGGER dbo.trgImportFilePendingRecord_D
ON dbo.[ImportFilePendingRecord] FOR delete 
AS 
insert into audit.[ImportFilePendingRecord](