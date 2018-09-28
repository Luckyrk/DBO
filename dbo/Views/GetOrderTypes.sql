
CREATE VIEW [dbo].[GetOrderTypes]
AS
SELECT c.CountryISO2A,  o.Code Code
	,t.Value Value
FROM orderType o
INNER JOIN Translationterm t ON o.Description_Id = t.Translation_Id
join Country c on c.CountryId=o.Country_Id
WHERE t.CultureCode = 2057