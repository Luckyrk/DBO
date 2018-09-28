
CREATE VIEW [dbo].[GroupPanelMembership]
AS
SELECT [CountryISO2A]
	,[PanelCode]
	,[PanelName]
	,[GroupId]
FROM [dbo].[FullGroupPanelMembership]
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupPanelMembership.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroupPanelMembership.CountryISO2A = dbo.CountryViewAccess.Country