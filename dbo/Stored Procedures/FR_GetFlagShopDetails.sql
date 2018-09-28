CREATE PROCEDURE [dbo].[FR_GetFlagShopDetails] (@pShopCode INT)
AS
BEGIN
	SELECT DISTINCT shop_code AS ShopCode
		,s.flag_attribut AS AttributeId
		,sa.flag_detail AS AttributeName
		,s.flag_valeur AS AttributeValId
		,s.flag_valeur AS OldAttributeValId
	FROM frs.FLAGS_SHOP s
	INNER JOIN frs.SHOPS_ATTRIBUTE sa ON s.flag_attribut = sa.flag_attribut
	WHERE shop_code = @pShopCode

	SELECT DISTINCT s.flag_attribut AS AttributeId
		,sad.flag_valeur AS AttributeValueId
		,sad.flag_detail AS AttributeValueDetail
	FROM frs.FLAGS_SHOP s
	INNER JOIN frs.SHOPS_ATTRIBUTE sa ON s.flag_attribut = sa.flag_attribut
	INNER JOIN frs.FLAGS_DETAIL sad ON sa.flag_attribut = sad.flag_attribut
	WHERE shop_code = @pShopCode
END