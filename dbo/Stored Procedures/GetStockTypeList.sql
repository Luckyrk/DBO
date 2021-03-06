CREATE PROCEDURE [dbo].[GetStockTypeList] @pCountryId UNIQUEIDENTIFIER
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
		,@op2 VARCHAR(50)
		,@op3 VARCHAR(50)
		,@op4 VARCHAR(50)
		,@op5 VARCHAR(50)
		,@op6 VARCHAR(50)
	DECLARE @AssetCode VARCHAR(500)
		,@AssetDescription VARCHAR(500)
		,@Category VARCHAR(500)
		,@RegisteredStock VARCHAR(500)
		,@UnRegisteredStock VARCHAR(500)
		,@WarningLimit VARCHAR(50)

	SELECT @op1 = Opertor
		,@AssetCode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Code'

	SELECT @op2 = Opertor
		,@AssetDescription = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Name'

	SELECT @op3 = Opertor
		,@Category = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'CategoryName'

	SELECT @op4 = Opertor
		,@RegisteredStock = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'RegisteredStock'

	SELECT @op5 = Opertor
		,@UnRegisteredStock = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'UnregisteredStock'

	SELECT @op6 = Opertor
		,@WarningLimit = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'WarningLimit'

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'Code'

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'DESC'

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
		SET @pPageSize = 15000

	IF (@pIsExport = 0)
	BEGIN
		SELECT COUNT(0)
		FROM (
			SELECT DISTINCT ST.GUIDReference AS [Id]
				,ST.CODE AS [Code]
				,ST.NAME AS [Name]
				,TT.VALUE AS [CategoryName]
				,STOCKTYPECOUNT.RegisteredStock AS [RegisteredStock]
				,ISNULL(ST.Quantity,0) - STOCKTYPECOUNT.RegisteredStock AS [UnregisteredStock]
				,ST.WarningLimit AS [WarningLimit]
			FROM STOCKTYPE ST
			JOIN STOCKCATEGORY SG ON ST.Category_Id = SG.GUIDReference
			JOIN TRANSLATION T ON T.TranslationId = SG.Translation_Id
			JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id
				AND TT.CULTURECODE = 2057
			JOIN Country c ON c.CountryId = ST.CountryId
				AND c.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
			LEFT JOIN (
				SELECT X.StockTypeId
					,ISNULL(x.GrossCount, 0) AS RegisteredStock
					,X.Quantity
				FROM (
					SELECT c.CountryISO2A
						,b.Code
						,b.NAME
						,b.Quantity
						,e.Location
						,count(*) AS GrossCount
						,b.GUIDReference AS StockTypeId
					FROM StockType b
					LEFT JOIN [StockItem] a ON b.GUIDReference = a.Type_Id
					JOIN Country c ON c.CountryId = b.CountryId
						AND c.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
					JOIN STOCKKITITEM SKI ON SKI.STOCKTYPE_ID = B.GUIDReference
					JOIN GenericStockLocation e ON e.GUIDReference = a.Location_Id
						AND e.Location = 'LAB'
					JOIN StateDefinition f ON f.Id = a.State_Id
						AND f.Code = ('AssetCommissioned')
					GROUP BY c.CountryISO2A
						,b.Code
						,b.NAME
						,b.Quantity
						,e.Location
						,SKI.GUIDReference
						,b.GUIDReference
					) x
				LEFT JOIN (
					SELECT c.CountryISO2A
						,f.Code
						,f.NAME
						,sum(b.Quantity) AS OrderedQuantity
					FROM [Order] a
					JOIN OrderItem b ON b.Order_Id = a.OrderId
					JOIN Country c ON c.CountryId = a.Country_Id
					JOIN StateDefinition d ON d.Id = a.State_Id
					JOIN StateModel e ON e.GUIDReference = d.StateModel_Id
						AND e.[Type] = 'Domain.PanelManagement.Orders.Order'
					JOIN StockType f ON f.GUIDReference = b.StockType_Id
					JOIN STOCKKITITEM SKI ON SKI.STOCKTYPE_ID = F.GUIDReference --AND SKI.StockKit_Id=@pKitId
					WHERE c.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
						AND d.Code <> 'OrderSentState'
					GROUP BY c.CountryISO2A
						,f.Code
						,f.NAME
						,SKI.GUIDReference
						,SKI.STOCKKIT_ID
					) y ON y.CountryISO2A = x.CountryISO2A
					AND y.Code = x.Code
					AND y.NAME = x.NAME
				) AS STOCKTYPECOUNT ON STOCKTYPECOUNT.StockTypeId = ST.GUIDReference
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Code = @AssetCode
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Code <> @AssetCode
					)
				OR (
					@op1 = @IsLessThan
					AND Code < @AssetCode
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Code <= @AssetCode
					)
				OR (
					@op1 = @IsGreaterThan
					AND Code > @AssetCode
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Code >= @AssetCode
					)
				OR (
					@op1 = @Contains
					AND Code LIKE '%' + @AssetCode + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Code NOT LIKE '%' + @AssetCode + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Code LIKE '' + @AssetCode + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Code LIKE '%' + @AssetCode + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND NAME = @AssetDescription
					)
				OR (
					@op2 = @IsNotEqualTo
					AND NAME <> @AssetDescription
					)
				OR (
					@op2 = @IsLessThan
					AND NAME < @AssetDescription
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND NAME <= @AssetDescription
					)
				OR (
					@op2 = @IsGreaterThan
					AND NAME > @AssetDescription
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND NAME >= @AssetDescription
					)
				OR (
					@op2 = @Contains
					AND NAME LIKE '%' + @AssetDescription + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND NAME NOT LIKE '%' + @AssetDescription + '%'
					)
				OR (
					@op2 = @StartsWith
					AND NAME LIKE '' + @AssetDescription + '%'
					)
				OR (
					@op2 = @EndsWith
					AND NAME LIKE '%' + @AssetDescription + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND CategoryName = @Category
					)
				OR (
					@op3 = @IsNotEqualTo
					AND CategoryName <> @Category
					)
				OR (
					@op3 = @IsLessThan
					AND CategoryName < @Category
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND CategoryName <= @Category
					)
				OR (
					@op3 = @IsGreaterThan
					AND CategoryName > @Category
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND CategoryName >= @Category
					)
				OR (
					@op3 = @Contains
					AND CategoryName LIKE '%' + @Category + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND CategoryName NOT LIKE '%' + @Category + '%'
					)
				OR (
					@op3 = @StartsWith
					AND CategoryName LIKE '' + @Category + '%'
					)
				OR (
					@op3 = @EndsWith
					AND CategoryName LIKE '%' + @Category + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND RegisteredStock = @RegisteredStock
					)
				OR (
					@op4 = @IsNotEqualTo
					AND RegisteredStock <> @RegisteredStock
					)
				OR (
					@op4 = @IsLessThan
					AND RegisteredStock < @RegisteredStock
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND RegisteredStock <= @RegisteredStock
					)
				OR (
					@op4 = @IsGreaterThan
					AND RegisteredStock > @RegisteredStock
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND RegisteredStock >= @RegisteredStock
					)
				OR (
					@op4 = @Contains
					AND RegisteredStock LIKE '%' + @RegisteredStock + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND RegisteredStock NOT LIKE '%' + @RegisteredStock + '%'
					)
				OR (
					@op4 = @StartsWith
					AND RegisteredStock LIKE '' + @RegisteredStock + '%'
					)
				OR (
					@op4 = @EndsWith
					AND RegisteredStock LIKE '%' + @RegisteredStock + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND UnregisteredStock = @UnRegisteredStock
					)
				OR (
					@op5 = @IsNotEqualTo
					AND UnregisteredStock <> @UnRegisteredStock
					)
				OR (
					@op5 = @IsLessThan
					AND UnregisteredStock < @UnRegisteredStock
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND UnregisteredStock <= @UnRegisteredStock
					)
				OR (
					@op5 = @IsGreaterThan
					AND UnregisteredStock > @UnRegisteredStock
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND UnregisteredStock >= @UnRegisteredStock
					)
				OR (
					@op5 = @Contains
					AND UnregisteredStock LIKE '%' + @UnRegisteredStock + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND UnregisteredStock NOT LIKE '%' + @UnRegisteredStock + '%'
					)
				OR (
					@op5 = @StartsWith
					AND UnregisteredStock LIKE '' + @UnRegisteredStock + '%'
					)
				OR (
					@op5 = @EndsWith
					AND UnregisteredStock LIKE '%' + @UnRegisteredStock + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND WarningLimit = @WarningLimit
					)
				OR (
					@op6 = @IsNotEqualTo
					AND WarningLimit <> @WarningLimit
					)
				OR (
					@op6 = @IsLessThan
					AND WarningLimit < @WarningLimit
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND WarningLimit <= @WarningLimit
					)
				OR (
					@op6 = @IsGreaterThan
					AND WarningLimit > @WarningLimit
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND WarningLimit >= @WarningLimit
					)
				OR (
					@op6 = @Contains
					AND WarningLimit LIKE '%' + @WarningLimit + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND WarningLimit NOT LIKE '%' + @WarningLimit + '%'
					)
				OR (
					@op6 = @StartsWith
					AND WarningLimit LIKE '' + @WarningLimit + '%'
					)
				OR (
					@op6 = @EndsWith
					AND WarningLimit LIKE '%' + @WarningLimit + ''
					)
				)
		OPTION (RECOMPILE)
	END

	SELECT *
	FROM (
		SELECT DISTINCT ST.GUIDReference AS [Id]
				,ST.CODE AS [Code]
				,ST.NAME AS [Name]
				,TT.VALUE AS [CategoryName]
				,STOCKTYPECOUNT.RegisteredStock AS [RegisteredStock]
				,ISNULL(ST.Quantity,0) - STOCKTYPECOUNT.RegisteredStock AS [UnregisteredStock]
				,ST.WarningLimit AS [WarningLimit]
			FROM STOCKTYPE ST
			JOIN STOCKCATEGORY SG ON ST.Category_Id = SG.GUIDReference
			JOIN TRANSLATION T ON T.TranslationId = SG.Translation_Id
			JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id
				AND TT.CULTURECODE = 2057
			JOIN Country c ON c.CountryId = ST.CountryId
				AND c.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
			LEFT JOIN (
				SELECT X.StockTypeId
					,ISNULL(x.GrossCount, 0) AS RegisteredStock
					,X.Quantity
				FROM (
					SELECT c.CountryISO2A
						,b.Code
						,b.NAME
						,b.Quantity
						,e.Location
						,count(*) AS GrossCount
						,b.GUIDReference AS StockTypeId
					FROM StockType b
					LEFT JOIN [StockItem] a ON b.GUIDReference = a.Type_Id
					JOIN Country c ON c.CountryId = b.CountryId
						AND c.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
					JOIN STOCKKITITEM SKI ON SKI.STOCKTYPE_ID = B.GUIDReference
					JOIN GenericStockLocation e ON e.GUIDReference = a.Location_Id
						AND e.Location = 'LAB'
					JOIN StateDefinition f ON f.Id = a.State_Id
						AND f.Code = ('AssetCommissioned')
					GROUP BY c.CountryISO2A
						,b.Code
						,b.NAME
						,b.Quantity
						,e.Location
						,SKI.GUIDReference
						,b.GUIDReference
					) x
				LEFT JOIN (
					SELECT c.CountryISO2A
						,f.Code
						,f.NAME
						,sum(b.Quantity) AS OrderedQuantity
					FROM [Order] a
					JOIN OrderItem b ON b.Order_Id = a.OrderId
					JOIN Country c ON c.CountryId = a.Country_Id
					JOIN StateDefinition d ON d.Id = a.State_Id
					JOIN StateModel e ON e.GUIDReference = d.StateModel_Id
						AND e.[Type] = 'Domain.PanelManagement.Orders.Order'
					JOIN StockType f ON f.GUIDReference = b.StockType_Id
					JOIN STOCKKITITEM SKI ON SKI.STOCKTYPE_ID = F.GUIDReference --AND SKI.StockKit_Id=@pKitId
					WHERE c.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
						AND d.Code <> 'OrderSentState'
					GROUP BY c.CountryISO2A
						,f.Code
						,f.NAME
						,SKI.GUIDReference
						,SKI.STOCKKIT_ID
					) y ON y.CountryISO2A = x.CountryISO2A
					AND y.Code = x.Code
					AND y.NAME = x.NAME
				) AS STOCKTYPECOUNT ON STOCKTYPECOUNT.StockTypeId = ST.GUIDReference
		) AS TEMPTABLE
	WHERE (
			(@op1 IS NULL)
			OR (
				@op1 = @IsEqualTo
				AND Code = @AssetCode
				)
			OR (
				@op1 = @IsNotEqualTo
				AND Code <> @AssetCode
				)
			OR (
				@op1 = @IsLessThan
				AND Code < @AssetCode
				)
			OR (
				@op1 = @IsLessThanOrEqualTo
				AND Code <= @AssetCode
				)
			OR (
				@op1 = @IsGreaterThan
				AND Code > @AssetCode
				)
			OR (
				@op1 = @IsGreaterThanOrEqualTo
				AND Code >= @AssetCode
				)
			OR (
				@op1 = @Contains
				AND Code LIKE '%' + @AssetCode + '%'
				)
			OR (
				@op1 = @DoesNotContain
				AND Code NOT LIKE '%' + @AssetCode + '%'
				)
			OR (
				@op1 = @StartsWith
				AND Code LIKE '' + @AssetCode + '%'
				)
			OR (
				@op1 = @EndsWith
				AND Code LIKE '%' + @AssetCode + ''
				)
			)
		AND (
			(@op2 IS NULL)
			OR (
				@op2 = @IsEqualTo
				AND NAME = @AssetDescription
				)
			OR (
				@op2 = @IsNotEqualTo
				AND NAME <> @AssetDescription
				)
			OR (
				@op2 = @IsLessThan
				AND NAME < @AssetDescription
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND NAME <= @AssetDescription
				)
			OR (
				@op2 = @IsGreaterThan
				AND NAME > @AssetDescription
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND NAME >= @AssetDescription
				)
			OR (
				@op2 = @Contains
				AND NAME LIKE '%' + @AssetDescription + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND NAME NOT LIKE '%' + @AssetDescription + '%'
				)
			OR (
				@op2 = @StartsWith
				AND NAME LIKE '' + @AssetDescription + '%'
				)
			OR (
				@op2 = @EndsWith
				AND NAME LIKE '%' + @AssetDescription + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 = @IsEqualTo
				AND CategoryName = @Category
				)
			OR (
				@op3 = @IsNotEqualTo
				AND CategoryName <> @Category
				)
			OR (
				@op3 = @IsLessThan
				AND CategoryName < @Category
				)
			OR (
				@op3 = @IsLessThanOrEqualTo
				AND CategoryName <= @Category
				)
			OR (
				@op3 = @IsGreaterThan
				AND CategoryName > @Category
				)
			OR (
				@op3 = @IsGreaterThanOrEqualTo
				AND CategoryName >= @Category
				)
			OR (
				@op3 = @Contains
				AND CategoryName LIKE '%' + @Category + '%'
				)
			OR (
				@op3 = @DoesNotContain
				AND CategoryName NOT LIKE '%' + @Category + '%'
				)
			OR (
				@op3 = @StartsWith
				AND CategoryName LIKE '' + @Category + '%'
				)
			OR (
				@op3 = @EndsWith
				AND CategoryName LIKE '%' + @Category + ''
				)
			)
		AND (
			(@op4 IS NULL)
			OR (
				@op4 = @IsEqualTo
				AND RegisteredStock = @RegisteredStock
				)
			OR (
				@op4 = @IsNotEqualTo
				AND RegisteredStock <> @RegisteredStock
				)
			OR (
				@op4 = @IsLessThan
				AND RegisteredStock < @RegisteredStock
				)
			OR (
				@op4 = @IsLessThanOrEqualTo
				AND RegisteredStock <= @RegisteredStock
				)
			OR (
				@op4 = @IsGreaterThan
				AND RegisteredStock > @RegisteredStock
				)
			OR (
				@op4 = @IsGreaterThanOrEqualTo
				AND RegisteredStock >= @RegisteredStock
				)
			OR (
				@op4 = @Contains
				AND RegisteredStock LIKE '%' + @RegisteredStock + '%'
				)
			OR (
				@op4 = @DoesNotContain
				AND RegisteredStock NOT LIKE '%' + @RegisteredStock + '%'
				)
			OR (
				@op4 = @StartsWith
				AND RegisteredStock LIKE '' + @RegisteredStock + '%'
				)
			OR (
				@op4 = @EndsWith
				AND RegisteredStock LIKE '%' + @RegisteredStock + ''
				)
			)
		AND (
			(@op5 IS NULL)
			OR (
				@op5 = @IsEqualTo
				AND UnregisteredStock = @UnRegisteredStock
				)
			OR (
				@op5 = @IsNotEqualTo
				AND UnregisteredStock <> @UnRegisteredStock
				)
			OR (
				@op5 = @IsLessThan
				AND UnregisteredStock < @UnRegisteredStock
				)
			OR (
				@op5 = @IsLessThanOrEqualTo
				AND UnregisteredStock <= @UnRegisteredStock
				)
			OR (
				@op5 = @IsGreaterThan
				AND UnregisteredStock > @UnRegisteredStock
				)
			OR (
				@op5 = @IsGreaterThanOrEqualTo
				AND UnregisteredStock >= @UnRegisteredStock
				)
			OR (
				@op5 = @Contains
				AND UnregisteredStock LIKE '%' + @UnRegisteredStock + '%'
				)
			OR (
				@op5 = @DoesNotContain
				AND UnregisteredStock NOT LIKE '%' + @UnRegisteredStock + '%'
				)
			OR (
				@op5 = @StartsWith
				AND UnregisteredStock LIKE '' + @UnRegisteredStock + '%'
				)
			OR (
				@op5 = @EndsWith
				AND UnregisteredStock LIKE '%' + @UnRegisteredStock + ''
				)
			)
		AND (
			(@op6 IS NULL)
			OR (
				@op6 = @IsEqualTo
				AND WarningLimit = @WarningLimit
				)
			OR (
				@op6 = @IsNotEqualTo
				AND WarningLimit <> @WarningLimit
				)
			OR (
				@op6 = @IsLessThan
				AND WarningLimit < @WarningLimit
				)
			OR (
				@op6 = @IsLessThanOrEqualTo
				AND WarningLimit <= @WarningLimit
				)
			OR (
				@op6 = @IsGreaterThan
				AND WarningLimit > @WarningLimit
				)
			OR (
				@op6 = @IsGreaterThanOrEqualTo
				AND WarningLimit >= @WarningLimit
				)
			OR (
				@op6 = @Contains
				AND WarningLimit LIKE '%' + @WarningLimit + '%'
				)
			OR (
				@op6 = @DoesNotContain
				AND WarningLimit NOT LIKE '%' + @WarningLimit + '%'
				)
			OR (
				@op6 = @StartsWith
				AND WarningLimit LIKE '' + @WarningLimit + '%'
				)
			OR (
				@op6 = @EndsWith
				AND WarningLimit LIKE '%' + @WarningLimit + ''
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'Code'
				AND @pOrderType = 'ASC'
				THEN Code
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Code'
				AND @pOrderType = 'DESC'
				THEN Code
			END DESC
		,CASE 
			WHEN @pOrderBy = 'Name'
				AND @pOrderType = 'ASC'
				THEN NAME
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Name'
				AND @pOrderType = 'DESC'
				THEN NAME
			END DESC
		,CASE 
			WHEN @pOrderBy = 'CategoryName'
				AND @pOrderType = 'ASC'
				THEN CategoryName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'CategoryName'
				AND @pOrderType = 'DESC'
				THEN CategoryName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'RegisteredStock'
				AND @pOrderType = 'ASC'
				THEN RegisteredStock
			END ASC
		,CASE 
			WHEN @pOrderBy = 'RegisteredStock'
				AND @pOrderType = 'DESC'
				THEN RegisteredStock
			END DESC
		,CASE 
			WHEN @pOrderBy = 'UnregisteredStock'
				AND @pOrderType = 'ASC'
				THEN UnregisteredStock
			END ASC
		,CASE 
			WHEN @pOrderBy = 'UnregisteredStock'
				AND @pOrderType = 'DESC'
				THEN UnregisteredStock
			END DESC
		,CASE 
			WHEN @pOrderBy = 'WarningLimit'
				AND @pOrderType = 'ASC'
				THEN WarningLimit
			END ASC
		,CASE 
			WHEN @pOrderBy = 'WarningLimit'
				AND @pOrderType = 'DESC'
				THEN WarningLimit
			END DESC OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)
END
