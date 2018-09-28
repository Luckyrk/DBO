
CREATE VIEW [dbo].[FullIndividualAliasVN] AS 
SELECT * FROM (	SELECT [CountryISO2A], [IndividualId], [Context], [Alias]
				FROM [dbo].[FullIndividualAliasAsRows] WHERE CountryISO2A = 'VN'
) AS source PIVOT(MAX([Alias]) FOR [Context] IN ([PanelSmart_VN])) AS PivotTable
GO

