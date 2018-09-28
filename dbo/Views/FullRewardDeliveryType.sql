
CREATE VIEW [dbo].[FullRewardDeliveryType]
AS
SELECT [Code]
	,c.CultureCode
	,c.Value
	,[AffectsAccountBalance]
	,[IsFirstDelivery]
FROM [RewardDeliveryType] a
INNER JOIN TranslationTerm c ON c.Translation_Id = a.Translation_Id
	AND c.CultureCode = 2057