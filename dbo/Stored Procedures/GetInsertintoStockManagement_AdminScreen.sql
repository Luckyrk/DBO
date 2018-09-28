Create PROCEDURE GetInsertintoStockManagement_AdminScreen @pStockCode VARCHAR(100)
	,@pAssetDescription VARCHAR(100)
	,@pQuantity INT
	,@pWarningLimit INT
	,@pCategoryCode VARCHAR(100)
	,@pcategoryname VARCHAR(max)
	,@pUserName VARCHAR(100)
	,@pCountryId UNIQUEIDENTIFIER
AS
SET NOCOUNT ON

BEGIN
BEGIN TRY
	DECLARE @pstockcategorytranid UNIQUEIDENTIFIER
	DECLARE @pstockbehaviourtranid UNIQUEIDENTIFIER
	DECLARE @pstockcategorytrim VARCHAR(50)
	DECLARE @pstockbehaviourtrim VARCHAR(50)
	DECLARE @pstockcategorys VARCHAR(50)
	DECLARE @pstockbehaviours VARCHAR(50)
	DECLARE @presandstocktypeidguid UNIQUEIDENTIFIER
	DECLARE @descriminator VARCHAR = 'StockType'
	DECLARE @pstockbehaviourguid UNIQUEIDENTIFIER
	DECLARE @pstockcategoryguid UNIQUEIDENTIFIER
	DECLARE @pstockcategorycode INT
	DECLARE @pstockcategoryguidea UNIQUEIDENTIFIER


 
SET @pstockbehaviours = @pAssetDescription + ' Behaviour'

DECLARE @GetDate DATETIME

SET @GetDate = (
		SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pCountryId)
		)

IF (@pstockbehaviours IS NOT NULL)
BEGIN
	SET @pstockbehaviourtrim = (
			SELECT REPLACE(@pstockbehaviours, ' ', '')
			)

	EXECUTE InsertTranslationValues @pstockbehaviourtrim
		,@pstockbehaviours
		,2057
		,@pUserName
		,'SystemTranslation'

	SET @pstockbehaviourtranid = (
			SELECT TranslationId
			FROM Translation
			WHERE [KEYNAME] = @pstockbehaviourtrim
			)

	IF (@pstockbehaviourtranid IS NOT NULL)
	BEGIN
		INSERT INTO StockBehavior
		VALUES (
			NEWID()
			,1
			,@pUserName
			,@GetDate
			,@GetDate
			,@pstockbehaviourtranid
			,@pCountryId
			)
	END

	SET @pstockbehaviourguid = (
			SELECT GUIDREFERENCE
			FROM StockBehavior
			WHERE Translation_Id = @pstockbehaviourtranid
				AND Country_Id = @pCountryId
			)
END

IF (@pCategoryCode IS NOT NULL)
BEGIN
	SET @pstockcategoryguid = (
			SELECT GUIDReference
			FROM StockCategory
			WHERE Code = @pCategoryCode
				AND Country_Id = @pCountryId
			)
		--SET @pstockcategoryguid = @pstockcategoryguidea
		--     select @pstockcategorytranid
END
ELSE IF (@pcategoryname IS NOT NULL)
BEGIN
	SET @pstockcategorys = @pcategoryname + ' Category'
	SET @pstockcategorytrim = (
			SELECT REPLACE(@pstockcategorys, ' ', '')
			)

	EXECUTE InsertTranslationValues @pstockcategorytrim
		,@pstockcategorys
		,2057
		,@pUserName
		,'SystemTranslation'

	SET @pstockcategorytranid = (
			SELECT TranslationId
			FROM Translation
			WHERE [KEYNAME] = @pstockcategorytrim
			)
	SET @pstockcategorycode = (
			SELECT max(code)
			FROM StockCategory
			WHERE Country_Id = @pCountryId
			) + 1

	INSERT INTO StockCategory
	VALUES (
		NEWID()
		,@pUserName
		,@GetDate
		,@GetDate
		,@pstockcategorytranid
		,@pCountryId
		,@pstockcategorycode
		)

	BEGIN
		SET @pstockcategoryguid = (
				SELECT GUIDREFERENCE
				FROM StockCategory
				WHERE Translation_Id = @pstockcategorytranid
					AND Country_Id = @pCountryId
				)
	END
END

SET @presandstocktypeidguid = NEWID()

IF (
		@presandstocktypeidguid IS NOT NULL
		AND @pStockCode IS NOT NULL
		AND @pCountryId IS NOT NULL
		)
BEGIN
	INSERT INTO Respondent
	VALUES (
		@presandstocktypeidguid
		,@descriminator
		,@pCountryId
		,@pUserName
		,@GetDate
		,@GetDate
		)

	INSERT INTO StockType
	VALUES (
		@presandstocktypeidguid
		,@pstockcategoryguid
		,@pstockbehaviourguid
		,@pStockCode
		,@pCountryId
		,@pAssetDescription
		,@pQuantity
		,@pWarningLimit
		,@pUserName
		,@GetDate
		,@GetDate
		,NULL
		)
END
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
	END