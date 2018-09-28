
CREATE VIEW [dbo].[PanellistSet]
AS
SELECT dbo.FullPanellistSet.CountryISO2A
	,dbo.FullPanellistSet.PanelCode
	,dbo.FullPanellistSet.PanelDesc
	,dbo.FullPanellistSet.Type
	,dbo.FullPanellistSet.PanelMemberID
	,dbo.FullPanellistSet.GroupID
	,dbo.FullPanellistSet.KitType
	,dbo.FullPanellistSet.KitCode
	,dbo.FullPanellistSet.MainContact
	,dbo.FullPanellistSet.PanLevelMainShopper
	,dbo.FullPanellistSet.PanLevelHeadOfHousehold
	,dbo.FullPanellistSet.IndividualUnderStudy
	,dbo.FullPanellistSet.StateCode
	,dbo.FullPanellistSet.SignupDate
	,dbo.FullPanellistSet.InterestedDate
	,dbo.FullPanellistSet.PreLiveDate
	,dbo.FullPanellistSet.LiveDate
	,dbo.FullPanellistSet.DroppedOffDate
	,dbo.FullPanellistSet.RefusalDate
	,dbo.FullPanellistSet.CollabCode
	,dbo.FullPanellistSet.CollabDesc
	,dbo.FullPanellistSet.IncentiveCode
	,dbo.FullPanellistSet.GPSUser
	,dbo.FullPanellistSet.GPSUpdateTimestamp
	,dbo.FullPanellistSet.CreationTimeStamp
FROM dbo.FullPanellistSet
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanellistSet.CountryISO2A = dbo.CountryViewAccess.Country