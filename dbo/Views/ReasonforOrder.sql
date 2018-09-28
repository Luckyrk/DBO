Create view ReasonforOrder
as
SELECT c.CountryISO2A
	,ot.Code AS Ordercode
	,ttorder.Value AS OrderDescription
	,rfo.Code AS ReasonCode
	,tt.Value AS OrderReason
FROM ReasonForOrderType rfo
INNER JOIN TranslationTerm tt ON tt.Translation_Id = rfo.Description_Id
	AND tt.CultureCode = 2057
INNER JOIN OrderType ot ON ot.Id = rfo.OrderType_Id
INNER JOIN TranslationTerm ttorder ON ttorder.Translation_Id = ot.Description_Id
	AND ttorder.CultureCode = 2057
INNER JOIN Country c ON c.CountryId = rfo.Country_Id