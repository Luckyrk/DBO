CREATE TABLE [dbo].[DefaultTemplateScheme] (
    [TemplateMessageSchemeId]     INT    NOT NULL,
    [TemplateMessageDefinitionId] BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED ([TemplateMessageSchemeId] ASC, [TemplateMessageDefinitionId] ASC),
    FOREIGN KEY ([TemplateMessageSchemeId]) REFERENCES [dbo].[TemplateMessageScheme] ([TemplateMessageSchemeId])
);

