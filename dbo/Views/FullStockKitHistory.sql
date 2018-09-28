
CREATE VIEW [dbo].[FullStockKitHistory]
AS
SELECT ct.CountryISO2A
	,skf.Code FromCode
	,skf.NAME FromName
	,skt.Code ToCode
	,skt.NAME ToName
	,rea.Code ReasonCode
	,rtr.KeyName ReasonDescription
	,skh.[Panelist_Id]
	,pan.PanelCode
	,skh.[GPSUser]
	,skh.[GPSUpdateTimestamp]
	,skh.[CreationTimeStamp] --select count(1)
	,skt.GUIDReference
FROM [dbo].[StockKitHistory] skh
LEFT JOIN dbo.country ct ON skh.Country_Id = ct.CountryId
LEFT JOIN dbo.stockKit skt ON skt.GUIDReference = skh.To_Id
LEFT JOIN dbo.stockKit skf ON skf.GUIDReference = skh.From_Id
LEFT JOIN dbo.panelist pst ON pst.GUIDReference = skh.Panelist_Id
LEFT JOIN dbo.ReasonForStockKitChange rea ON rea.Id = skh.Reason_Id
LEFT JOIN dbo.translation rtr ON rtr.TranslationId = rea.Description_Id
LEFT JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
LEFT JOIN dbo.StockKitItem ski ON ski.StockKit_Id = skt.GUIDReference