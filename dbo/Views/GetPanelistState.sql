
CREATE VIEW [dbo].[GetPanelistState]
AS
SELECT CountryISO2A
	,Code
FROM StateDefinition SD
INNER JOIN StateModel SM
INNER JOIN Country C ON C.CountryId = SM.Country_Id ON SD.StateModel_Id = SM.GUIDReference
	AND Lower(SM.Type) = 'domain.panelmanagement.candidates.panelist'