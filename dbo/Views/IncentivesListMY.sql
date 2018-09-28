CREATE VIEW [dbo].[IncentivesListMY]
AS
/**************************************************************************************************
PF 18/01: Created this Country specific View as MY want to link this to Panel via PanelPoint. 
They only have a 1 to 1 relationship with IncentivePoint/Panel so it is possible to add the join to Panel via PanelPoint
Other Countries do not maintain this 1 to 1 relationship can cannot apply this join
****************************************************************************************************/
SELECT iaet.[Type]
	,iaet.Code AS TypeCode
	,t.Value AS TypeDescription
	,c.CountryISO2A AS CountryCode
	,ip.Code AS IncentiveCode
	,ip.RewardCode
	,ip.[Type] AS PointType
	,tpointdesc.Value PointDescription
	,ip.ValidFrom
	,ip.ValidTo
	,p.PanelCode
	,p.Name
	,ip.[CostPrice]
	,ip.[RewardSource]
	,ip.[HasStockControl]
	,ip.[StockLevel]
	,ip.[GiftPrice]
	,ip.[Minimum]
	,ip.[Maximum]
	,s.[Code] SupplierCode
	,s.[Description] SupplierDescription
	,ip.Value AS Point
FROM IncentivePointAccountEntryType iaet
INNER JOIN IncentivePoint ip ON ip.[Type_Id] = iaet.GUIDReference
LEFT JOIN IncentiveSupplier AS s ON s.IncentiveSupplierId = ip.SupplierId
INNER JOIN country c ON c.CountryId = iaet.Country_Id
INNER JOIN TranslationTerm t ON (
		t.Translation_Id = iaet.TypeName_Id
		AND t.CultureCode = 2057
		)
INNER JOIN TranslationTerm tpointdesc ON (
		tpointdesc.Translation_Id = ip.Description_Id
		AND tpointdesc.CultureCode = 2057
		)
INNER JOIN PanelPoint pp ON ip.GUIDReference = pp.Point_Id
INNER JOIN Panel p ON pp.Panel_Id = p.GUIDReference
WHERE CountryISO2A = 'MY'
GO

