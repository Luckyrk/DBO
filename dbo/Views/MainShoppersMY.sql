
CREATE VIEW [dbo].[MainShoppersMY]
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
FROM [dbo].[FullMainShoppersMY]
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainShoppersMY.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullMainShoppersMY.CountryISO2A = dbo.CountryViewAccess.Country