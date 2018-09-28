
CREATE VIEW [dbo].[GetActionCodes]
AS
SELECT c.CountryISO2A
	,ATT.ActionCode AS ActionCode
	,tt.KeyName AS ActionTask
FROM ActionTaskType ATT
INNER JOIN Country C ON c.CountryId = ATT.Country_Id
INNER JOIN Translation tt ON att.DescriptionTranslation_Id = tt.TranslationId