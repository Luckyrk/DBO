
CREATE VIEW [dbo].[GetGeographicAreaCode]
AS
SELECT c.CountryISO2A
	,tt.value
	,ga.Code
FROM GeographicArea ga
INNER JOIN Respondent r ON r.GUIDReference = ga.GUIDReference
INNER JOIN Country C ON c.CountryId = r.CountryID
INNER JOIN Translation t ON t.TranslationId = ga.Translation_Id
INNER JOIN TranslationTerm tt ON tt.Translation_Id = t.TranslationId