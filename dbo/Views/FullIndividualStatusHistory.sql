
CREATE VIEW [dbo].[FullIndividualStatusHistory]
AS
SELECT [dbo].Country.CountryISO2A
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
INNER JOIN [dbo].Country ON Country.CountryId = FromState.Country_Id ---inner join
INNER JOIN Individual ind ON ind.GUIDReference = sdh.Candidate_Id
WHERE Panelist_Id IS NULL