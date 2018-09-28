
CREATE VIEW [dbo].[CultureCodes]
AS
SELECT tt.CultureCode
	,CountryISO2A
	,tt.Value
FROM country c
INNER JOIN TranslationTerm tt ON c.TranslationId = tt.Translation_Id