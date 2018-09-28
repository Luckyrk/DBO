
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[PanelMembersTW]
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
FROM [dbo].[FullPanelMembersTW]
INNER JOIN dbo.CountryViewAccess ON dbo.FullPanelMembersTW.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanelMembersTW.CountryISO2A = dbo.CountryViewAccess.Country