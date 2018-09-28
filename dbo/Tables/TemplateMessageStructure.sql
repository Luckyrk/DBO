﻿CREATE TABLE [dbo].[TemplateMessageStructure] (
    [TemplateMessageStructureId]          BIGINT NOT NULL,
    [TemplateMessageSchemeId]             INT    NOT NULL,
    [TemplateMessageDefinitionId]         BIGINT NOT NULL,
    [CommsMessageTemplateTypeId]          INT    NOT NULL,
    [CommsMessageTemplateComponentTypeId] INT    NOT NULL,
    [CommsMessageTemplateSubTypeId]       INT    NOT NULL,
    [ComponentSequence]                   INT    NOT NULL,
    [IsIncluded]                          BIT    NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TemplateMessageStructure] PRIMARY KEY CLUSTERED ([TemplateMessageStructureId] ASC),
    CONSTRAINT [FK_dbo.TemplateMessageStructure_dbo.CommsMessageTemplateComponentType_CommsMessageTemplateTypeId_CommsMessageTemplateComponentTy] FOREIGN KEY ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]) REFERENCES [dbo].[CommsMessageTemplateComponentType] ([CommsMessageTemplateTypeId], [CommsMessageTemplateComponentTypeId]),
    CONSTRAINT [FK_dbo.TemplateMessageStructure_dbo.CommsMessageTemplateSubType_CommsMessageTemplateSubTypeId_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateSubTypeId], [CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateSubType] ([CommsMessageTemplateSubTypeId], [CommsMessageTemplateTypeId]),
    CONSTRAINT [FK_dbo.TemplateMessageStructure_dbo.CommsMessageTemplateType_CommsMessageTemplateTypeId] FOREIGN KEY ([CommsMessageTemplateTypeId]) REFERENCES [dbo].[CommsMessageTemplateType] ([CommsMessageTemplateTypeId]),
    CONSTRAINT [FK_dbo.TemplateMessageStructure_dbo.TemplateMessageDefinition_TemplateMessageDefinitionId_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageDefinitionId], [TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageDefinition] ([TemplateMessageDefinitionId], [TemplateMessageSchemeId]),
    CONSTRAINT [FK_dbo.TemplateMessageStructure_dbo.TemplateMessageScheme_TemplateMessageSchemeId] FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageStructure]([TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TemplateMessageDefinitionId_TemplateMessageSchemeId]
    ON [dbo].[TemplateMessageStructure]([TemplateMessageDefinitionId] ASC, [TemplateMessageSchemeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId]
    ON [dbo].[TemplateMessageStructure]([CommsMessageTemplateTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateTypeId_CommsMessageTemplateComponentTypeId]
    ON [dbo].[TemplateMessageStructure]([CommsMessageTemplateTypeId] ASC, [CommsMessageTemplateComponentTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CommsMessageTemplateSubTypeId_CommsMessageTemplateTypeId]
    ON [dbo].[TemplateMessageStructure]([CommsMessageTemplateSubTypeId] ASC, [CommsMessageTemplateTypeId] ASC);


GO
CREATE TRIGGER dbo.trgTemplateMessageStructure_U 
ON dbo.[TemplateMessageStructure] FOR update 
AS 
insert into audit.[TemplateMessageStructure](
insert into audit.[TemplateMessageStructure](
GO
CREATE TRIGGER dbo.trgTemplateMessageStructure_I
ON dbo.[TemplateMessageStructure] FOR insert 
AS 
insert into audit.[TemplateMessageStructure](
GO
CREATE TRIGGER dbo.trgTemplateMessageStructure_D
ON dbo.[TemplateMessageStructure] FOR delete 
AS 
insert into audit.[TemplateMessageStructure](