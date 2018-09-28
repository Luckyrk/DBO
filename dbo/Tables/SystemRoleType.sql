﻿CREATE TABLE [dbo].[SystemRoleType] (
    [SystemRoleTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SystemRoleType] PRIMARY KEY CLUSTERED ([SystemRoleTypeId] ASC)
);




GO
CREATE TRIGGER dbo.trgSystemRoleType_U 
ON dbo.[SystemRoleType] FOR update 
AS 
insert into audit.[SystemRoleType](
insert into audit.[SystemRoleType](
GO
CREATE TRIGGER dbo.trgSystemRoleType_I
ON dbo.[SystemRoleType] FOR insert 
AS 
insert into audit.[SystemRoleType](
GO
CREATE TRIGGER dbo.trgSystemRoleType_D
ON dbo.[SystemRoleType] FOR delete 
AS 
insert into audit.[SystemRoleType](