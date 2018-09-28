﻿CREATE TABLE [dbo].[ImportAudit] (
    [GUIDReference]       UNIQUEIDENTIFIER NOT NULL,
    [Error]               BIT              NOT NULL,
    [IsInvalid]           BIT              NOT NULL,
    [Message]             NVARCHAR (1000)  NULL,
    [Date]                DATETIME         NOT NULL,
    [SerializedRowData]   NVARCHAR (MAX)   NULL,
    [SerializedRowErrors] NVARCHAR (MAX)   NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [File_Id]             UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ImportAudit] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ImportAudit_dbo.ImportFile_File_Id] FOREIGN KEY ([File_Id]) REFERENCES [dbo].[ImportFile] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_File_Id]
    ON [dbo].[ImportAudit]([File_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportAudit_U 
ON dbo.[ImportAudit] FOR update 
AS 
insert into audit.[ImportAudit](
insert into audit.[ImportAudit](
GO
CREATE TRIGGER dbo.trgImportAudit_I
ON dbo.[ImportAudit] FOR insert 
AS 
insert into audit.[ImportAudit](
GO
CREATE TRIGGER dbo.trgImportAudit_D
ON dbo.[ImportAudit] FOR delete 
AS 
insert into audit.[ImportAudit](