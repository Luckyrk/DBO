
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[QuotaManagementTW]
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
FROM [dbo].[FullQuotaManagementTW]
INNER JOIN dbo.CountryViewAccess ON dbo.FullQuotaManagementTW.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullQuotaManagementTW.CountryISO2A = dbo.CountryViewAccess.Country