
CREATE VIEW [dbo].[FullIndividualAliasGB]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,[IndividualId]
		,[Context]
		,[Alias]
	FROM [dbo].[FullIndividualAliasAsRows]
	WHERE CountryISO2A = 'GB'
	) AS source
PIVOT(MAX([Alias]) FOR [Context] IN (
			[FoodOnTheGoAlias]
			,[LifestyleQuestbackAlias]
			)) AS PivotTable