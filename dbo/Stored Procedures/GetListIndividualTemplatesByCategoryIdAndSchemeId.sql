CREATE PROCEDURE GetListIndividualTemplatesByCategoryIdAndSchemeId (
	@pCategoryId BIGINT
	,@pschemeId INT
	)
AS
BEGIN
	SELECT DISTINCT tmd.TemplateMessageDefinitionId  AS TemplateDefId
		,tmd.Description AS TemplateDescription
	FROM TemplateMessageDefinition tmd
	INNER JOIN TemplateMessageConfiguration tmc ON tmd.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
	WHERE tmd.TemplateMessageCategoryId = @pCategoryId
		AND tmd.TemplateMessageSchemeId = @pschemeId
		AND tmd.TemplateUsageIntentId = 1
		AND tmc.CommsMessageTemplateTypeId = 1
		AND tmc.ActiveTo IS NULL
		AND tmd.IsActive = 1
	ORDER BY tmd.Description
END