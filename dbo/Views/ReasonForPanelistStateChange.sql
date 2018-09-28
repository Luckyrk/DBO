CREATE VIEW ReasonForPanelistStateChange
AS
SELECT c.CountryISO2A
	,rcs.Code
	,tt.Value
	,sdfrom.Code AS FromState
	,sd.Code AS ToState
FROM ReasonForChangeState rcs
INNER JOIN StateModel sm ON sm.GUIDReference = rcs.StateModel_Id
INNER JOIN TranslationTerm tt ON tt.Translation_Id = rcs.Description_Id
	AND tt.CultureCode = 2057
INNER JOIN ReasonForChangeStateAvailableTransition rca ON rca.ReasonForChangeState_Id = rcs.Id
INNER JOIN StateTransition st ON st.Id = rca.AvailableTransition_Id
INNER JOIN StateDefinition sdfrom ON sdfrom.Id = st.FromState_Id
INNER JOIN StateDefinition sd ON sd.Id = st.ToState_Id
INNER JOIN Country c ON c.CountryId = sm.Country_Id
WHERE sm.[Type] = 'Domain.PanelManagement.Candidates.Panelist'