

CREATE PROCEDURE [dbo].[GetTemplatesBySchemelId] (
	@pCountryId UNIQUEIDENTIFIER
	,@pUnmatchedemailid NVARCHAR(200)
	)
AS
BEGIN
	DECLARE @schemeId AS INT

	SET @schemeId = (
			SELECT Ad.Scheme_Id
			FROM Address A
			INNER JOIN AddressDomain AD ON A.GUIDReference = AD.AddressId
			WHERE A.AddressLine1 = @pUnmatchedemailid
				AND CountryId = @pCountryId
			)

	SELECT DISTINCT TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateDefId
		,TemplateMessageDefinition.Description AS TemplateDescription
				FROM TemplateMessageScheme
				INNER JOIN TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId
				INNER JOIN TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId = TI.TemplateUsageIntentId
				INNER JOIN TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
				WHERE tmc.CommsMessageTemplateTypeId = 1
					AND TemplateMessageScheme.TemplateMessageSchemeId = @schemeId
					AND TemplateMessageScheme.CountryId = @pCountryId
		AND TemplateMessageDefinition.IsActive = 1
		AND tmc.ActiveTo is NULL
		AND TI.TemplateUsageIntentId=1
	ORDER BY TemplateMessageDefinition.Description
			
	SELECT TemplateMessageDefinitionId AS DefaultTemplateDefinitationId
	FROM DefaultTemplateScheme
	WHERE TemplateMessageSchemeId = @schemeId
	
	IF (@schemeId IS NOT NULL)
	BEGIN
		SELECT @schemeId AS TemplateSchemeId;
	END
	ELSE
	BEGIN
		SELECT 0 AS TemplateSchemeId;
	END
END