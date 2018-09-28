
CREATE VIEW [dbo].[RewardDeliveryTypes]
AS
SELECT r.Code
	,t.KeyName AS RewardDeliveryType
FROM RewardDeliveryType r
INNER JOIN Translation t ON t.TranslationId = r.Translation_Id