
CREATE VIEW [dbo].[ActionTasks]
AS
SELECT dbo.FullActionTasks.CountryISO2A
	,dbo.FullActionTasks.IndividualId
	,dbo.FullActionTasks.StartDate
	,dbo.FullActionTasks.EndDate
	,dbo.FullActionTasks.CompletionDate
	,dbo.FullActionTasks.ActionComment
	,dbo.FullActionTasks.InternalOrExternal
	,dbo.FullActionTasks.STATE
	,dbo.FullActionTasks.StateDescription
	,dbo.FullActionTasks.ActionCode
	,dbo.FullActionTasks.ActionDescription
	,dbo.FullActionTasks.IsForDpa
	,dbo.FullActionTasks.Type
	,dbo.FullActionTasks.PanelCode
	,dbo.FullActionTasks.PanelName
	,dbo.FullActionTasks.GPSUser
	,dbo.FullActionTasks.GPSUpdateTimestamp
	,dbo.FullActionTasks.CreationTimeStamp
FROM dbo.FullActionTasks
CROSS JOIN dbo.CountryViewAccess
WHERE (
		dbo.CountryViewAccess.UserId = SUSER_SNAME()
		AND dbo.FullActionTasks.CountryISO2A = dbo.CountryViewAccess.Country
		)