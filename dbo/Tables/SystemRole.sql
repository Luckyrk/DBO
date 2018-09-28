﻿CREATE TABLE [dbo].[SystemRole] (
    [Id]          UNIQUEIDENTIFIER NOT NULL,
    [Description] NVARCHAR (50)    NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SystemRole] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgSystemRole_U 
ON dbo.[SystemRole] FOR update 
AS 
insert into audit.[SystemRole](
insert into audit.[SystemRole](
GO
CREATE TRIGGER dbo.trgSystemRole_I
ON dbo.[SystemRole] FOR insert 
AS 
insert into audit.[SystemRole](
GO
CREATE TRIGGER dbo.trgSystemRole_D
ON dbo.[SystemRole] FOR delete 
AS 
insert into audit.[SystemRole](