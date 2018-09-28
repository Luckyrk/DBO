
CREATE VIEW [dbo].[PanellistEligibilityView]
AS
SELECT [CountryISO2A]
	,[PanelCode]
	,[PanelName]
	,[PanelMemberID]
	,[GroupID]
	,[IsEligible]
	,[Year]
	,[PeriodValue]
	,[PeriodType]
	,[EligibilityFailureReason]
	,[DemographicWeight]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
FROM dbo.FullPanellistEligibilityView
INNER JOIN dbo.CountryViewAccess ON dbo.FullPanellistEligibilityView.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanellistEligibilityView.CountryISO2A = dbo.CountryViewAccess.Country