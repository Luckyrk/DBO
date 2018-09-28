
CREATE VIEW [dbo].[Groups]
AS
SELECT dbo.FullGroups.CountryISO2A
	,dbo.FullGroups.GroupId
	,dbo.FullGroups.Comments
	,dbo.FullGroups.KitType
	,dbo.FullGroups.GroupContact
	,dbo.FullGroups.HeadOfHousehold
	,dbo.FullGroups.MainShopper
	,dbo.FullGroups.ChiefIncomeEarner
	,dbo.FullGroups.MainContact
	,dbo.FullGroups.GeographicAreaCode
FROM dbo.FullGroups
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroups.CountryISO2A = dbo.CountryViewAccess.Country