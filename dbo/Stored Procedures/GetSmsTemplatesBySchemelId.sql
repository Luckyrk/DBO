


CREATE PROCEDURE [dbo].[GetSmsTemplatesBySchemelId] (
	@pCountryId UNIQUEIDENTIFIER
	,@pschemeId INT
	,@pPanelId UNIQUEIDENTIFIER
	)
AS
BEGIN

 IF (@pschemeId = 0)
       BEGIN
              SET @pschemeId = (
                           SELECT TOP 1 TemplateMessageSchemeId
                           FROM PanelTemplateMessageScheme
                           WHERE panel_Id = @pPanelId
                           )
       END
	
				SELECT DISTINCT TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateId,TemplateMessageDefinition.Description AS TemplateDescription
					
				FROM TemplateMessageScheme
				INNER JOIN TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId
				INNER JOIN TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId = TI.TemplateUsageIntentId
				INNER JOIN TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
				WHERE tmc.CommsMessageTemplateTypeId = 2
					AND TemplateMessageScheme.TemplateMessageSchemeId = @pschemeId
					AND TemplateMessageScheme.CountryId = @pCountryId 
					And TemplateMessageDefinition.IsActive=1
					AND TI.TemplateUsageIntentId=1
					And  tmc.ActiveTo is NULL
					If(@pschemeId is null)
	   begin
       SELECT 0 AS TemplateSchemeId
	   END
	   ELSE
	   BEGIN
	     SELECT @pschemeId AS TemplateSchemeId
	   END
			
END