
CREATE VIEW [dbo].[FullIndividualAliasMY]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,[IndividualId]
		,[Context]
		,[Alias]
		,[GPSUser]
		,[CreationTimeStamp]
		,[GPSUpdateTimestamp]
	FROM [dbo].[FullIndividualAliasAsRows]
	WHERE CountryISO2A = 'MY'
	) AS source
PIVOT(MAX([Alias]) FOR [Context] IN (
			[PanelSmart_MY]
			)) AS PivotTable