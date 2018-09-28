
CREATE VIEW [dbo].[StateDefinitionList]
AS
SELECT sm.[Type]
	,sd.Code
	,c.CountryISO2A
FROM StateDefinition sd
INNER JOIN StateModel sm ON sm.GUIDReference = sd.StateModel_Id
INNER JOIN Country c ON c.CountryId = sm.Country_Id