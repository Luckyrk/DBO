
CREATE VIEW [dbo].[StatesRate]
AS
SELECT p.Country_Id
	,tt1.CultureCode CultureCode1
	,tt2.CultureCode CultureCode2
	,p.CreationDate
	,p.GUIDReference
	,tt1.Value AS Country
	,panel.NAME AS Panel
	,panel.Total_Target_Population AS Total_Target
	,tt2.Value AS STATE
FROM panelist p
INNER JOIN Country c ON p.Country_Id = c.CountryId
INNER JOIN TranslationTerm tt1 ON c.TranslationId = tt1.Translation_Id
INNER JOIN Panel ON p.Panel_Id = panel.GUIDReference
	AND p.Country_Id = panel.Country_Id
INNER JOIN StateDefinition s ON p.State_Id = s.Id
	AND p.Country_Id = s.Country_Id
INNER JOIN TranslationTerm tt2 ON s.Label_Id = tt2.Translation_Id