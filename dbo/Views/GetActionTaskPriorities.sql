CREATE VIEW GetActionTaskPriorities
AS
SELECT Id as  Code,  dbo.GetTranslationValue(ATP.Translation_Id, 3082) as Name,CountryISO2A
FROM ActionTaskPriorities ATP 
INNER JOIN Country C ON C.CountryId=ATP.CountryId