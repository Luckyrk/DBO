
CREATE VIEW [dbo].[FullGroupAliasFR]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,[GroupId]
		,[Context]
		,[Alias]
	FROM [dbo].[FullGroupAliasAsRows]
	WHERE CountryISO2A = 'FR'
	) AS source
PIVOT(MAX([Alias]) FOR [Context] IN ([AliasLoadingFR])) AS PivotTable