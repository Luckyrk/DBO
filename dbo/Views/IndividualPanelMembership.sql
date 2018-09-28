
CREATE VIEW [dbo].[IndividualPanelMembership]
AS
SELECT [CountryISO2A]
	,[PanelCode]
	,[PanelName]
	,[IndividualId]
FROM [dbo].[FullIndividualPanelMembership]
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualPanelMembership.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullIndividualPanelMembership.CountryISO2A = dbo.CountryViewAccess.Country