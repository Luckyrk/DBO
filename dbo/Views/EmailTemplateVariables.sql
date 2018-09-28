
CREATE VIEW [dbo].[EmailTemplateVariables]
AS
SELECT [CountryISO2A]
	,[TemplateId]
	,[TemplateDescription]
	,[VariableNo]
	,[VariableName]
FROM [dbo].[FullEmailTemplateVariables]
INNER JOIN dbo.CountryViewAccess ON dbo.FullEmailTemplateVariables.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullEmailTemplateVariables.CountryISO2A = dbo.CountryViewAccess.Country