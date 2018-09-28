﻿CREATE TABLE [dbo].[CommsMessageTemplateType] (
    [CommsMessageTemplateTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [Description]                NVARCHAR (50) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CommsMessageTemplateType] PRIMARY KEY CLUSTERED ([CommsMessageTemplateTypeId] ASC)
);








GO
CREATE TRIGGER dbo.trgCommsMessageTemplateType_U 
ON dbo.[CommsMessageTemplateType] FOR update 
AS 
insert into audit.[CommsMessageTemplateType](
insert into audit.[CommsMessageTemplateType](
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateType_I
ON dbo.[CommsMessageTemplateType] FOR insert 
AS 
insert into audit.[CommsMessageTemplateType](
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateType_D
ON dbo.[CommsMessageTemplateType] FOR delete 
AS 
insert into audit.[CommsMessageTemplateType](