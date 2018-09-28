
CREATE VIEW [dbo].[QuotaManagementPH]
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
FROM [dbo].[FullQuotaManagementPH]
INNER JOIN dbo.CountryViewAccess ON dbo.FullQuotaManagementPH.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullQuotaManagementPH.CountryISO2A = dbo.CountryViewAccess.Country