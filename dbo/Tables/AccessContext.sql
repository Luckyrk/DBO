﻿CREATE TABLE [dbo].[AccessContext] (
    [AccessContextId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]     NVARCHAR (MAX) NULL,
	[GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    CONSTRAINT [PK_dbo.AccessContext] PRIMARY KEY CLUSTERED ([AccessContextId] ASC)
);




GO
CREATE TRIGGER dbo.trgAccessContext_U 
ON dbo.[AccessContext] FOR update 
AS 
insert into audit.[AccessContext](
insert into audit.[AccessContext](
GO
CREATE TRIGGER dbo.trgAccessContext_I
ON dbo.[AccessContext] FOR insert 
AS 
insert into audit.[AccessContext](
GO
CREATE TRIGGER dbo.trgAccessContext_D
ON dbo.[AccessContext] FOR delete 
AS 
insert into audit.[AccessContext](