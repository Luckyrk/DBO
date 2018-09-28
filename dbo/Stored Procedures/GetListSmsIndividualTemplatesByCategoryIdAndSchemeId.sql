

CREATE PROCEDURE [dbo].[GetListSmsIndividualTemplatesByCategoryIdAndSchemeId] (

	@pCategoryId BIGINT

	,@pschemeId INT

	)

AS

BEGIN
BEGIN TRY 
if(@pschemeId<>0 AND @pCategoryId <>0)
BEGIN
	SELECT DISTINCT tmd.TemplateMessageDefinitionId  AS TemplateDefId

		,tmd.Description AS TemplateDescription

	FROM TemplateMessageDefinition tmd

	INNER JOIN TemplateMessageConfiguration tmc ON tmd.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId

	WHERE tmd.TemplateMessageCategoryId = @pCategoryId

		AND tmd.TemplateMessageSchemeId = @pschemeId

		AND tmd.TemplateUsageIntentId = 1

		AND tmc.CommsMessageTemplateTypeId = 2

		AND tmc.ActiveTo IS NULL

		AND tmd.IsActive = 1

	ORDER BY tmd.Description
	END
	ELSE if(@pschemeId=0 AND @pCategoryId <>0)
	BEGIN
	SELECT DISTINCT tmd.TemplateMessageDefinitionId  AS TemplateDefId

		,tmd.Description AS TemplateDescription

	FROM TemplateMessageDefinition tmd

	INNER JOIN TemplateMessageConfiguration tmc ON tmd.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId

	WHERE tmd.TemplateMessageCategoryId = @pCategoryId
		AND tmd.TemplateUsageIntentId = 1
		AND tmc.CommsMessageTemplateTypeId = 2

		AND tmc.ActiveTo IS NULL

		AND tmd.IsActive = 1
	END
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END