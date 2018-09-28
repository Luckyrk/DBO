﻿CREATE TABLE [dbo].[CommsMessageTemplateSubType] (
    [CommsMessageTemplateSubTypeId] INT           NOT NULL,
    [CommsMessageTemplateTypeId]    INT           NOT NULL,
    [Description]                   NVARCHAR (50) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CommsMessageTemplateSubType] PRIMARY KEY CLUSTERED ([CommsMessageTemplateSubTypeId] ASC, [CommsMessageTemplateTypeId] ASC),
    CONSTRAINT [FK_dbo.CommsMessageTemplateSubType_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[CommsMessageTemplateSubType]([CommsMessageTemplateTypeId] ASC);


GO
CREATE TRIGGER dbo.trgCommsMessageTemplateSubType_U 
ON dbo.[CommsMessageTemplateSubType] FOR update 
AS 
insert into audit.[CommsMessageTemplateSubType](
insert into audit.[CommsMessageTemplateSubType](
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateSubType_I
ON dbo.[CommsMessageTemplateSubType] FOR insert 
AS 
insert into audit.[CommsMessageTemplateSubType](
GO
CREATE TRIGGER dbo.trgCommsMessageTemplateSubType_D
ON dbo.[CommsMessageTemplateSubType] FOR delete 
AS 
insert into audit.[CommsMessageTemplateSubType](