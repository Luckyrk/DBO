
CREATE VIEW [dbo].[FullGroupMembershipHistory]
AS
SELECT --COUNT(1)
	[dbo].Country.CountryISO2A
	,col.Sequence
	,ind.IndividualId
	,sdh.GPSUser
	,sdh.CreationDate [Date]
	,FromState.Code FromState
	,ToState.Code ToState
	,Reason.Code ReasonCode
FROM [dbo].StateDefinitionHistory sdh
INNER JOIN [dbo].StateDefinition AS FromState ON sdh.From_Id = FromState.Id
INNER JOIN [dbo].StateDefinition AS ToState ON sdh.To_Id = ToState.Id
LEFT JOIN [dbo].ReasonForChangeState AS Reason ON Reason.Id = sdh.ReasonForchangeState_Id
INNER JOIN CollectiveMembership cmem ON cmem.CollectiveMembershipId = sdh.GroupMembership_Id
INNER JOIN [dbo].Country ON Country.CountryId = sdh.Country_Id
INNER JOIN Collective col ON col.GUIDReference = cmem.Group_Id
INNER JOIN Individual ind ON ind.GUIDReference = cmem.Individual_Id
WHERE groupmembership_id IS NOT NULL