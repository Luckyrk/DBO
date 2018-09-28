
CREATE VIEW [dbo].[CultureCodes2]
AS
SELECT tt.CultureCode
	,CountryId
	,tt.Value
FROM country c
INNER JOIN TranslationTerm tt ON c.TranslationId = tt.Translation_Id