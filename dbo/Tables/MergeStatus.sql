﻿CREATE TABLE [dbo].[MergeStatus] (
    [MergeStatusId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]   NVARCHAR (200) NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.MergeStatus] PRIMARY KEY CLUSTERED ([MergeStatusId] ASC)
);




GO
CREATE TRIGGER dbo.trgMergeStatus_U 
ON dbo.[MergeStatus] FOR update 
AS 
insert into audit.[MergeStatus](
insert into audit.[MergeStatus](
GO
CREATE TRIGGER dbo.trgMergeStatus_I
ON dbo.[MergeStatus] FOR insert 
AS 
insert into audit.[MergeStatus](
GO
CREATE TRIGGER dbo.trgMergeStatus_D
ON dbo.[MergeStatus] FOR delete 
AS 
insert into audit.[MergeStatus](