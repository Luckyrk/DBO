
CREATE VIEW [dbo].[MainShopperSummaryCount]
AS
SELECT [CountryISO2A]
	,[MainShopper]
	,[PanelCode]
	,[PanelName]
	,[CategoryCode]
	,[SummaryCount]
	,[CalendarId]
	,[CalendarTypePeriodId]
FROM [dbo].[FullMainShopperSummaryCount]
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainShopperSummaryCount.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullMainShopperSummaryCount.CountryISO2A = dbo.CountryViewAccess.Country