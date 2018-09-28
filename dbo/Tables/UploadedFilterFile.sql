﻿CREATE TABLE [dbo].[UploadedFilterFile] (
    [Id]       UNIQUEIDENTIFIER NOT NULL,
    [Date]     DATETIME         NOT NULL,
    [DataType] NVARCHAR (200)   NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.UploadedFilterFile] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgUploadedFilterFile_U 
ON dbo.[UploadedFilterFile] FOR update 
AS 
insert into audit.[UploadedFilterFile](
insert into audit.[UploadedFilterFile](
GO
CREATE TRIGGER dbo.trgUploadedFilterFile_I
ON dbo.[UploadedFilterFile] FOR insert 
AS 
insert into audit.[UploadedFilterFile](
GO
CREATE TRIGGER dbo.trgUploadedFilterFile_D
ON dbo.[UploadedFilterFile] FOR delete 
AS 
insert into audit.[UploadedFilterFile](