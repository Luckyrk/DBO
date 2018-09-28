﻿CREATE TABLE [dbo].[AttributeScope] (
    [GUIDReference]    UNIQUEIDENTIFIER NOT NULL,
    [Type]             NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.AttributeScope] PRIMARY KEY CLUSTERED ([GUIDReference] ASC)
);
GO

CREATE TRIGGER dbo.trgAttributeScope_U 
ON dbo.[AttributeScope] FOR update 
AS 
insert into audit.[AttributeScope](
insert into audit.[AttributeScope](
GO
CREATE TRIGGER dbo.trgAttributeScope_I
ON dbo.[AttributeScope] FOR insert 
AS 
insert into audit.[AttributeScope](
GO
CREATE TRIGGER dbo.trgAttributeScope_D
ON dbo.[AttributeScope] FOR delete 
AS 
insert into audit.[AttributeScope](