
CREATE VIEW [dbo].[GroupKitTypeGB]
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Panel.PanelCode
	,dbo.Panel.NAME PanelDesc
	,dbo.Panel.Type
	,CONVERT(VARCHAR, col.Sequence) GroupID
	,dbo.StockKit.Code KitType
	,dbo.StockKit.NAME KitDesc
FROM dbo.Panel
INNER JOIN dbo.Country ON dbo.Panel.Country_Id = dbo.Country.CountryId
INNER JOIN dbo.Panelist ON dbo.Panel.GUIDReference = dbo.Panelist.Panel_Id
LEFT JOIN dbo.StockKit ON dbo.Panelist.ExpectedKit_Id = dbo.StockKit.GUIDReference
INNER JOIN dbo.Collective col ON col.GUIDReference = dbo.Panelist.PanelMember_Id
WHERE dbo.Country.CountryISO2A = 'GB'