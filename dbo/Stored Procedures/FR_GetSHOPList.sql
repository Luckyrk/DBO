GO
CREATE PROCEDURE [dbo].[FR_GetSHOPList] @pCountryId UNIQUEIDENTIFIER
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
		,@op7 VARCHAR(50)
		,@op8 VARCHAR(50)
	DECLARE @LogicalOperator4 VARCHAR(5)
		,@LogicalOperator8 VARCHAR(5)
	DECLARE @Secondop4 VARCHAR(50)
		,@Secondop8 VARCHAR(50)
	DECLARE @SecondClosedDate DATE
		,@SecondUpdatedDate DATE
	DECLARE @ShopCode INT
		,@LongName VARCHAR(500)
		,@ShortName VARCHAR(500)
		,@ClosedDate VARCHAR(500)
		,@shoptype VARCHAR(500)
		,@PalmCode INT
		,@H14Code INT
		,@UpdatedDate VARCHAR(500)

	SELECT @op1 = Opertor
		,@ShopCode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'ShopCode'

	SELECT @op2 = Opertor
		,@LongName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'LongName'

	SELECT @op3 = Opertor
		,@ShortName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'ShortName'

	SELECT @op4 = Opertor
		,@ClosedDate = CAST(ParameterValue AS DATE)
		,@Secondop4 = SecondParameterOperator
		,@SecondClosedDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator4 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'ClosedDate'

	SELECT @op5 = Opertor
		,@shoptype = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Shoptype'

	SELECT @op6 = Opertor
		,@PalmCode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'PalmCode'

	SELECT @op7 = Opertor
		,@H14Code = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'H14Code'

	SELECT @op8 = Opertor
		,@UpdatedDate = CAST(ParameterValue AS DATE)
		,@Secondop8 = SecondParameterOperator
		,@SecondUpdatedDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator8 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'UpdatedDate'

	DECLARE @ClosedDateVarchar VARCHAR(100) = CAST(@ClosedDate AS VARCHAR)
		,@SecondClosedDateVarchar VARCHAR(100) = CAST(@SecondClosedDate AS VARCHAR)
	DECLARE @UpdatedDateVarchar VARCHAR(100) = CAST(@UpdatedDate AS VARCHAR)
		,@SecondUpdatedDateVarchar VARCHAR(100) = CAST(@SecondUpdatedDate AS VARCHAR)

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'Shopcode'

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
			SELECT shop_code AS ShopCode
				,shop_type AS ShopType
				,shop_longname AS LongName
				,shop_shortname AS ShortName
				,shop_dt_update AS UpdatedDate
				,shop_code_palm AS PalmCode
				,shop_code_H14 AS H14Code
				,shop_dt_fermeture AS ClosedDate
			FROM FRS.SHOP
			where shop_code<>0
				-- Order by shop_code desc
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Shopcode = @ShopCode
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Shopcode <> @ShopCode
					)
				OR (
					@op1 = @IsLessThan
					AND Shopcode < @ShopCode
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Shopcode <= @ShopCode
					)
				OR (
					@op1 = @IsGreaterThan
					AND Shopcode > @ShopCode
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Shopcode >= @ShopCode
					)
				OR (
					@op1 = @Contains
					AND Shopcode LIKE '%' + @ShopCode + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Shopcode NOT LIKE '%' + @ShopCode + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Shopcode LIKE '' + @ShopCode + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Shopcode LIKE '%' + @ShopCode + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND LongName = @LongName
					)
				OR (
					@op2 = @IsNotEqualTo
					AND LongName <> @LongName
					)
				OR (
					@op2 = @IsLessThan
					AND LongName < @LongName
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND LongName <= @LongName
					)
				OR (
					@op2 = @IsGreaterThan
					AND LongName > @LongName
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND LongName >= @LongName
					)
				OR (
					@op2 = @Contains
					AND LongName LIKE '%' + @LongName + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND LongName NOT LIKE '%' + @LongName + '%'
					)
				OR (
					@op2 = @StartsWith
					AND LongName LIKE '' + @LongName + '%'
					)
				OR (
					@op2 = @EndsWith
					AND LongName LIKE '%' + @LongName + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND ShortName = @ShortName
					)
				OR (
					@op3 = @IsNotEqualTo
					AND ShortName <> @ShortName
					)
				OR (
					@op3 = @IsLessThan
					AND ShortName < @ShortName
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND ShortName <= @ShortName
					)
				OR (
					@op3 = @IsGreaterThan
					AND ShortName > @ShortName
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND ShortName >= @ShortName
					)
				OR (
					@op3 = @Contains
					AND ShortName LIKE '%' + @ShortName + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND ShortName NOT LIKE '%' + @ShortName + '%'
					)
				OR (
					@op3 = @StartsWith
					AND ShortName LIKE '' + @ShortName + '%'
					)
				OR (
					@op3 = @EndsWith
					AND ShortName LIKE '%' + @ShortName + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 IS NULL
					AND @LogicalOperator4 IS NULL
					)
				OR (
					@LogicalOperator4 = 'OR'
					AND (
						(
							(
								@op4 = @IsEqualTo
								AND ClosedDate = @ClosedDate
								)
							OR (
								@op4 = @IsNotEqualTo
								AND ClosedDate <> @ClosedDate
								)
							OR (
								@op4 = @IsLessThan
								AND ClosedDate < @ClosedDate
								)
							OR (
								@op4 = @IsLessThanOrEqualTo
								AND ClosedDate <= @ClosedDate
								)
							OR (
								@op4 = @IsGreaterThan
								AND ClosedDate > @ClosedDate
								)
							OR (
								@op4 = @IsGreaterThanOrEqualTo
								AND ClosedDate >= @ClosedDate
								)
							OR (
								@op4 = @Contains
								AND ClosedDate LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op4 = @DoesNotContain
								AND ClosedDate NOT LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op4 = @StartsWith
								AND ClosedDate LIKE '' + @ClosedDateVarchar + '%'
								)
							OR (
								@op4 = @EndsWith
								AND ClosedDate LIKE '%' + @ClosedDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop4 = @IsEqualTo
								AND ClosedDate = @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsNotEqualTo
								AND ClosedDate <> @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsLessThan
								AND ClosedDate < @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsLessThanOrEqualTo
								AND ClosedDate <= @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsGreaterThan
								AND ClosedDate > @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsGreaterThanOrEqualTo
								AND ClosedDate >= @SecondClosedDate
								)
							OR (
								@Secondop4 = @Contains
								AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop4 = @DoesNotContain
								AND ClosedDate NOT LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop4 = @StartsWith
								AND ClosedDate LIKE '' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop4 = @EndsWith
								AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator4 = 'AND'
					AND (
						(
							(
								@op4 = @IsEqualTo
								AND ClosedDate = @ClosedDate
								)
							OR (
								@op4 = @IsNotEqualTo
								AND ClosedDate <> @ClosedDate
								)
							OR (
								@op4 = @IsLessThan
								AND ClosedDate < @ClosedDate
								)
							OR (
								@op4 = @IsLessThanOrEqualTo
								AND ClosedDate <= @ClosedDate
								)
							OR (
								@op4 = @IsGreaterThan
								AND ClosedDate > @ClosedDate
								)
							OR (
								@op4 = @IsGreaterThanOrEqualTo
								AND ClosedDate >= @ClosedDate
								)
							OR (
								@op4 = @Contains
								AND ClosedDate LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op4 = @DoesNotContain
								AND ClosedDate NOT LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op4 = @StartsWith
								AND ClosedDate LIKE '' + @ClosedDateVarchar + '%'
								)
							OR (
								@op4 = @EndsWith
								AND ClosedDate LIKE '%' + @ClosedDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop4 = @IsEqualTo
								AND ClosedDate = @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsNotEqualTo
								AND ClosedDate <> @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsLessThan
								AND ClosedDate < @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsLessThanOrEqualTo
								AND ClosedDate <= @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsGreaterThan
								AND ClosedDate > @SecondClosedDate
								)
							OR (
								@Secondop4 = @IsGreaterThanOrEqualTo
								AND ClosedDate >= @SecondClosedDate
								)
							OR (
								@Secondop4 = @Contains
								AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop4 = @DoesNotContain
								AND ClosedDate NOT LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop4 = @StartsWith
								AND ClosedDate LIKE '' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop4 = @EndsWith
								AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop4 IS NULL
					AND (
						(
							@op4 = @IsEqualTo
							AND ClosedDate = @ClosedDate
							)
						OR (
							@op4 = @IsNotEqualTo
							AND ClosedDate <> @ClosedDate
							)
						OR (
							@op4 = @IsLessThan
							AND ClosedDate < @ClosedDate
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND ClosedDate <= @ClosedDate
							)
						OR (
							@op4 = @IsGreaterThan
							AND ClosedDate > @ClosedDate
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND ClosedDate >= @ClosedDate
							)
						OR (
							@op4 = @Contains
							AND ClosedDate LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND ClosedDate NOT LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @StartsWith
							AND ClosedDate LIKE '' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @EndsWith
							AND ClosedDate LIKE '%' + @ClosedDateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND Shoptype = @shoptype
					)
				OR (
					@op5 = @IsNotEqualTo
					AND Shoptype <> @shoptype
					)
				OR (
					@op5 = @IsLessThan
					AND Shoptype < @shoptype
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND shoptype <= @shoptype
					)
				OR (
					@op5 = @IsGreaterThan
					AND shoptype > @shoptype
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND shoptype >= @shoptype
					)
				OR (
					@op5 = @Contains
					AND shoptype LIKE '%' + @shoptype + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND shoptype NOT LIKE '%' + @shoptype + '%'
					)
				OR (
					@op5 = @StartsWith
					AND shoptype LIKE '' + @shoptype + '%'
					)
				OR (
					@op5 = @EndsWith
					AND shoptype LIKE '%' + @shoptype + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND PalmCode = @PalmCode
					)
				OR (
					@op6 = @IsNotEqualTo
					AND PalmCode <> @PalmCode
					)
				OR (
					@op6 = @IsLessThan
					AND PalmCode < @PalmCode
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND PalmCode <= @PalmCode
					)
				OR (
					@op6 = @IsGreaterThan
					AND PalmCode > @PalmCode
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND PalmCode >= @PalmCode
					)
				OR (
					@op6 = @Contains
					AND PalmCode LIKE '%' + @PalmCode + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND PalmCode NOT LIKE '%' + @PalmCode + '%'
					)
				OR (
					@op6 = @StartsWith
					AND PalmCode LIKE '' + @PalmCode + '%'
					)
				OR (
					@op6 = @EndsWith
					AND PalmCode LIKE '%' + @PalmCode + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND H14Code = @H14Code
					)
				OR (
					@op7 = @IsNotEqualTo
					AND H14Code <> @H14Code
					)
				OR (
					@op7 = @IsLessThan
					AND H14Code < @H14Code
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND H14Code <= @H14Code
					)
				OR (
					@op7 = @IsGreaterThan
					AND H14Code > @H14Code
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND H14Code >= @H14Code
					)
				OR (
					@op7 = @Contains
					AND H14Code LIKE '%' + @H14Code + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND H14Code NOT LIKE '%' + @H14Code + '%'
					)
				OR (
					@op7 = @StartsWith
					AND H14Code LIKE '' + @H14Code + '%'
					)
				OR (
					@op7 = @EndsWith
					AND H14Code LIKE '%' + @H14Code + ''
					)
				)
			AND (
				(@op8 IS NULL)
				OR (
					@op8 IS NULL
					AND @LogicalOperator8 IS NULL
					)
				OR (
					@LogicalOperator8 = 'OR'
					AND (
						(
							(
								@op8 = @IsEqualTo
								AND UpdatedDate = @UpdatedDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND UpdatedDate <> @UpdatedDate
								)
							OR (
								@op8 = @IsLessThan
								AND UpdatedDate < @UpdatedDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND UpdatedDate <= @UpdatedDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND UpdatedDate > @UpdatedDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND UpdatedDate >= @UpdatedDate
								)
							OR (
								@op8 = @Contains
								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop8 = @IsEqualTo
								AND UpdatedDate = @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND UpdatedDate <> @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND UpdatedDate < @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND UpdatedDate <= @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND UpdatedDate > @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND UpdatedDate >= @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @Contains
								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator8 = 'AND'
					AND (
						(
							(
								@op8 = @IsEqualTo
								AND UpdatedDate = @UpdatedDate
								)
							OR (
								@op8 = @IsNotEqualTo
								AND UpdatedDate <> @UpdatedDate
								)
							OR (
								@op8 = @IsLessThan
								AND UpdatedDate < @UpdatedDate
								)
							OR (
								@op8 = @IsLessThanOrEqualTo
								AND UpdatedDate <= @UpdatedDate
								)
							OR (
								@op8 = @IsGreaterThan
								AND UpdatedDate > @UpdatedDate
								)
							OR (
								@op8 = @IsGreaterThanOrEqualTo
								AND UpdatedDate >= @UpdatedDate
								)
							OR (
								@op8 = @Contains
								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'
								)
							OR (
								@op8 = @DoesNotContain
								AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'
								)
							OR (
								@op8 = @StartsWith
								AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'
								)
							OR (
								@op8 = @EndsWith
								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop8 = @IsEqualTo
								AND UpdatedDate = @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsNotEqualTo
								AND UpdatedDate <> @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsLessThan
								AND UpdatedDate < @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsLessThanOrEqualTo
								AND UpdatedDate <= @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsGreaterThan
								AND UpdatedDate > @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @IsGreaterThanOrEqualTo
								AND UpdatedDate >= @SecondUpdatedDate
								)
							OR (
								@Secondop8 = @Contains
								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'
								)
							OR (
								@Secondop8 = @DoesNotContain
								AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'
								)
							OR (
								@Secondop8 = @StartsWith
								AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'
								)
							OR (
								@Secondop8 = @EndsWith
								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop8 IS NULL
					AND (
						(
							@op8 = @IsEqualTo
							AND UpdatedDate = @UpdatedDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND UpdatedDate <> @UpdatedDate
							)
						OR (
							@op8 = @IsLessThan
							AND UpdatedDate < @UpdatedDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND UpdatedDate <= @UpdatedDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND UpdatedDate > @UpdatedDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND UpdatedDate >= @UpdatedDate
							)
						OR (
							@op8 = @Contains
							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''
							)
						)
					)
				)
		OPTION (RECOMPILE)
	END

	SELECT *
	FROM (
		SELECT shop_code AS ShopCode
			,shop_type AS ShopType
			,shop_longname AS LongName
			,shop_shortname AS ShortName
			,shop_dt_update AS UpdatedDate
			,shop_code_palm AS PalmCode
			,shop_code_H14 AS H14Code
			,shop_dt_fermeture AS ClosedDate
		FROM FRS.SHOP
		where shop_code<>0
			--Order by shop_code desc
		) AS TEMPTABLE
	WHERE (
			(@op1 IS NULL)
			OR (
				@op1 = @IsEqualTo
				AND Shopcode = @ShopCode
				)
			OR (
				@op1 = @IsNotEqualTo
				AND Shopcode <> @ShopCode
				)
			OR (
				@op1 = @IsLessThan
				AND Shopcode < @ShopCode
				)
			OR (
				@op1 = @IsLessThanOrEqualTo
				AND Shopcode <= @ShopCode
				)
			OR (
				@op1 = @IsGreaterThan
				AND Shopcode > @ShopCode
				)
			OR (
				@op1 = @IsGreaterThanOrEqualTo
				AND Shopcode >= @ShopCode
				)
			OR (
				@op1 = @Contains
				AND Shopcode LIKE '%' + @ShopCode + '%'
				)
			OR (
				@op1 = @DoesNotContain
				AND Shopcode NOT LIKE '%' + @ShopCode + '%'
				)
			OR (
				@op1 = @StartsWith
				AND Shopcode LIKE '' + @ShopCode + '%'
				)
			OR (
				@op1 = @EndsWith
				AND Shopcode LIKE '%' + @ShopCode + ''
				)
			)
		AND (
			(@op2 IS NULL)
			OR (
				@op2 = @IsEqualTo
				AND LongName = @LongName
				)
			OR (
				@op2 = @IsNotEqualTo
				AND LongName <> @LongName
				)
			OR (
				@op2 = @IsLessThan
				AND LongName < @LongName
				)
			OR (
				@op2 = @IsLessThanOrEqualTo
				AND LongName <= @LongName
				)
			OR (
				@op2 = @IsGreaterThan
				AND LongName > @LongName
				)
			OR (
				@op2 = @IsGreaterThanOrEqualTo
				AND LongName >= @LongName
				)
			OR (
				@op2 = @Contains
				AND LongName LIKE '%' + @LongName + '%'
				)
			OR (
				@op2 = @DoesNotContain
				AND LongName NOT LIKE '%' + @LongName + '%'
				)
			OR (
				@op2 = @StartsWith
				AND LongName LIKE '' + @LongName + '%'
				)
			OR (
				@op2 = @EndsWith
				AND LongName LIKE '%' + @LongName + ''
				)
			)
		AND (
			(@op3 IS NULL)
			OR (
				@op3 = @IsEqualTo
				AND ShortName = @ShortName
				)
			OR (
				@op3 = @IsNotEqualTo
				AND ShortName <> @ShortName
				)
			OR (
				@op3 = @IsLessThan
				AND ShortName < @ShortName
				)
			OR (
				@op3 = @IsLessThanOrEqualTo
				AND ShortName <= @ShortName
				)
			OR (
				@op3 = @IsGreaterThan
				AND ShortName > @ShortName
				)
			OR (
				@op3 = @IsGreaterThanOrEqualTo
				AND ShortName >= @ShortName
				)
			OR (
				@op3 = @Contains
				AND ShortName LIKE '%' + @ShortName + '%'
				)
			OR (
				@op3 = @DoesNotContain
				AND ShortName NOT LIKE '%' + @ShortName + '%'
				)
			OR (
				@op3 = @StartsWith
				AND ShortName LIKE '' + @ShortName + '%'
				)
			OR (
				@op3 = @EndsWith
				AND ShortName LIKE '%' + @ShortName + ''
				)
			)
		AND (
			(@op4 IS NULL)
			OR (
				@op4 IS NULL
				AND @LogicalOperator4 IS NULL
				)
			OR (
				@LogicalOperator4 = 'OR'
				AND (
					(
						(
							@op4 = @IsEqualTo
							AND ClosedDate = @ClosedDate
							)
						OR (
							@op4 = @IsNotEqualTo
							AND ClosedDate <> @ClosedDate
							)
						OR (
							@op4 = @IsLessThan
							AND ClosedDate < @ClosedDate
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND ClosedDate <= @ClosedDate
							)
						OR (
							@op4 = @IsGreaterThan
							AND ClosedDate > @ClosedDate
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND ClosedDate >= @ClosedDate
							)
						OR (
							@op4 = @Contains
							AND ClosedDate LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND ClosedDate NOT LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @StartsWith
							AND ClosedDate LIKE '' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @EndsWith
							AND ClosedDate LIKE '%' + @ClosedDateVarchar + ''
							)
						)
					OR (
						(
							@Secondop4 = @IsEqualTo
							AND ClosedDate = @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsNotEqualTo
							AND ClosedDate <> @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsLessThan
							AND ClosedDate < @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsLessThanOrEqualTo
							AND ClosedDate <= @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsGreaterThan
							AND ClosedDate > @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsGreaterThanOrEqualTo
							AND ClosedDate >= @SecondClosedDate
							)
						OR (
							@Secondop4 = @Contains
							AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + '%'
							)
						OR (
							@Secondop4 = @DoesNotContain
							AND ClosedDate NOT LIKE '%' + @SecondClosedDateVarchar + '%'
							)
						OR (
							@Secondop4 = @StartsWith
							AND ClosedDate LIKE '' + @SecondClosedDateVarchar + '%'
							)
						OR (
							@Secondop4 = @EndsWith
							AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator4 = 'AND'
				AND (
					(
						(
							@op4 = @IsEqualTo
							AND ClosedDate = @ClosedDate
							)
						OR (
							@op4 = @IsNotEqualTo
							AND ClosedDate <> @ClosedDate
							)
						OR (
							@op4 = @IsLessThan
							AND ClosedDate < @ClosedDate
							)
						OR (
							@op4 = @IsLessThanOrEqualTo
							AND ClosedDate <= @ClosedDate
							)
						OR (
							@op4 = @IsGreaterThan
							AND ClosedDate > @ClosedDate
							)
						OR (
							@op4 = @IsGreaterThanOrEqualTo
							AND ClosedDate >= @ClosedDate
							)
						OR (
							@op4 = @Contains
							AND ClosedDate LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @DoesNotContain
							AND ClosedDate NOT LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @StartsWith
							AND ClosedDate LIKE '' + @ClosedDateVarchar + '%'
							)
						OR (
							@op4 = @EndsWith
							AND ClosedDate LIKE '%' + @ClosedDateVarchar + ''
							)
						)
					AND (
						(
							@Secondop4 = @IsEqualTo
							AND ClosedDate = @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsNotEqualTo
							AND ClosedDate <> @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsLessThan
							AND ClosedDate < @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsLessThanOrEqualTo
							AND ClosedDate <= @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsGreaterThan
							AND ClosedDate > @SecondClosedDate
							)
						OR (
							@Secondop4 = @IsGreaterThanOrEqualTo
							AND ClosedDate >= @SecondClosedDate
							)
						OR (
							@Secondop4 = @Contains
							AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + '%'
							)
						OR (
							@Secondop4 = @DoesNotContain
							AND ClosedDate NOT LIKE '%' + @SecondClosedDateVarchar + '%'
							)
						OR (
							@Secondop4 = @StartsWith
							AND ClosedDate LIKE '' + @SecondClosedDateVarchar + '%'
							)
						OR (
							@Secondop4 = @EndsWith
							AND ClosedDate LIKE '%' + @SecondClosedDateVarchar + ''
							)
						)
					)
				)
			OR (
				@Secondop4 IS NULL
				AND (
					(
						@op4 = @IsEqualTo
						AND ClosedDate = @ClosedDate
						)
					OR (
						@op4 = @IsNotEqualTo
						AND ClosedDate <> @ClosedDate
						)
					OR (
						@op4 = @IsLessThan
						AND ClosedDate < @ClosedDate
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND ClosedDate <= @ClosedDate
						)
					OR (
						@op4 = @IsGreaterThan
						AND ClosedDate > @ClosedDate
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND ClosedDate >= @ClosedDate
						)
					OR (
						@op4 = @Contains
						AND ClosedDate LIKE '%' + @ClosedDateVarchar + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND ClosedDate NOT LIKE '%' + @ClosedDateVarchar + '%'
						)
					OR (
						@op4 = @StartsWith
						AND ClosedDate LIKE '' + @ClosedDateVarchar + '%'
						)
					OR (
						@op4 = @EndsWith
						AND ClosedDate LIKE '%' + @ClosedDateVarchar + ''
						)
					)
				)
			)
		AND (
			(@op5 IS NULL)
			OR (
				@op5 = @IsEqualTo
				AND shoptype = @shoptype
				)
			OR (
				@op5 = @IsNotEqualTo
				AND shoptype <> @shoptype
				)
			OR (
				@op5 = @IsLessThan
				AND shoptype < @shoptype
				)
			OR (
				@op5 = @IsLessThanOrEqualTo
				AND shoptype <= @shoptype
				)
			OR (
				@op5 = @IsGreaterThan
				AND shoptype > @shoptype
				)
			OR (
				@op5 = @IsGreaterThanOrEqualTo
				AND shoptype >= @shoptype
				)
			OR (
				@op5 = @Contains
				AND shoptype LIKE '%' + @shoptype + '%'
				)
			OR (
				@op5 = @DoesNotContain
				AND shoptype NOT LIKE '%' + @shoptype + '%'
				)
			OR (
				@op5 = @StartsWith
				AND shoptype LIKE '' + @shoptype + '%'
				)
			OR (
				@op5 = @EndsWith
				AND shoptype LIKE '%' + @shoptype + ''
				)
			)
		AND (
			(@op6 IS NULL)
			OR (
				@op6 = @IsEqualTo
				AND PalmCode = @PalmCode
				)
			OR (
				@op6 = @IsNotEqualTo
				AND PalmCode <> @PalmCode
				)
			OR (
				@op6 = @IsLessThan
				AND PalmCode < @PalmCode
				)
			OR (
				@op6 = @IsLessThanOrEqualTo
				AND PalmCode <= @PalmCode
				)
			OR (
				@op6 = @IsGreaterThan
				AND PalmCode > @PalmCode
				)
			OR (
				@op6 = @IsGreaterThanOrEqualTo
				AND PalmCode >= @PalmCode
				)
			OR (
				@op6 = @Contains
				AND PalmCode LIKE '%' + @PalmCode + '%'
				)
			OR (
				@op6 = @DoesNotContain
				AND PalmCode NOT LIKE '%' + @PalmCode + '%'
				)
			OR (
				@op6 = @StartsWith
				AND PalmCode LIKE '' + @PalmCode + '%'
				)
			OR (
				@op6 = @EndsWith
				AND PalmCode LIKE '%' + @PalmCode + ''
				)
			)
		AND (
			(@op7 IS NULL)
			OR (
				@op7 = @IsEqualTo
				AND H14Code = @H14Code
				)
			OR (
				@op7 = @IsNotEqualTo
				AND H14Code <> @H14Code
				)
			OR (
				@op7 = @IsLessThan
				AND H14Code < @H14Code
				)
			OR (
				@op7 = @IsLessThanOrEqualTo
				AND H14Code <= @H14Code
				)
			OR (
				@op7 = @IsGreaterThan
				AND H14Code > @H14Code
				)
			OR (
				@op7 = @IsGreaterThanOrEqualTo
				AND H14Code >= @H14Code
				)
			OR (
				@op7 = @Contains
				AND H14Code LIKE '%' + @H14Code + '%'
				)
			OR (
				@op7 = @DoesNotContain
				AND H14Code NOT LIKE '%' + @H14Code + '%'
				)
			OR (
				@op7 = @StartsWith
				AND H14Code LIKE '' + @H14Code + '%'
				)
			OR (
				@op7 = @EndsWith
				AND H14Code LIKE '%' + @H14Code + ''
				)
			)
		AND (
			(@op8 IS NULL)
			OR (
				@op8 IS NULL
				AND @LogicalOperator8 IS NULL
				)
			OR (
				@LogicalOperator8 = 'OR'
				AND (
					(
						(
							@op8 = @IsEqualTo
							AND UpdatedDate = @UpdatedDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND UpdatedDate <> @UpdatedDate
							)
						OR (
							@op8 = @IsLessThan
							AND UpdatedDate < @UpdatedDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND UpdatedDate <= @UpdatedDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND UpdatedDate > @UpdatedDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND UpdatedDate >= @UpdatedDate
							)
						OR (
							@op8 = @Contains
							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''
							)
						)
					OR (
						(
							@Secondop8 = @IsEqualTo
							AND UpdatedDate = @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsNotEqualTo
							AND UpdatedDate <> @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsLessThan
							AND UpdatedDate < @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsLessThanOrEqualTo
							AND UpdatedDate <= @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsGreaterThan
							AND UpdatedDate > @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsGreaterThanOrEqualTo
							AND UpdatedDate >= @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @Contains
							AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'
							)
						OR (
							@Secondop8 = @DoesNotContain
							AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'
							)
						OR (
							@Secondop8 = @StartsWith
							AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'
							)
						OR (
							@Secondop8 = @EndsWith
							AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''
							)
						)
					)
				)
			OR (
				@LogicalOperator8 = 'AND'
				AND (
					(
						(
							@op8 = @IsEqualTo
							AND UpdatedDate = @UpdatedDate
							)
						OR (
							@op8 = @IsNotEqualTo
							AND UpdatedDate <> @UpdatedDate
							)
						OR (
							@op8 = @IsLessThan
							AND UpdatedDate < @UpdatedDate
							)
						OR (
							@op8 = @IsLessThanOrEqualTo
							AND UpdatedDate <= @UpdatedDate
							)
						OR (
							@op8 = @IsGreaterThan
							AND UpdatedDate > @UpdatedDate
							)
						OR (
							@op8 = @IsGreaterThanOrEqualTo
							AND UpdatedDate >= @UpdatedDate
							)
						OR (
							@op8 = @Contains
							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @DoesNotContain
							AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @StartsWith
							AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'
							)
						OR (
							@op8 = @EndsWith
							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''
							)
						)
					AND (
						(
							@Secondop8 = @IsEqualTo
							AND UpdatedDate = @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsNotEqualTo
							AND UpdatedDate <> @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsLessThan
							AND UpdatedDate < @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsLessThanOrEqualTo
							AND UpdatedDate <= @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsGreaterThan
							AND UpdatedDate > @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @IsGreaterThanOrEqualTo
							AND UpdatedDate >= @SecondUpdatedDate
							)
						OR (
							@Secondop8 = @Contains
							AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'
							)
						OR (
							@Secondop8 = @DoesNotContain
							AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'
							)
						OR (
							@Secondop8 = @StartsWith
							AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'
							)
						OR (
							@Secondop8 = @EndsWith
							AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''
							)
						)
					)
				)
			OR (
				@Secondop8 IS NULL
				AND (
					(
						@op8 = @IsEqualTo
						AND UpdatedDate = @UpdatedDate
						)
					OR (
						@op8 = @IsNotEqualTo
						AND UpdatedDate <> @UpdatedDate
						)
					OR (
						@op8 = @IsLessThan
						AND UpdatedDate < @UpdatedDate
						)
					OR (
						@op8 = @IsLessThanOrEqualTo
						AND UpdatedDate <= @UpdatedDate
						)
					OR (
						@op8 = @IsGreaterThan
						AND UpdatedDate > @UpdatedDate
						)
					OR (
						@op8 = @IsGreaterThanOrEqualTo
						AND UpdatedDate >= @UpdatedDate
						)
					OR (
						@op8 = @Contains
						AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'
						)
					OR (
						@op8 = @DoesNotContain
						AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'
						)
					OR (
						@op8 = @StartsWith
						AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'
						)
					OR (
						@op8 = @EndsWith
						AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''
						)
					)
				)
			)
	ORDER BY CASE 
			WHEN @pOrderBy = 'Shopcode'
				AND @pOrderType = 'ASC'
				THEN Shopcode
			END ASC
		,CASE 
			WHEN @pOrderBy = 'Shopcode'
				AND @pOrderType = 'DESC'
				THEN Shopcode
			END DESC
		,CASE 
			WHEN @pOrderBy = 'LongName'
				AND @pOrderType = 'ASC'
				THEN LongName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'LongName'
				AND @pOrderType = 'DESC'
				THEN LongName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ShortName'
				AND @pOrderType = 'ASC'
				THEN ShortName
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ShortName'
				AND @pOrderType = 'DESC'
				THEN ShortName
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ClosedDate'
				AND @pOrderType = 'ASC'
				THEN ClosedDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ClosedDate'
				AND @pOrderType = 'DESC'
				THEN ClosedDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'UpdatedDate'
				AND @pOrderType = 'ASC'
				THEN UpdatedDate
			END ASC
		,CASE 
			WHEN @pOrderBy = 'UpdatedDate'
				AND @pOrderType = 'DESC'
				THEN UpdatedDate
			END DESC
		,CASE 
			WHEN @pOrderBy = 'ShopType'
				AND @pOrderType = 'ASC'
				THEN ShopType
			END ASC
		,CASE 
			WHEN @pOrderBy = 'ShopType'
				AND @pOrderType = 'DESC'
				THEN ShopType
			END DESC
		,CASE 
			WHEN @pOrderBy = 'PalmCode'
				AND @pOrderType = 'ASC'
				THEN PalmCode
			END ASC
		,CASE 
			WHEN @pOrderBy = 'PalmCode'
				AND @pOrderType = 'DESC'
				THEN PalmCode
			END DESC
		,CASE 
			WHEN @pOrderBy = 'H14Code'
				AND @pOrderType = 'ASC'
				THEN H14Code
			END ASC
		,CASE 
			WHEN @pOrderBy = 'H14Code'
				AND @pOrderType = 'DESC'
				THEN H14Code
			END DESC OFFSET @OFFSETRows ROWS

	FETCH NEXT @pPageSize ROWS ONLY
	OPTION (RECOMPILE)
END
GO