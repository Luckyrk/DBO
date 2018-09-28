
CREATE VIEW [dbo].[CollaborationMethodologySet]
AS
SELECT c.CountryISO2A AS countrycode
	,cm.Code
	,t.KeyName
FROM CollaborationMethodology cm
INNER JOIN country c ON c.CountryId = cm.Country_Id
INNER JOIN translation t ON t.TranslationId = cm.TranslationId