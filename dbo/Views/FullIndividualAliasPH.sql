CREATE VIEW [dbo].[FullIndividualAliasPH]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,[IndividualId]
		,[Context]
		,[Alias]
	FROM [dbo].[FullIndividualAliasAsRows]
	WHERE CountryISO2A = 'PH'
	) AS source
PIVOT(MAX([Alias]) FOR [Context] IN (
			[PanelSmart_PH]
			)) AS PivotTable
