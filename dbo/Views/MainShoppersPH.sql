
CREATE VIEW [dbo].[MainShoppersPH]
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
FROM [dbo].[FullMainShoppersPH]
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainShoppersPH.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullMainShoppersPH.CountryISO2A = dbo.CountryViewAccess.Country