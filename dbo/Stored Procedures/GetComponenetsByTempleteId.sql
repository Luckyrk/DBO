CREATE PROCEDURE GetComponenetsByTempleteId (@ptempalteDefinitionId BIGINT)
AS
BEGIN
		SELECT tmc.CommsMessageTemplateComponentTypeId as Id,
		      ctc.TextContent as Name,
			  ctc.[Subject],
			  tms.Email as FromEmail
		FROM TemplateMessageDefinition tmd
		INNER JOIN TemplateMessageConfiguration tmc ON tmd.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
		INNER JOIN TemplateMessageScheme tms ON tms.TemplateMessageSchemeId = tmd.TemplateMessageSchemeId
		INNER JOIN CommsMessageTemplateComponent ctc ON tmc.CommsMessageTemplateComponentId = ctc.CommsMessageTemplateComponentId
			AND tmc.CommsMessageTemplateTypeId = ctc.CommsMessageTemplateTypeId
			AND tmc.CommsMessageTemplateSubTypeId = ctc.CommsMessageTemplateSubTypeId
		WHERE tmd.TemplateMessageDefinitionId = @ptempalteDefinitionId
END