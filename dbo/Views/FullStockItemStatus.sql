
CREATE VIEW [dbo].[FullStockItemStatus]
AS
SELECT CT.CountryISO2A
	,SI.SerialNumber
	,I.IndividualId AS IndividualId
	,pnl.PanelCode
	,SI.Description AS StockDescription
	,GSL.Location
	,SDH.GPSUpdateTimestamp as StateTransitionDate
	,SDH.CreationDate AS StateTransitionCreationDate
	,SD.Code AS CurrentStockState
FROM StockItem SI
INNER JOIN StockStateDefinitionHistory SSDH ON SI.GUIDReference = SSDH.StockItem_Id
INNER JOIN StateDefinitionHistory SDH ON SSDH.GUIDReference = SDH.GUIDReference
INNER JOIN StateDefinition SD ON SDH.To_Id = SD.Id
INNER JOIN Country CT ON CT.CountryId = SDH.Country_Id
LEFT JOIN GenericStockLocation GSL ON GSL.GUIDReference = SSDH.Location_Id
LEFT JOIN StockLocation SL ON SL.GUIDReference = SSDH.Location_Id
LEFT JOIN StockPanelistLocation SPL ON SL.GUIDReference = SPL.GUIDReference
LEFT JOIN Panelist P ON SPL.Panelist_Id = P.GUIDReference
LEFT JOIN Panel pnl ON p.Panel_Id = pnl.GUIDReference
LEFT JOIN Candidate C ON P.PanelMember_Id = C.GUIDReference
LEFT JOIN Individual I ON C.GUIDReference = I.GUIDReference
RIGHT JOIN (
	SELECT SI.SerialNumber
		,MAX(SDH.GPSUpdateTimestamp) AS TransDate
	FROM StockItem SI
	INNER JOIN StockStateDefinitionHistory SSDH ON SI.GUIDReference = SSDH.StockItem_Id
	INNER JOIN StateDefinitionHistory SDH ON SSDH.GUIDReference = SDH.GUIDReference
	GROUP BY SI.SerialNumber
	) AS History ON SDH.GPSUpdateTimestamp = History.TransDate
	AND History.SerialNumber = SI.SerialNumber