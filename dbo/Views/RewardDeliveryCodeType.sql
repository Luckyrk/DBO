
CREATE VIEW [dbo].[RewardDeliveryCodeType]
	WITH SCHEMABINDING
AS
SELECT r.RewardDeliveryTypeID
	,r.Code AS DeliveryCode
	,trd.KeyName AS DeliveryDescription
FROM dbo.RewardDeliveryType r
INNER JOIN dbo.Translation trd ON r.Translation_Id = trd.TranslationId