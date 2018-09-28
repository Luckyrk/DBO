
CREATE VIEW [dbo].[FullIndividualAliasTW]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,[IndividualId]
		,[Context]
		,[Alias]
	FROM [dbo].[FullIndividualAliasAsRows]
	WHERE CountryISO2A = 'TW'
	) AS source
PIVOT(MAX([Alias]) FOR [Context] IN (
			[QBu_ID_SSW]
			,[QBu_ID_BP]
			,[QBu_ID_MP]
			,[QB_u_ID_LP]
			,[EMC_id]
			,[PanelSmart_TW]
			)) AS PivotTable