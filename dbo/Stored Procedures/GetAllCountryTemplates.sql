

CREATE PROCEDURE [dbo].[GetAllCountryTemplates] (

	@pCountrtId UNIQUEIDENTIFIER

	
	)

AS

BEGIN


	SELECT DISTINCT tmd.TemplateMessageDefinitionId  AS TemplateDefId

		,tmd.Description AS TemplateDescription

	FROM TemplateMessageDefinition tmd

	INNER JOIN TemplateMessageConfiguration tmc ON tmd.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
	INNER JOIN TemplateMessageScheme ts on tmd.TemplateMessageSchemeId =ts.TemplateMessageSchemeId 
	WHERE ts.CountryId  = @pCountrtId

		

		AND tmd.TemplateUsageIntentId = 1

		AND tmc.CommsMessageTemplateTypeId = 2

		AND tmc.ActiveTo IS NULL

		AND tmd.IsActive = 1

	ORDER BY tmd.Description
	END