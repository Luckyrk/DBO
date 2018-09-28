
CREATE VIEW [dbo].[PanelMembersMY]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[DateOfBirth]
	,[SexCode]
	,[SexDescription]
	,[TitleDescription]
	,[FirstOrderedName]
	,[PanelCode]
	,[PanelName]
	,[PanellistState]
	,[MainShopperId]
	,[SignupDate]
	,[LiveDate]
FROM [dbo].[FullPanelMembersMY]
INNER JOIN dbo.CountryViewAccess ON dbo.FullPanelMembersMY.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanelMembersMY.CountryISO2A = dbo.CountryViewAccess.Country