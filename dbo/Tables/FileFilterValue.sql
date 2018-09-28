﻿CREATE TABLE [dbo].[FileFilterValue] (
    [Id]           UNIQUEIDENTIFIER NOT NULL,
    [IntegerValue] INT              NULL,
    [DateValue]    DATETIME         NULL,
    [FloatValue]   DECIMAL (18, 2)  NULL,
    [TextValue]    NVARCHAR (500)   NULL,
    [File_Id]      UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.FileFilterValue] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.FileFilterValue_dbo.UploadedFilterFile_File_Id] FOREIGN KEY ([File_Id]) REFERENCES [dbo].[UploadedFilterFile] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_File_Id]
    ON [dbo].[FileFilterValue]([File_Id] ASC);


GO
CREATE TRIGGER dbo.trgFileFilterValue_U 
ON dbo.[FileFilterValue] FOR update 
AS 
insert into audit.[FileFilterValue](
insert into audit.[FileFilterValue](
GO
CREATE TRIGGER dbo.trgFileFilterValue_I
ON dbo.[FileFilterValue] FOR insert 
AS 
insert into audit.[FileFilterValue](
GO
CREATE TRIGGER dbo.trgFileFilterValue_D
ON dbo.[FileFilterValue] FOR delete 
AS 
insert into audit.[FileFilterValue](