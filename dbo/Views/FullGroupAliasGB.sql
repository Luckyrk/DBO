
CREATE VIEW [dbo].[FullGroupAliasGB]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,[GroupId]
		,[Context]
		,[Alias]
	FROM [dbo].[FullGroupAliasAsRows]
	WHERE CountryISO2A = 'GB'
	) AS source
PIVOT(MAX([Alias]) FOR [Context] IN ([PetrolPanelAlias])) AS PivotTable