
CREATE VIEW [dbo].[PanelMembersPH]
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
FROM [dbo].[FullPanelMembersPH]
INNER JOIN dbo.CountryViewAccess ON dbo.FullPanelMembersPH.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanelMembersPH.CountryISO2A = dbo.CountryViewAccess.Country