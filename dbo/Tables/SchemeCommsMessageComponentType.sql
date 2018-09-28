﻿CREATE TABLE [dbo].[SchemeCommsMessageComponentType] (
    [SchemeCommsMessageComponentTypeId]   BIGINT NOT NULL,
    [CommsMessageTemplateComponentTypeId] INT    NOT NULL,
    [TemplateMessageSchemeId]             INT    NOT NULL,
    [CommsMessageTemplateTypeId]          INT    NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SchemeCommsMessageComponentType] PRIMARY KEY CLUSTERED ([SchemeCommsMessageComponentTypeId] ASC),
    CONSTRAINT [FK_dbo.SchemeCommsMessageComponentType_dbo.CommsMessageTemplateComponentType_CommsMessageTemplateTypeId_CommsMessageTemplateComp] FOREIGN KEY ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]) REFERENCES [dbo].[CommsMessageTemplateComponentType] ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]),
    CONSTRAINT [FK_dbo.SchemeCommsMessageComponentType_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId]),
    CONSTRAINT [FK_dbo.SchemeCommsMessageComponentType_dbo.TemplateMessageScheme_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId_CommsMessageTemplateComponentTypeId]
    ON [dbo].[SchemeCommsMessageComponentType]([CommsMessageTemplateTypeId] ASC, [CommsMessageTemplateComponentTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageSchemeId]
    ON [dbo].[SchemeCommsMessageComponentType]([TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[SchemeCommsMessageComponentType]([CommsMessageTemplateTypeId] ASC);


GO
CREATE TRIGGER dbo.trgSchemeCommsMessageComponentType_U 
ON dbo.[SchemeCommsMessageComponentType] FOR update 
AS 
insert into audit.[SchemeCommsMessageComponentType](
insert into audit.[SchemeCommsMessageComponentType](
GO
CREATE TRIGGER dbo.trgSchemeCommsMessageComponentType_I
ON dbo.[SchemeCommsMessageComponentType] FOR insert 
AS 
insert into audit.[SchemeCommsMessageComponentType](
GO
CREATE TRIGGER dbo.trgSchemeCommsMessageComponentType_D
ON dbo.[SchemeCommsMessageComponentType] FOR delete 
AS 
insert into audit.[SchemeCommsMessageComponentType](