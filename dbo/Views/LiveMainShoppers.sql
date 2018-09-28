
CREATE VIEW [dbo].[LiveMainShoppers]
AS
SELECT [CountryISO2A]
	,[GroupId]
	,[IndividualId]
	,[DateOfBirth]
	,[SexCode]
	,[SexDescription]
	,[TitleDescription]
	,[FirstOrderedName]
	,[LastOrderedName]
	,[PanelCode]
	,[PanelName]
	,[SignupDate]
	,[LiveDate]
	,[DroppedOffDate]
FROM [dbo].[FullLiveMainShoppers]
INNER JOIN dbo.CountryViewAccess ON dbo.FullLiveMainShoppers.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullLiveMainShoppers.CountryISO2A = dbo.CountryViewAccess.Country