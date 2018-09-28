
CREATE PROCEDURE [dbo].[FR_GetUSIHistory]

@pUSICode INT

,@pCountryId UNIQUEIDENTIFIER

,@pCultureCode INT

,@pOrderBy VARCHAR(100)

,@pOrderType VARCHAR(10) -- ASC OR DESC

,@pPageNumber INT = 1

,@pPageSize INT = 100

,@pIsExport BIT = 0

,@pParametersTable dbo.GridParametersTable READONLY

AS

BEGIN



--DateOfUpdate,USI_LongName,USI_ShortName,Shop_LongName,SurfaceArea







	DECLARE @op1 VARCHAR(50),@op2 VARCHAR(50),@op3 VARCHAR(50),@op4 VARCHAR(50),@op5 VARCHAR(50),@op6 VARCHAR(50),@op7 VARCHAR(50),@op8 VARCHAR(50)

	DECLARE @USI_LongName VARCHAR(100),@USI_ShortName VARCHAR(500),@Shop_LongName VARCHAR(500),@SurfaceArea int

	,@DateOfUpdate VARCHAR(500),@MagCode INT,@Olddate VARCHAR(500),@Newdate VARCHAR(500)



	DECLARE @LogicalOperator5 VARCHAR(5),@LogicalOperator7 VARCHAR(5),@LogicalOperator8 VARCHAR(5)	

	DECLARE @Secondop5 VARCHAR(50),@Secondop7 VARCHAR(50),@Secondop8 VARCHAR(50)

	DECLARE @SecondDateOfUpdate DATE,@SecondOlddate DATE,@SecondNewdate DATE





	SELECT @op1 = Opertor
		,@USI_LongName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'LongName'


	SELECT @op2 = Opertor

		,@USI_ShortName = ParameterValue

	FROM @pParametersTable

	WHERE ParameterName = 'ShortName'

	

	SELECT @op3 = Opertor

		,@Shop_LongName = ParameterValue

	FROM @pParametersTable

	WHERE ParameterName = 'ShopLongName'



	SELECT @op4 = Opertor

		,@SurfaceArea = ParameterValue

	FROM @pParametersTable

	WHERE ParameterName = 'SurfaceArea'





	SELECT @op5 = Opertor
		,@DateOfUpdate = CAST(ParameterValue AS DATE)
		,@Secondop5 = SecondParameterOperator
		,@SecondDateOfUpdate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator5 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'UpdateDate'

	SELECT @op6 = Opertor
		,@MagCode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'MagCode'

	SELECT @op7 = Opertor
		,@Olddate = CAST(ParameterValue AS DATE)
		,@Secondop7 = SecondParameterOperator
		,@SecondOlddate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator7 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'Olddate'

	SELECT @op8 = Opertor
		,@Newdate = CAST(ParameterValue AS DATE)
		,@Secondop8 = SecondParameterOperator
		,@SecondNewdate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator8 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'Newdate'



	

	

	DECLARE @DateOfUpdateVarchar VARCHAR(100) = CAST(@DateOfUpdate AS VARCHAR)
	,@SecondDateOfUpdateVarchar VARCHAR(100) = CAST(@SecondDateOfUpdate AS VARCHAR)
	,@OlddateVarchar VARCHAR(100) = CAST(@Olddate AS VARCHAR)
	,@SecondOlddateVarchar VARCHAR(100) = CAST(@SecondOlddate AS VARCHAR)
	,@NewdateVarchar VARCHAR(100) = CAST(@Newdate AS VARCHAR)
	,@SecondNewdateVarchar VARCHAR(100) = CAST(@SecondNewdate AS VARCHAR)



	IF (@pOrderBy IS NULL)

		SET @pOrderBy = 'MagCode'



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

	SELECT U.usi_dt_update AS UpdateDate,U.usi_longname AS LongName, U.usi_shortname AS ShortName,
		S.shop_longname AS ShopLongName,M.mag_surface AS SurfaceArea
		,M.mag_code AS MagCode,M.mag_dt_debut AS OldDate,M.mag_dt_fin AS NewDate
		FROM FRS.MAG M 
		INNER JOIN FRS.USI U ON M.usi_code= U.usi_code
		INNER JOIN FRS.SHOP S ON M.shop_code = S.shop_code 
		WHERE M.usi_code=@pUSICode

	) AS TEMPTABLE

		WHERE (

				(@op1 IS NULL)

				OR (

					@op1 = @IsEqualTo

					AND LongName = @USI_LongName

					)

				OR (

					@op1 = @IsNotEqualTo

					AND LongName <> @USI_LongName

					)

				OR (

					@op1 = @IsLessThan

					AND LongName < @USI_LongName

					)

				OR (

					@op1 = @IsLessThanOrEqualTo

					AND LongName <= @USI_LongName

					)

				OR (

					@op1 = @IsGreaterThan

					AND LongName > @USI_LongName

					)

				OR (

					@op1 = @IsGreaterThanOrEqualTo

					AND LongName >= @USI_LongName

					)

				OR (

					@op1 = @Contains

					AND LongName LIKE '%' + @USI_LongName + '%'

					)

				OR (

					@op1 = @DoesNotContain

					AND LongName NOT LIKE '%' + @USI_LongName + '%'

					)

				OR (

					@op1 = @StartsWith

					AND LongName LIKE '' + @USI_LongName + '%'

					)

				OR (

					@op1 = @EndsWith

					AND LongName LIKE '%' + @USI_LongName + ''

					)

				)

			AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND ShortName = @USI_ShortName

					)

				OR (

					@op2 = @IsNotEqualTo

					AND ShortName <> @USI_ShortName

					)

				OR (

					@op2 = @IsLessThan

					AND ShortName < @USI_ShortName

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND ShortName <= @USI_ShortName

					)

				OR (

					@op2 = @IsGreaterThan

					AND ShortName > @USI_ShortName

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND ShortName >= @USI_ShortName

					)

				OR (

					@op2 = @Contains

					AND ShortName LIKE '%' + @USI_ShortName + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND ShortName NOT LIKE '%' + @USI_ShortName + '%'

					)

				OR (

					@op2 = @StartsWith

					AND ShortName LIKE '' + @USI_ShortName + '%'

					)

				OR (

					@op2 = @EndsWith

					AND ShortName LIKE '%' + @USI_ShortName + ''

					)

				)

				AND (

				(@op3 IS NULL)

				OR (

					@op3 = @IsEqualTo

					AND ShopLongName = @Shop_LongName

					)

				OR (

					@op3 = @IsNotEqualTo

					AND ShopLongName <> @Shop_LongName

					)

				OR (

					@op3 = @IsLessThan

					AND ShopLongName < @Shop_LongName

					)

				OR (

					@op3 = @IsLessThanOrEqualTo

					AND ShopLongName <= @Shop_LongName

					)

				OR (

					@op3 = @IsGreaterThan

					AND ShopLongName > @Shop_LongName

					)

				OR (

					@op3 = @IsGreaterThanOrEqualTo

					AND ShopLongName >= @Shop_LongName

					)

				OR (

					@op3 = @Contains

					AND ShopLongName LIKE '%' + @Shop_LongName + '%'

					)

				OR (

					@op3 = @DoesNotContain

					AND ShopLongName NOT LIKE '%' + @Shop_LongName + '%'

					)

				OR (

					@op3 = @StartsWith

					AND ShopLongName LIKE '' + @Shop_LongName + '%'

					)

				OR (

					@op3 = @EndsWith

					AND ShopLongName LIKE '%' + @Shop_LongName + ''

					)

				)

				AND (

				(@op4 IS NULL)

				OR (

					@op4 = @IsEqualTo

					AND SurfaceArea = @SurfaceArea

					)

				OR (

					@op4 = @IsNotEqualTo

					AND SurfaceArea <> @SurfaceArea

					)

				OR (

					@op4 = @IsLessThan

					AND SurfaceArea < @SurfaceArea

					)

				OR (

					@op4 = @IsLessThanOrEqualTo

					AND SurfaceArea <= @SurfaceArea

					)

				OR (

					@op4 = @IsGreaterThan

					AND SurfaceArea > @SurfaceArea

					)

				OR (

					@op4 = @IsGreaterThanOrEqualTo

					AND SurfaceArea >= @SurfaceArea

					)

				OR (

					@op4 = @Contains

					AND SurfaceArea LIKE '%' + @SurfaceArea + '%'

					)

				OR (

					@op4 = @DoesNotContain

					AND SurfaceArea NOT LIKE '%' + @SurfaceArea + '%'

					)

				OR (

					@op4 = @StartsWith

					AND SurfaceArea LIKE '' + @SurfaceArea + '%'

					)

				OR (

					@op4 = @EndsWith

					AND SurfaceArea LIKE '%' + @SurfaceArea + ''

					)

				)				
				AND
				(

				(@op5 IS NULL)

				OR (

					@op5 IS NULL

					AND @LogicalOperator5 IS NULL

					)

				OR (

					@LogicalOperator5 = 'OR'

					AND (

						(

							(

								@op5 = @IsEqualTo

								AND UpdateDate = @DateOfUpdate

								)

							OR (

								@op5 = @IsNotEqualTo

								AND UpdateDate <> @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThan

								AND UpdateDate < @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThan

								AND UpdateDate > @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @DateOfUpdate

								)

							OR (

								@op5 = @Contains

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @StartsWith

								AND UpdateDate LIKE '' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @EndsWith

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + ''

								)

							)

						OR (

							(

								@Secondop5 = @IsEqualTo

								AND UpdateDate = @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsNotEqualTo

								AND UpdateDate <> @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThan

								AND UpdateDate < @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThan

								AND UpdateDate > @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @Contains

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @StartsWith

								AND UpdateDate LIKE '' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @EndsWith

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + ''

								)

							)

						)

					)

				OR (

					@LogicalOperator5 = 'AND'

					AND (

						(

							(

								@op5 = @IsEqualTo

								AND UpdateDate = @DateOfUpdate

								)

							OR (

								@op5 = @IsNotEqualTo

								AND UpdateDate <> @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThan

								AND UpdateDate < @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThan

								AND UpdateDate > @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @DateOfUpdate

								)

							OR (

								@op5 = @Contains

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @StartsWith

								AND UpdateDate LIKE '' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @EndsWith

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + ''

								)

							)

						AND (

							(

								@Secondop5 = @IsEqualTo

								AND UpdateDate = @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsNotEqualTo

								AND UpdateDate <> @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThan

								AND UpdateDate < @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThan

								AND UpdateDate > @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @Contains

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @StartsWith

								AND UpdateDate LIKE '' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @EndsWith

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop5 IS NULL

					AND (

						(

							@op5 = @IsEqualTo

							AND UpdateDate = @DateOfUpdate

							)

						OR (

							@op5 = @IsNotEqualTo

							AND UpdateDate <> @DateOfUpdate

							)

						OR (

							@op5 = @IsLessThan

							AND UpdateDate < @DateOfUpdate

							)

						OR (

							@op5 = @IsLessThanOrEqualTo

							AND UpdateDate <= @DateOfUpdate

							)

						OR (

							@op5 = @IsGreaterThan

							AND UpdateDate > @DateOfUpdate

							)

						OR (

							@op5 = @IsGreaterThanOrEqualTo

							AND UpdateDate >= @DateOfUpdate

							)

						OR (

							@op5 = @Contains

							AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + '%'

							)

						OR (

							@op5 = @DoesNotContain

							AND UpdateDate NOT LIKE '%' + @DateOfUpdateVarchar + '%'

							)

						OR (

							@op5 = @StartsWith

							AND UpdateDate LIKE '' + @DateOfUpdateVarchar + '%'

							)

						OR (

							@op5 = @EndsWith

							AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + ''

							)

						)

					)

				) 
				AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND MagCode = @MagCode
					)
				OR (
					@op6 = @IsNotEqualTo
					AND MagCode <> @MagCode
					)
				OR (
					@op6 = @IsLessThan
					AND MagCode < @MagCode
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND MagCode <= @MagCode
					)
				OR (
					@op6 = @IsGreaterThan
					AND MagCode > @MagCode
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND MagCode >= @MagCode
					)
				OR (
					@op6 = @Contains
					AND MagCode LIKE '%' + @MagCode + '%'
					)
				OR (
				    @op6 = @DoesNotContain
					AND MagCode NOT LIKE '%' + @MagCode + '%'
					)
				OR (
					@op6 = @StartsWith
					AND MagCode LIKE '' + @MagCode + '%'
					)
				OR (
					@op6 = @EndsWith
					AND MagCode LIKE '%' + @MagCode + ''
					)
				)
				AND
				(

				(@op7 IS NULL)

				OR (

					@op7 IS NULL

					AND @LogicalOperator7 IS NULL

					)

				OR (

					@LogicalOperator7 = 'OR'

					AND (

						(

							(

								@op7 = @IsEqualTo

								AND Olddate = @Olddate

								)

							OR (

								@op7 = @IsNotEqualTo

								AND Olddate <> @Olddate

								)

							OR (

								@op7 = @IsLessThan

								AND Olddate < @Olddate

								)

							OR (

								@op7 = @IsLessThanOrEqualTo

								AND Olddate <= @Olddate

								)

							OR (

								@op7 = @IsGreaterThan

								AND Olddate > @Olddate

								)

							OR (

								@op7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @Olddate

								)

							OR (

								@op7 = @Contains

								AND Olddate LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @StartsWith

								AND Olddate LIKE '' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @EndsWith

								AND Olddate LIKE '%' + @OlddateVarchar + ''

								)

							)

						OR (

							(

								@Secondop7 = @IsEqualTo

								AND Olddate = @SecondOlddate

								)

							OR (

								@Secondop7 = @IsNotEqualTo

								AND Olddate <> @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThan

								AND Olddate < @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThanOrEqualTo

								AND Olddate <= @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThan

								AND Olddate > @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @SecondOlddate

								)

							OR (

								@Secondop7 = @Contains

								AND Olddate LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @StartsWith

								AND Olddate LIKE '' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @EndsWith

								AND Olddate LIKE '%' + @SecondOlddateVarchar + ''

								)

							)

						)

					)

				OR (

					@LogicalOperator7 = 'AND'

					AND (

						(

							(

								@op7 = @IsEqualTo

								AND Olddate = @Olddate

								)

							OR (

								@op7 = @IsNotEqualTo

								AND Olddate <> @Olddate

								)

							OR (

								@op7 = @IsLessThan

								AND Olddate < @Olddate

								)

							OR (

								@op7 = @IsLessThanOrEqualTo

								AND Olddate <= @Olddate

								)

							OR (

								@op7 = @IsGreaterThan

								AND Olddate > @Olddate

								)

							OR (

								@op7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @Olddate

								)

							OR (

								@op7 = @Contains

								AND Olddate LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @StartsWith

								AND Olddate LIKE '' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @EndsWith

								AND Olddate LIKE '%' + @OlddateVarchar + ''

								)

							)

						AND (

							(

								@Secondop7 = @IsEqualTo

								AND Olddate = @SecondOlddate

								)

							OR (

								@Secondop7 = @IsNotEqualTo

								AND Olddate <> @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThan

								AND Olddate < @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThanOrEqualTo

								AND Olddate <= @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThan

								AND Olddate > @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @SecondOlddate

								)

							OR (

								@Secondop7 = @Contains

								AND Olddate LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @StartsWith

								AND Olddate LIKE '' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @EndsWith

								AND Olddate LIKE '%' + @SecondOlddateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop7 IS NULL

					AND (

						(

							@op7 = @IsEqualTo

							AND Olddate = @Olddate

							)

						OR (

							@op7 = @IsNotEqualTo

							AND Olddate <> @Olddate

							)

						OR (

							@op7 = @IsLessThan

							AND Olddate < @Olddate

							)

						OR (

							@op7 = @IsLessThanOrEqualTo

							AND Olddate <= @Olddate

							)

						OR (

							@op7 = @IsGreaterThan

							AND Olddate > @Olddate

							)

						OR (

							@op7 = @IsGreaterThanOrEqualTo

							AND Olddate >= @Olddate

							)

						OR (

							@op7 = @Contains

							AND Olddate LIKE '%' + @OlddateVarchar + '%'

							)

						OR (

							@op7 = @DoesNotContain

							AND Olddate NOT LIKE '%' + @OlddateVarchar + '%'

							)

						OR (

							@op7 = @StartsWith

							AND Olddate LIKE '' + @OlddateVarchar + '%'

							)

						OR (

							@op7 = @EndsWith

							AND Olddate LIKE '%' + @OlddateVarchar + ''

							)

						)

					)

				)
				AND
				(

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

								AND Newdate = @Newdate

								)

							OR (

								@op8 = @IsNotEqualTo

								AND Newdate <> @Newdate

								)

							OR (

								@op8 = @IsLessThan

								AND Newdate < @Newdate

								)

							OR (

								@op8 = @IsLessThanOrEqualTo

								AND Newdate <= @Newdate

								)

							OR (

								@op8 = @IsGreaterThan

								AND Newdate > @Newdate

								)

							OR (

								@op8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @Newdate

								)

							OR (

								@op8 = @Contains

								AND Newdate LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @StartsWith

								AND Newdate LIKE '' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @EndsWith

								AND Newdate LIKE '%' + @NewdateVarchar + ''

								)

							)

						OR (

							(

								@Secondop8 = @IsEqualTo

								AND Newdate = @SecondNewdate

								)

							OR (

								@Secondop8 = @IsNotEqualTo

								AND Newdate <> @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThan

								AND Newdate < @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThanOrEqualTo

								AND Newdate <= @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThan

								AND Newdate > @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @SecondNewdate

								)

							OR (

								@Secondop8 = @Contains

								AND Newdate LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @StartsWith

								AND Newdate LIKE '' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @EndsWith

								AND Newdate LIKE '%' + @SecondNewdateVarchar + ''

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

								AND Newdate = @Newdate

								)

							OR (

								@op8 = @IsNotEqualTo

								AND Newdate <> @Newdate

								)

							OR (

								@op8 = @IsLessThan

								AND Newdate < @Newdate

								)

							OR (

								@op8 = @IsLessThanOrEqualTo

								AND Newdate <= @Newdate

								)

							OR (

								@op8 = @IsGreaterThan

								AND Newdate > @Newdate

								)

							OR (

								@op8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @Newdate

								)

							OR (

								@op8 = @Contains

								AND Newdate LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @StartsWith

								AND Newdate LIKE '' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @EndsWith

								AND Newdate LIKE '%' + @NewdateVarchar + ''

								)

							)

						AND (

							(

								@Secondop8 = @IsEqualTo

								AND Newdate = @SecondNewdate

								)

							OR (

								@Secondop8 = @IsNotEqualTo

								AND Newdate <> @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThan

								AND Newdate < @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThanOrEqualTo

								AND Newdate <= @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThan

								AND Newdate > @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @SecondNewdate

								)

							OR (

								@Secondop8 = @Contains

								AND Newdate LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @StartsWith

								AND Newdate LIKE '' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @EndsWith

								AND Newdate LIKE '%' + @SecondNewdateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop8 IS NULL

					AND (

						(

							@op8 = @IsEqualTo

							AND Newdate = @Newdate

							)

						OR (

							@op8 = @IsNotEqualTo

							AND Newdate <> @Newdate

							)

						OR (

							@op8 = @IsLessThan

							AND Newdate < @Newdate

							)

						OR (

							@op8 = @IsLessThanOrEqualTo

							AND Newdate <= @Newdate

							)

						OR (

							@op8 = @IsGreaterThan

							AND Newdate > @Newdate

							)

						OR (

							@op8 = @IsGreaterThanOrEqualTo

							AND Newdate >= @Newdate

							)

						OR (

							@op8 = @Contains

							AND Newdate LIKE '%' + @NewdateVarchar + '%'

							)

						OR (

							@op8 = @DoesNotContain

							AND Newdate NOT LIKE '%' + @NewdateVarchar + '%'

							)

						OR (

							@op8 = @StartsWith

							AND Newdate LIKE '' + @NewdateVarchar + '%'

							)

						OR (

							@op8 = @EndsWith

							AND Newdate LIKE '%' + @NewdateVarchar + ''

							)

						)

					)

				)

				

				OPTION (RECOMPILE)

				

	END

	SELECT *

		FROM (

		SELECT U.usi_dt_update AS UpdateDate,U.usi_longname AS LongName, U.usi_shortname AS ShortName,

		S.shop_longname AS ShopLongName,M.mag_surface AS SurfaceArea
		,M.mag_code AS MagCode,M.mag_dt_debut AS OldDate,M.mag_dt_fin AS NewDate

		FROM FRS.MAG M INNER JOIN FRS.USI U ON M.usi_code= U.usi_code

		INNER JOIN FRS.SHOP S ON M.shop_code = S.shop_code 

		WHERE M.usi_code=@pUSICode

	) AS TEMPTABLE

		WHERE (

				(@op1 IS NULL)

				OR (

					@op1 = @IsEqualTo

					AND LongName = @USI_LongName

					)

				OR (

					@op1 = @IsNotEqualTo

					AND LongName <> @USI_LongName

					)

				OR (

					@op1 = @IsLessThan

					AND LongName < @USI_LongName

					)

				OR (

					@op1 = @IsLessThanOrEqualTo

					AND LongName <= @USI_LongName

					)

				OR (

					@op1 = @IsGreaterThan

					AND LongName > @USI_LongName

					)

				OR (

					@op1 = @IsGreaterThanOrEqualTo

					AND LongName >= @USI_LongName

					)

				OR (

					@op1 = @Contains

					AND LongName LIKE '%' + @USI_LongName + '%'

					)

				OR (

					@op1 = @DoesNotContain

					AND LongName NOT LIKE '%' + @USI_LongName + '%'

					)

				OR (

					@op1 = @StartsWith

					AND LongName LIKE '' + @USI_LongName + '%'

					)

				OR (

					@op1 = @EndsWith

					AND LongName LIKE '%' + @USI_LongName + ''

					)

				)

			AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND ShortName = @USI_ShortName

					)

				OR (

					@op2 = @IsNotEqualTo

					AND ShortName <> @USI_ShortName

					)

				OR (

					@op2 = @IsLessThan

					AND ShortName < @USI_ShortName

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND ShortName <= @USI_ShortName

					)

				OR (

					@op2 = @IsGreaterThan

					AND ShortName > @USI_ShortName

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND ShortName >= @USI_ShortName

					)

				OR (

					@op2 = @Contains

					AND ShortName LIKE '%' + @USI_ShortName + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND ShortName NOT LIKE '%' + @USI_ShortName + '%'

					)

				OR (

					@op2 = @StartsWith

					AND ShortName LIKE '' + @USI_ShortName + '%'

					)

				OR (

					@op2 = @EndsWith

					AND ShortName LIKE '%' + @USI_ShortName + ''

					)

				)

				AND (

				(@op3 IS NULL)

				OR (

					@op3 = @IsEqualTo

					AND ShopLongName = @Shop_LongName

					)

				OR (

					@op3 = @IsNotEqualTo

					AND ShopLongName <> @Shop_LongName

					)

				OR (

					@op3 = @IsLessThan

					AND ShopLongName < @Shop_LongName

					)

				OR (

					@op3 = @IsLessThanOrEqualTo

					AND ShopLongName <= @Shop_LongName

					)

				OR (

					@op3 = @IsGreaterThan

					AND ShopLongName > @Shop_LongName

					)

				OR (

					@op3 = @IsGreaterThanOrEqualTo

					AND ShopLongName >= @Shop_LongName

					)

				OR (

					@op3 = @Contains

					AND ShopLongName LIKE '%' + @Shop_LongName + '%'

					)

				OR (

					@op3 = @DoesNotContain

					AND ShopLongName NOT LIKE '%' + @Shop_LongName + '%'

					)

				OR (

					@op3 = @StartsWith

					AND ShopLongName LIKE '' + @Shop_LongName + '%'

					)

				OR (

					@op3 = @EndsWith

					AND ShopLongName LIKE '%' + @Shop_LongName + ''

					)

				)

				AND (

				(@op4 IS NULL)

				OR (

					@op4 = @IsEqualTo

					AND SurfaceArea = @SurfaceArea

					)

				OR (

					@op4 = @IsNotEqualTo

					AND SurfaceArea <> @SurfaceArea

					)

				OR (

					@op4 = @IsLessThan

					AND SurfaceArea < @SurfaceArea

					)

				OR (

					@op4 = @IsLessThanOrEqualTo

					AND SurfaceArea <= @SurfaceArea

					)

				OR (

					@op4 = @IsGreaterThan

					AND SurfaceArea > @SurfaceArea

					)

				OR (

					@op4 = @IsGreaterThanOrEqualTo

					AND SurfaceArea >= @SurfaceArea

					)

				OR (

					@op4 = @Contains

					AND SurfaceArea LIKE '%' + @SurfaceArea + '%'

					)

				OR (

					@op4 = @DoesNotContain

					AND SurfaceArea NOT LIKE '%' + @SurfaceArea + '%'

					)

				OR (

					@op4 = @StartsWith

					AND SurfaceArea LIKE '' + @SurfaceArea + '%'

					)

				OR (

					@op4 = @EndsWith

					AND SurfaceArea LIKE '%' + @SurfaceArea + ''

					)

				)

				AND

				(

				(@op5 IS NULL)

				OR (

					@op5 IS NULL

					AND @LogicalOperator5 IS NULL

					)

				OR (

					@LogicalOperator5 = 'OR'

					AND (

						(

							(

								@op5 = @IsEqualTo

								AND UpdateDate = @DateOfUpdate

								)

							OR (

								@op5 = @IsNotEqualTo

								AND UpdateDate <> @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThan

								AND UpdateDate < @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThan

								AND UpdateDate > @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @DateOfUpdate

								)

							OR (

								@op5 = @Contains

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @StartsWith

								AND UpdateDate LIKE '' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @EndsWith

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + ''

								)

							)

						OR (

							(

								@Secondop5 = @IsEqualTo

								AND UpdateDate = @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsNotEqualTo

								AND UpdateDate <> @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThan

								AND UpdateDate < @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThan

								AND UpdateDate > @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @Contains

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @StartsWith

								AND UpdateDate LIKE '' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @EndsWith

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + ''

								)

							)

						)

					)

				OR (

					@LogicalOperator5 = 'AND'

					AND (

						(

							(

								@op5 = @IsEqualTo

								AND UpdateDate = @DateOfUpdate

								)

							OR (

								@op5 = @IsNotEqualTo

								AND UpdateDate <> @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThan

								AND UpdateDate < @DateOfUpdate

								)

							OR (

								@op5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThan

								AND UpdateDate > @DateOfUpdate

								)

							OR (

								@op5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @DateOfUpdate

								)

							OR (

								@op5 = @Contains

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @StartsWith

								AND UpdateDate LIKE '' + @DateOfUpdateVarchar + '%'

								)

							OR (

								@op5 = @EndsWith

								AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + ''
								)

							)

						AND (

							(

								@Secondop5 = @IsEqualTo

								AND UpdateDate = @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsNotEqualTo

								AND UpdateDate <> @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThan

								AND UpdateDate < @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsLessThanOrEqualTo

								AND UpdateDate <= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThan

								AND UpdateDate > @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @IsGreaterThanOrEqualTo

								AND UpdateDate >= @SecondDateOfUpdate

								)

							OR (

								@Secondop5 = @Contains

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @DoesNotContain

								AND UpdateDate NOT LIKE '%' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @StartsWith

								AND UpdateDate LIKE '' + @SecondDateOfUpdateVarchar + '%'

								)

							OR (

								@Secondop5 = @EndsWith

								AND UpdateDate LIKE '%' + @SecondDateOfUpdateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop5 IS NULL

					AND (

						(

							@op5 = @IsEqualTo

							AND UpdateDate = @DateOfUpdate

							)

						OR (

							@op5 = @IsNotEqualTo

							AND UpdateDate <> @DateOfUpdate

							)

						OR (

							@op5 = @IsLessThan

							AND UpdateDate < @DateOfUpdate

							)

						OR (

							@op5 = @IsLessThanOrEqualTo

							AND UpdateDate <= @DateOfUpdate

							)

						OR (

							@op5 = @IsGreaterThan

							AND UpdateDate > @DateOfUpdate

							)

						OR (

							@op5 = @IsGreaterThanOrEqualTo

							AND UpdateDate >= @DateOfUpdate

							)

						OR (

							@op5 = @Contains

							AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + '%'

							)

						OR (

							@op5 = @DoesNotContain

							AND UpdateDate NOT LIKE '%' + @DateOfUpdateVarchar + '%'

							)

						OR (

							@op5 = @StartsWith

							AND UpdateDate LIKE '' + @DateOfUpdateVarchar + '%'

							)

						OR (

							@op5 = @EndsWith

							AND UpdateDate LIKE '%' + @DateOfUpdateVarchar + ''

							)

						)

					)

				) 
				AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND MagCode = @MagCode
					)
				OR (
					@op6 = @IsNotEqualTo
					AND MagCode <> @MagCode
					)
				OR (
					@op6 = @IsLessThan
					AND MagCode < @MagCode
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND MagCode <= @MagCode
					)
				OR (
					@op6 = @IsGreaterThan
					AND MagCode > @MagCode
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND MagCode >= @MagCode
					)
				OR (
					@op6 = @Contains
					AND MagCode LIKE '%' + @MagCode + '%'
					)
				OR (
				    @op6 = @DoesNotContain
					AND MagCode NOT LIKE '%' + @MagCode + '%'
					)
				OR (
					@op6 = @StartsWith
					AND MagCode LIKE '' + @MagCode + '%'
					)
				OR (
					@op6 = @EndsWith
					AND MagCode LIKE '%' + @MagCode + ''
					)
				)
				AND
				(

				(@op7 IS NULL)

				OR (

					@op7 IS NULL

					AND @LogicalOperator7 IS NULL

					)

				OR (

					@LogicalOperator7 = 'OR'

					AND (

						(

							(

								@op7 = @IsEqualTo

								AND Olddate = @Olddate

								)

							OR (

								@op7 = @IsNotEqualTo

								AND Olddate <> @Olddate

								)

							OR (

								@op7 = @IsLessThan

								AND Olddate < @Olddate

								)

							OR (

								@op7 = @IsLessThanOrEqualTo

								AND Olddate <= @Olddate

								)

							OR (

								@op7 = @IsGreaterThan

								AND Olddate > @Olddate

								)

							OR (

								@op7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @Olddate

								)

							OR (

								@op7 = @Contains

								AND Olddate LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @StartsWith

								AND Olddate LIKE '' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @EndsWith

								AND Olddate LIKE '%' + @OlddateVarchar + ''

								)

							)

						OR (

							(

								@Secondop7 = @IsEqualTo

								AND Olddate = @SecondOlddate

								)

							OR (

								@Secondop7 = @IsNotEqualTo

								AND Olddate <> @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThan

								AND Olddate < @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThanOrEqualTo

								AND Olddate <= @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThan

								AND Olddate > @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @SecondOlddate

								)

							OR (

								@Secondop7 = @Contains

								AND Olddate LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @StartsWith

								AND Olddate LIKE '' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @EndsWith

								AND Olddate LIKE '%' + @SecondOlddateVarchar + ''

								)

							)

						)

					)

				OR (

					@LogicalOperator7 = 'AND'

					AND (

						(

							(

								@op7 = @IsEqualTo

								AND Olddate = @Olddate

								)

							OR (

								@op7 = @IsNotEqualTo

								AND Olddate <> @Olddate

								)

							OR (

								@op7 = @IsLessThan

								AND Olddate < @Olddate

								)

							OR (

								@op7 = @IsLessThanOrEqualTo

								AND Olddate <= @Olddate

								)

							OR (

								@op7 = @IsGreaterThan

								AND Olddate > @Olddate

								)

							OR (

								@op7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @Olddate

								)

							OR (

								@op7 = @Contains

								AND Olddate LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @StartsWith

								AND Olddate LIKE '' + @OlddateVarchar + '%'

								)

							OR (

								@op7 = @EndsWith

								AND Olddate LIKE '%' + @OlddateVarchar + ''

								)

							)

						AND (

							(

								@Secondop7 = @IsEqualTo

								AND Olddate = @SecondOlddate

								)

							OR (

								@Secondop7 = @IsNotEqualTo

								AND Olddate <> @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThan

								AND Olddate < @SecondOlddate

								)

							OR (

								@Secondop7 = @IsLessThanOrEqualTo

								AND Olddate <= @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThan

								AND Olddate > @SecondOlddate

								)

							OR (

								@Secondop7 = @IsGreaterThanOrEqualTo

								AND Olddate >= @SecondOlddate

								)

							OR (

								@Secondop7 = @Contains

								AND Olddate LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @DoesNotContain

								AND Olddate NOT LIKE '%' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @StartsWith

								AND Olddate LIKE '' + @SecondOlddateVarchar + '%'

								)

							OR (

								@Secondop7 = @EndsWith

								AND Olddate LIKE '%' + @SecondOlddateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop7 IS NULL

					AND (

						(

							@op7 = @IsEqualTo

							AND Olddate = @Olddate

							)

						OR (

							@op7 = @IsNotEqualTo

							AND Olddate <> @Olddate

							)

						OR (

							@op7 = @IsLessThan

							AND Olddate < @Olddate

							)

						OR (

							@op7 = @IsLessThanOrEqualTo

							AND Olddate <= @Olddate

							)

						OR (

							@op7 = @IsGreaterThan

							AND Olddate > @Olddate

							)

						OR (

							@op7 = @IsGreaterThanOrEqualTo

							AND Olddate >= @Olddate

							)

						OR (

							@op7 = @Contains

							AND Olddate LIKE '%' + @OlddateVarchar + '%'

							)

						OR (

							@op7 = @DoesNotContain

							AND Olddate NOT LIKE '%' + @OlddateVarchar + '%'

							)

						OR (

							@op7 = @StartsWith

							AND Olddate LIKE '' + @OlddateVarchar + '%'

							)

						OR (

							@op7 = @EndsWith

							AND Olddate LIKE '%' + @OlddateVarchar + ''

							)

						)

					)

				)
				AND
				(

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

								AND Newdate = @Newdate

								)

							OR (

								@op8 = @IsNotEqualTo

								AND Newdate <> @Newdate

								)

							OR (

								@op8 = @IsLessThan

								AND Newdate < @Newdate

								)

							OR (

								@op8 = @IsLessThanOrEqualTo

								AND Newdate <= @Newdate

								)

							OR (

								@op8 = @IsGreaterThan

								AND Newdate > @Newdate

								)

							OR (

								@op8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @Newdate

								)

							OR (

								@op8 = @Contains

								AND Newdate LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @StartsWith

								AND Newdate LIKE '' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @EndsWith

								AND Newdate LIKE '%' + @NewdateVarchar + ''

								)

							)

						OR (

							(

								@Secondop8 = @IsEqualTo

								AND Newdate = @SecondNewdate

								)

							OR (

								@Secondop8 = @IsNotEqualTo

								AND Newdate <> @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThan

								AND Newdate < @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThanOrEqualTo

								AND Newdate <= @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThan

								AND Newdate > @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @SecondNewdate

								)

							OR (

								@Secondop8 = @Contains

								AND Newdate LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @StartsWith

								AND Newdate LIKE '' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @EndsWith

								AND Newdate LIKE '%' + @SecondNewdateVarchar + ''

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

								AND Newdate = @Newdate

								)

							OR (

								@op8 = @IsNotEqualTo

								AND Newdate <> @Newdate

								)

							OR (

								@op8 = @IsLessThan

								AND Newdate < @Newdate

								)

							OR (

								@op8 = @IsLessThanOrEqualTo

								AND Newdate <= @Newdate

								)

							OR (

								@op8 = @IsGreaterThan

								AND Newdate > @Newdate

								)

							OR (

								@op8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @Newdate

								)

							OR (

								@op8 = @Contains

								AND Newdate LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @StartsWith

								AND Newdate LIKE '' + @NewdateVarchar + '%'

								)

							OR (

								@op8 = @EndsWith

								AND Newdate LIKE '%' + @NewdateVarchar + ''

								)

							)

						AND (

							(

								@Secondop8 = @IsEqualTo

								AND Newdate = @SecondNewdate

								)

							OR (

								@Secondop8 = @IsNotEqualTo

								AND Newdate <> @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThan

								AND Newdate < @SecondNewdate

								)

							OR (

								@Secondop8 = @IsLessThanOrEqualTo

								AND Newdate <= @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThan

								AND Newdate > @SecondNewdate

								)

							OR (

								@Secondop8 = @IsGreaterThanOrEqualTo

								AND Newdate >= @SecondNewdate

								)

							OR (

								@Secondop8 = @Contains

								AND Newdate LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @DoesNotContain

								AND Newdate NOT LIKE '%' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @StartsWith

								AND Newdate LIKE '' + @SecondNewdateVarchar + '%'

								)

							OR (

								@Secondop8 = @EndsWith

								AND Newdate LIKE '%' + @SecondNewdateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop8 IS NULL

					AND (

						(

							@op8 = @IsEqualTo

							AND Newdate = @Newdate

							)

						OR (

							@op8 = @IsNotEqualTo

							AND Newdate <> @Newdate

							)

						OR (

							@op8 = @IsLessThan

							AND Newdate < @Newdate

							)

						OR (

							@op8 = @IsLessThanOrEqualTo

							AND Newdate <= @Newdate

							)

						OR (

							@op8 = @IsGreaterThan

							AND Newdate > @Newdate

							)

						OR (

							@op8 = @IsGreaterThanOrEqualTo

							AND Newdate >= @Newdate

							)

						OR (

							@op8 = @Contains

							AND Newdate LIKE '%' + @NewdateVarchar + '%'

							)

						OR (

							@op8 = @DoesNotContain

							AND Newdate NOT LIKE '%' + @NewdateVarchar + '%'

							)

						OR (

							@op8 = @StartsWith

							AND Newdate LIKE '' + @NewdateVarchar + '%'

							)

						OR (

							@op8 = @EndsWith

							AND Newdate LIKE '%' + @NewdateVarchar + ''

							)

						)

					)

				)
				--OPTION (RECOMPILE)

				ORDER BY CASE 

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

				WHEN @pOrderBy = 'ShopLongName'

					AND @pOrderType = 'ASC'

					THEN ShopLongName

				END ASC

			,CASE 

				WHEN @pOrderBy = 'ShopLongName'

					AND @pOrderType = 'DESC'

					THEN ShopLongName

				END DESC

				,CASE 

				WHEN @pOrderBy = 'SurfaceArea'

					AND @pOrderType = 'DESC'

					THEN SurfaceArea

				END DESC

				,CASE 

				WHEN @pOrderBy = 'SurfaceArea'

					AND @pOrderType = 'ASC'

					THEN SurfaceArea

				END

				ASC 

				,CASE 
				WHEN @pOrderBy = 'UpdateDate'
					AND @pOrderType = 'DESC'
					THEN UpdateDate
				END DESC
				,CASE 
				WHEN @pOrderBy = 'UpdateDate'
					AND @pOrderType = 'ASC'
					THEN UpdateDate
				END ASC

				,CASE 
				WHEN @pOrderBy = 'MagCode'
					AND @pOrderType = 'DESC'
					THEN MagCode
				END DESC
				,CASE 
				WHEN @pOrderBy = 'MagCode'
					AND @pOrderType = 'ASC'
					THEN MagCode
				END ASC
				,CASE 
				WHEN @pOrderBy = 'Olddate'
					AND @pOrderType = 'DESC'
					THEN Olddate
				END DESC
				,CASE 
				WHEN @pOrderBy = 'Olddate'
					AND @pOrderType = 'ASC'
					THEN Olddate
				END ASC
				,CASE 
				WHEN @pOrderBy = 'Newdate'
					AND @pOrderType = 'DESC'
					THEN Newdate
				END DESC
				,CASE 
				WHEN @pOrderBy = 'Newdate'
					AND @pOrderType = 'ASC'
					THEN Newdate
				END ASC
				OFFSET @OFFSETRows ROWS



		FETCH NEXT @pPageSize ROWS ONLY

		OPTION (RECOMPILE)



		 

END




