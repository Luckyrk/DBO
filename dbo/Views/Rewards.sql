
CREATE VIEW [dbo].[Rewards]
AS
SELECT [type]
	,i.StockLevel
	,t.CultureCode
	,c.CountryISO2A
	,r.DiscriminatorType
	,i.Code
	,i.Value AS Points
	,t.Value AS Description
FROM IncentivePoint i
INNER JOIN translationterm t ON i.Description_Id = t.Translation_Id
INNER JOIN respondent r ON i.GUIDReference = r.GUIDReference
INNER JOIN Country c ON r.CountryID = c.CountryId