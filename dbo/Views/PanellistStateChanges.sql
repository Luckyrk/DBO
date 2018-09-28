
CREATE VIEW [dbo].[PanellistStateChanges]
AS
SELECT dbo.FullPanellistStateChanges.CountryISO2A
	,dbo.FullPanellistStateChanges.PanelMemberID
	,dbo.FullPanellistStateChanges.PanelCode
	,dbo.FullPanellistStateChanges.PanelName
	,dbo.FullPanellistStateChanges.Type
	,dbo.FullPanellistStateChanges.[Date]
	,dbo.FullPanellistStateChanges.FromState
	,dbo.FullPanellistStateChanges.ToState
	,dbo.FullPanellistStateChanges.ReasonCode
	,dbo.FullPanellistStateChanges.GPSUser
FROM dbo.FullPanellistStateChanges
INNER JOIN dbo.CountryViewAccess ON dbo.FullPanellistStateChanges.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullPanellistStateChanges.CountryISO2A = dbo.CountryViewAccess.Country