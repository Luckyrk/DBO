CREATE PROCEDURE [dbo].[FR_GetLibelliShopSiasiNonReduitList] @pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10) -- ASC OR DESC
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable READONLY
AS
BEGIN
	DECLARE @op1 VARCHAR(50)
	DECLARE @Libelle_Saisi VARCHAR(500)
	DECLARE @LogicalOperator4 VARCHAR(5)
	DECLARE @Secondop4 VARCHAR(50)
	DECLARE @SecondDate DATE

	SELECT @op1 = Opertor
		,@Libelle_Saisi = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Libelle_Saisi'

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'Libelle_Saisi'

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'ASC'

	DECLARE @OFFSETRows INT = 0
	DECLARE @IsLessThan VARCHAR(50) = 'IsLessThan'
		,@IsLessThanOrEqualTo VARCHAR(50) = 'IsLessThanOrEqualTo'
		,@IsEqualTo VARCHAR(50) = 'IsEqualTo'
		,@IsNotEqualTo VARCHAR(50) = 'IsNotEqualTo'
		,@IsGreaterThanOrEqualTo VARCHAR(50) = 'IsGreaterThanOrEqualTo'
		,@IsGreaterThan VARCHAR(50) = 'IsGreaterThan'
		,@StartsWith VARCHAR(50) = 'StartsWith'
		,@EndsWith VARCHAR(50) = 'EndsWith'
		,@Contains VARCHAR(50) = 'Contains'
		,@IsContainedIn VARCHAR(50) = 'IsContainedIn'
		,@DoesNotContain VARCHAR(50) = 'DoesNotContain'

	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 150000

	IF OBJECT_ID('tempdb.dbo.#tmpLibelle') IS NOT NULL 
		DROP TABLE #tmpLibelle

	SELECT * INTO #tmpLibelle
	FROM (
		SELECT DISTINCT SI.libelle_saisi AS Libelle_Saisi	
		FROM FRS.LIBELLE_SHOP_SAISI_NON_REDUIT SI
		JOIN [FRS].[SHOP] SH ON SI.shop_code = SH.shop_code
		WHERE LTRim(RTRIM(SI.libelle_saisi)) NOT IN (SELECT LTRim(RTRIM(syn_libelle)) FROM [FRS].[SYNONYMES_SHOP])) AS SUB	
	WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Libelle_Saisi = @Libelle_Saisi
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Libelle_Saisi <> @Libelle_Saisi
					)
				OR (
					@op1 = @IsLessThan
					AND Libelle_Saisi < @Libelle_Saisi
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Libelle_Saisi <= @Libelle_Saisi
					)
				OR (
					@op1 = @IsGreaterThan
					AND Libelle_Saisi > @Libelle_Saisi
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Libelle_Saisi >= @Libelle_Saisi
					)
				OR (
					@op1 = @Contains
					AND Libelle_Saisi LIKE '%' + @Libelle_Saisi + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Libelle_Saisi NOT LIKE '%' + @Libelle_Saisi + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Libelle_Saisi LIKE '' + @Libelle_Saisi + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Libelle_Saisi LIKE '%' + @Libelle_Saisi + ''
					)
				)
			


	IF (@pIsExport = 0)
	BEGIN
		SELECT COUNT(0)
		FROM #tmpLibelle		
		OPTION (RECOMPILE)
	END

	SELECT *
	FROM #tmpLibelle
	ORDER BY CASE 
			WHEN @pOrderBy = 'Libelle_Saisi'
				AND @pOrderType = 'ASC'
				THEN Libelle_Saisi
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Libelle_Saisi'
				AND @pOrderType = 'DESC'
				THEN Libelle_Saisi
			END DESC
		OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)
END

