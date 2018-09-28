
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[MainShoppersTW]
AS
SELECT [CountryISO2A]
	,[MainShopperId]
	,GroupId
	,[DateOfBirth]
	,[SexCode]
	,[SexDescription]
	,[TitleDescription]
	,[FirstOrderedName]
	,[PanelCode]
	,[PanelName]
	,[PanellistState]
	,[SignupDate]
	,[LiveDate]
FROM [dbo].[FullMainShoppersTW]
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainShoppersTW.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullMainShoppersTW.CountryISO2A = dbo.CountryViewAccess.Country