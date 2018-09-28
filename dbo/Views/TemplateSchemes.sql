
CREATE VIEW [dbo].[TemplateSchemes]
AS
SELECT ts.TemplateMessageSchemeId AS SchemeId
	,ts.Description
	,c.CountryISO2A AS CountryCode
FROM TemplateMessageScheme ts
INNER JOIN Country c ON c.CountryId = ts.CountryId