
CREATE VIEW [dbo].[StockKits]
AS
SELECT Code
	,NAME
	,CountryISO2A AS CountryCode
	,CONVERT(VARCHAR(10), sc.Code) + ' -' + sc.NAME AS StockKit
FROM StockKit sc
INNER JOIN country c ON sc.Country_Id = c.CountryId