CREATE PROCEDURE [dbo].[USP_FRSHOPSAVE] (
	@pShopCode INT
	,@pShopType VARCHAR(10)
	,@pShopLongName VARCHAR(50)
	,@pShopShortName VARCHAR(30)
	,@pChannel VARCHAR(100)
	,@pShopFermetureDate DATETIME
	,@pShopUpdateDate DATETIME
	,@pShopOuverturedate DATETIME
	,@pShopCodePalm INT
	,@pShopCodeH14 INT
	,@pGpsUser VARCHAR(200)
	,@pOperation VARCHAR(2)
	,@pShopFlagDetails [dbo].[ShopFlagDetailsTable] READONLY
	,@pShopSynonyms ShopSynonymTable READONLY
	)
AS
BEGIN
	DECLARE @Getdate DATETIME 
		SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),'FR'))

	DECLARE @defaultDate DATETIME =CAST('9999-12-31' AS DATETIME)
	

	IF (@pOperation = 'I')
	BEGIN
		INSERT INTO FRS.SHOP (
			shop_code
			,shop_type
			,shop_longname
			,shop_shortname
			,shop_dt_fermeture
			,shop_dt_update
			,shop_dt_ouverture
			,shop_code_palm
			,shop_code_H14
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		VALUES (
			@pShopCode
			,@pShopType
			,@pShopLongName
			,@pShopShortName
			,@pShopFermetureDate
			,@pShopUpdateDate
			,@pShopOuverturedate
			,@pShopCodePalm
			,@pShopCodeH14
			,@pGpsUser
			,@Getdate
			,@Getdate
			)

		INSERT INTO FRS.APPARTENIR_CIR_SHOP (
			shop_code
			,civ_cd_circ_vente
			,dt_rattachement
			,dt_fin_rattachement
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		VALUES (
			@pShopCode
			,@pChannel
			,@pShopOuverturedate
			,@defaultDate
			,@pGpsUser
			,@Getdate
			,@Getdate
			)

		--Insert AttributeFlags
		INSERT INTO frs.FLAGS_SHOP (
			shop_code
			,flag_attribut
			,flag_valeur
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		SELECT [ShopCode]
			,[FlagId]
			,[FlagValue]
			,@pGpsUser
			,@Getdate
			,@Getdate
		FROM @pShopFlagDetails

		--Insert Synonyms
		INSERT INTO FRS.SYNONYMES_SHOP (
			shop_shortname
			,syn_libelle
			,shop_code
			,syn_dt_insert
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		SELECT @pShopShortName
			,[Synonym]
			,@pShopCode
			,@Getdate
			,@pGpsUser
			,@Getdate
			,@Getdate
		FROM @pShopSynonyms
	END
	ELSE IF (@pOperation = 'U')
	BEGIN
		UPDATE FRS.SHOP
		SET shop_type = @pShopType
			,shop_longname = @pShopLongName
			,shop_shortname = @pShopShortName
			,shop_dt_fermeture = @pShopFermetureDate
			,shop_dt_update = @pShopUpdateDate
			,shop_dt_ouverture = @pShopOuverturedate
			,shop_code_palm = @pShopCodePalm
			,shop_code_H14 = @pShopCodeH14
			,GPSUser = @pGpsUser
			,GPSUpdateTimestamp = @Getdate
		WHERE shop_code = @pShopCode

		IF NOT EXISTS (
			SELECT 1
			FROM frs.APPARTENIR_CIR_SHOP
			WHERE civ_cd_circ_vente = @pChannel
				AND shop_code = @pShopCode
			)
		BEGIN
			DECLARE @finisheddate DATETIME

			SET @finisheddate = @pShopUpdateDate - 1

			UPDATE frs.APPARTENIR_CIR_SHOP
			SET dt_fin_rattachement = @finisheddate
			WHERE shop_code = (
					SELECT TOP 1 shop_code
					FROM frs.APPARTENIR_CIR_SHOP
					where shop_code=@pShopCode
					ORDER BY creationtimestamp DESC
					)

			INSERT INTO frs.APPARTENIR_CIR_SHOP (
				shop_code
				,civ_cd_circ_vente
				,dt_rattachement
				,dt_fin_rattachement
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				)
			VALUES (
				@pShopCode
				,@pChannel
				,@pShopUpdateDate
				,@defaultDate
				,@pGpsUser
				,@Getdate
				,@Getdate
				)
		END

		-- Remove AttributeFlags
		DELETE fs FROM frs.FLAGS_SHOP fs
		INNER JOIN @pShopFlagDetails sf ON fs.shop_code = sf.ShopCode
			AND fs.flag_attribut = sf.FlagId AND fs.flag_valeur=sf.OldFlagValue
		WHERE sf.RecordType = 'R'

		--Insert AttributeFlags
		INSERT INTO frs.FLAGS_SHOP (
			shop_code
			,flag_attribut
			,flag_valeur
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		SELECT [ShopCode]
			,[FlagId]
			,[FlagValue]
			,@pGpsUser
			,@Getdate
			,@Getdate
		FROM @pShopFlagDetails
		WHERE RecordType = 'I'

		-- Update AttributeFlags
		update fs set fs.flag_valeur=sf.FlagValue
		FROM frs.FLAGS_SHOP fs
		INNER JOIN @pShopFlagDetails sf ON fs.shop_code = sf.ShopCode
			AND fs.flag_attribut = sf.FlagId AND fs.flag_valeur=sf.OldFlagValue
		WHERE sf.RecordType = 'U'

		-- update the Synonms
		UPDATE sy
		SET sy.syn_libelle = ps.[Synonym]
		FROM frs.SYNONYMES_SHOP sy
		INNER JOIN @pShopSynonyms ps ON sy.shop_code = @pShopCode
			AND sy.shop_shortname = ps.shopshortname
			AND sy.syn_libelle = ps.OldSynonym
		WHERE ps.RecordType = 'U'

		-- Remove Synonm
		DELETE fs
		FROM FRS.SYNONYMES_SHOP fs
		INNER JOIN @pShopSynonyms sf ON fs.shop_shortname = sf.shopshortname
			AND fs.syn_libelle = sf.[Synonym]
		WHERE sf.RecordType = 'R'

		-- Insert Synonms
		INSERT INTO FRS.SYNONYMES_SHOP (
			shop_shortname
			,syn_libelle
			,shop_code
			,syn_dt_insert
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		SELECT @pShopShortName
			,[Synonym]
			,@pShopCode
			,@Getdate
			,@pGpsUser
			,@Getdate
			,@Getdate
		FROM @pShopSynonyms
		WHERE RecordType = 'I'
	END
END