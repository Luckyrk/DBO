

--exec GetUnmtachedSmsTemplatesBySchemelId '17d348d8-a08d-ce7a-cb8c-08cf81794a86','8977558207'

CREATE PROCEDURE [dbo].[GetUnmtachedSmsTemplatesBySchemelId] (

	@pCountryId UNIQUEIDENTIFIER

	,@pUnmatchedemailid NVARCHAR(200)

	)

AS

BEGIN
BEGIN TRY 
	DECLARE @schemeId AS INT



	SET @schemeId = (

			SELECT Ad.Scheme_Id

			FROM Address A

			INNER JOIN AddressDomain AD ON A.GUIDReference = AD.AddressId

			WHERE A.AddressLine1 = @pUnmatchedemailid

				AND CountryId = @pCountryId

			)
	
	IF(@schemeId  IS NULL)
	BEGIN
		SELECT DISTINCT TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateId

		,TemplateMessageDefinition.Description AS TemplateDescription

	FROM TemplateMessageScheme

	INNER JOIN TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId

	INNER JOIN TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId = TI.TemplateUsageIntentId

	INNER JOIN TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId

	WHERE tmc.CommsMessageTemplateTypeId = 2

	

		AND TemplateMessageScheme.CountryId = @pCountryId

		AND TemplateMessageDefinition.IsActive = 1

		AND tmc.ActiveTo is NULL

		AND TI.TemplateUsageIntentId=1

	ORDER BY TemplateMessageDefinition.Description
	END
	ELSE
	BEGIN
	SELECT DISTINCT TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateId

		,TemplateMessageDefinition.Description AS TemplateDescription

	FROM TemplateMessageScheme

	INNER JOIN TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId

	INNER JOIN TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId = TI.TemplateUsageIntentId

	INNER JOIN TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId

	WHERE tmc.CommsMessageTemplateTypeId = 2

		AND TemplateMessageScheme.TemplateMessageSchemeId = @schemeId

		AND TemplateMessageScheme.CountryId = @pCountryId

		AND TemplateMessageDefinition.IsActive = 1

		AND tmc.ActiveTo is NULL

		AND TI.TemplateUsageIntentId=1

	ORDER BY TemplateMessageDefinition.Description

	END





	


	IF (@schemeId IS NOT NULL)

	BEGIN

		SELECT @schemeId AS TemplateSchemeId;

	END

	ELSE

	BEGIN

		SELECT 0 AS TemplateSchemeId;

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