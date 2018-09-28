
CREATE VIEW [dbo].[PanelTargets]
AS
SELECT [CountryISO2A]
	,[PanelCode]
	,[PanelName]
	,[TotalTargetPopulation]
	,[TargetName]
	,[Target]
	,[CellDescription]
	,[Dimension1]
	,[Dimension2]
FROM [dbo].[FullPanelTargets]
INNER JOIN dbo.CountryViewAccess ON dbo.FullPanelTargets.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanelTargets.CountryISO2A = dbo.CountryViewAccess.Country