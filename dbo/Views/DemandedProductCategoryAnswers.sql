
CREATE VIEW [dbo].[DemandedProductCategoryAnswers]
AS
SELECT [CountryISO2A]
	,[AnswerCatCode]
	,[AnswerCatDescription]
	,[IgnoreCall]
	,[AskAgainInterval]
	,[ProductCode]
FROM [dbo].[FullDemandedProductCategoryAnswers]
INNER JOIN dbo.CountryViewAccess ON dbo.FullDemandedProductCategoryAnswers.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullDemandedProductCategoryAnswers.CountryISO2A = dbo.CountryViewAccess.Country