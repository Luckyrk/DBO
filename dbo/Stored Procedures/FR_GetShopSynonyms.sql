CREATE PROCEDURE FR_GetShopSynonyms (@pShopCode INT)
AS
BEGIN
	SELECT CreationTimeStamp
		,shop_code AS ShopCode
		,shop_shortname AS ShopShortName
		,syn_dt_insert
		,syn_libelle AS ShopSynonymLabel
		,syn_libelle AS OldShopSynonymLabel
	FROM frs.SYNONYMES_SHOP
	WHERE shop_code = @pShopCode
END