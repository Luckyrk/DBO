
CREATE VIEW [dbo].[GetStockItemStatus]
AS
SELECT C.CountryISO2A
	,Code
FROM StateDefinition SD
INNER JOIN StateModel SM
INNER JOIN Country C ON C.CountryId = SM.Country_Id ON SD.StateModel_Id = SM.GUIDReference
	AND Lower(SM.Type) = 'domain.panelmanagement.assets.stockitem'