
CREATE VIEW [dbo].[DynamicRoles]
AS
SELECT [CountryISO2A]
	,[Code]
	,[RoleName]
	,[GroupId]
	,[IndividualId]
	,[PanelCode]
	,[PanelName]
	,[PanelMemberId]
FROM [dbo].[FullDynamicRoles]
INNER JOIN dbo.CountryViewAccess ON dbo.FullDynamicRoles.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullDynamicRoles.CountryISO2A = dbo.CountryViewAccess.Country