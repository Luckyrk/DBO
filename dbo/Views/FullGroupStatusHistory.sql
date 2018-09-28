
CREATE VIEW [dbo].[FullGroupStatusHistory]
AS
SELECT [dbo].Country.CountryISO2A
	,col.Sequence
	,sdh.GPSUser
	,sdh.CreationDate [Date]
	,FromState.Code FromState
	,ToState.Code ToState
	,Reason.Code ReasonCode
FROM [dbo].StateDefinitionHistory sdh
INNER JOIN [dbo].StateDefinition AS FromState ON sdh.From_Id = FromState.Id
INNER JOIN [dbo].StateDefinition AS ToState ON sdh.To_Id = ToState.Id
LEFT JOIN [dbo].ReasonForChangeState AS Reason ON Reason.Id = sdh.ReasonForchangeState_Id
INNER JOIN Candidate can ON can.GUIDReference = sdh.Candidate_Id
INNER JOIN [dbo].Country ON Country.CountryId = can.Country_Id ---inner join
INNER JOIN Collective col ON col.GUIDReference = sdh.Candidate_Id
WHERE Panelist_Id IS NULL