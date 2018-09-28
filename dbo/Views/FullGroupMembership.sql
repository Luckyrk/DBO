CREATE VIEW [dbo].[FullGroupMembership]
	WITH SCHEMABINDING
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Collective.Sequence GroupId
	,dbo.Individual.IndividualId
	,dbo.StateDefinition.Code STATE
	,dbo.CollectiveMembership.SignUpDate
	,dbo.CollectiveMembership.DeletedDate
	,dbo.Collective.GPSUser
	,dbo.Collective.CreationTimeStamp
	,dbo.Collective.GPSUpdateTimestamp
	,sdh.CreationDate as ChangeDate
FROM dbo.Collective
INNER JOIN dbo.Candidate ON dbo.Collective.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.CollectiveMembership ON dbo.Collective.GUIDReference = dbo.CollectiveMembership.Group_Id
INNER JOIN dbo.Individual ON dbo.CollectiveMembership.Individual_Id = dbo.Individual.GUIDReference
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.StateDefinition ON dbo.StateDefinition.Id = dbo.CollectiveMembership.State_Id
INNER JOIN (
	SELECT MAX(CreationDate) CreationDate,GroupMembership_Id,To_Id 
	FROM dbo.StateDefinitionHistory 
	GROUP BY GroupMembership_Id,To_Id) sdh ON sdh.GroupMembership_Id = dbo.CollectiveMembership.CollectiveMembershipId AND sdh.To_Id = dbo.StateDefinition.Id