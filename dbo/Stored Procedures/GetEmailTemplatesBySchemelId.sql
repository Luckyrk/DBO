--Procedures Start
CREATE PROCEDURE [dbo].[GetEmailTemplatesBySchemelId] (
	@pschemeId INT
	,@pcountryId UNIQUEIDENTIFIER
	,@pPanelId UNIQUEIDENTIFIER
	)
AS
BEGIN
BEGIN TRY 
	IF (@pschemeId = 0)
	BEGIN
		SET @pschemeId = (
				SELECT TOP 1 TemplateMessageSchemeId
				FROM PanelTemplateMessageScheme
				WHERE panel_Id = @pPanelId
				)
	END

	SELECT DISTINCT TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateDefId
		,TemplateMessageDefinition.Description AS TemplateDescription
		,cmt.[Subject] AS [Subject]
	FROM TemplateMessageScheme
	INNER JOIN TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId
	INNER JOIN TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId = TI.TemplateUsageIntentId
	INNER JOIN TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
	INNER JOIN CommsMessageTemplateComponent cmt ON cmt.CommsMessageTemplateComponentId = tmc.CommsMessageTemplateComponentId
		AND cmt.CommsMessageTemplateSubTypeId = 2
		AND cmt.[Subject] IS NOT NULL
	WHERE tmc.CommsMessageTemplateTypeId = 1
		AND TemplateMessageScheme.TemplateMessageSchemeId = @pschemeId
		AND TemplateMessageScheme.CountryId = @pCountryId
		AND TemplateMessageDefinition.IsActive = 1
		AND tmc.ActiveTo IS NULL
		AND TI.TemplateUsageIntentId = 1
	ORDER BY TemplateDescription ASC

	SELECT TemplateMessageDefinitionId AS DefaultTemplateDefinitationId
	FROM DefaultTemplateScheme
	WHERE TemplateMessageSchemeId = @pschemeId

	IF (@pschemeId IS NULL)
	BEGIN
		SELECT 0 AS TemplateSchemeId
	END
	ELSE
	BEGIN
		SELECT @pschemeId AS TemplateSchemeId
	END

	SELECT tmc.TemplateMessageCategoryId AS DefaultTemplateCategoryId
	FROM (
		SELECT DISTINCT TemplateMessageCategoryId,TemplateMessageDefinitionId
		FROM TemplateMessageDefinition
		WHERE TemplateMessageSchemeId = @pschemeId
		) T
	INNER JOIN TemplateMessageCategories tmc ON tmc.TemplateMessageCategoryId = t.TemplateMessageCategoryId	
	INNER JOIN DefaultTemplateScheme DT ON DT.TemplateMessageSchemeId=@pschemeId and DT.TemplateMessageDefinitionId=T.TemplateMessageDefinitionId
	WHERE tmc.CountryId = @pcountryId
	ORDER BY DefaultTemplateCategoryId DESC
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END
