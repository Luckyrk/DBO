
CREATE VIEW [dbo].[QuotaManagementMY]
AS
SELECT [CountryISO2A]
	,[MainShopperId]
	,[DateOfBirth]
	,[PanelCode]
	,[PanelName]
	,[CollaborationMethodology]
	,[PanellistState]
	,[SignupDate]
	,[Region]
	,[Habitat]
	,[HouseholdSizeNew]
	,[LifeStageNew]
	,[FamilyMonthlyIncome]
	,[Occupation]
FROM [dbo].[FullQuotaManagementMY]
INNER JOIN dbo.CountryViewAccess ON dbo.FullQuotaManagementMY.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullQuotaManagementMY.CountryISO2A = dbo.CountryViewAccess.Country