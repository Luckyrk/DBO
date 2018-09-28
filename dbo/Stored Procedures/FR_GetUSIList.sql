GO
CREATE PROCEDURE [dbo].[FR_GetUSIList]
@pCountryId UNIQUEIDENTIFIER
,@pCultureCode INT
,@pOrderBy VARCHAR(100)
,@pOrderType VARCHAR(10) -- ASC OR DESC
,@pPageNumber INT = 1
,@pPageSize INT = 100
,@pIsExport BIT = 0
,@pParametersTable dbo.GridParametersTable READONLY
AS
BEGIN
	DECLARE @op1 VARCHAR(50),@op2 VARCHAR(50),@op3 VARCHAR(50),@op4 VARCHAR(50),@op5 VARCHAR(50),@op6 VARCHAR(50)
	DECLARE @USICode VARCHAR(100),@LongName VARCHAR(500),@ShortName VARCHAR(500)
	,@Ville VARCHAR(500),@ClosedDate VARCHAR(500),@PostalCode VARCHAR(100)

	DECLARE @LogicalOperator5 VARCHAR(5)	
	DECLARE @Secondop5 VARCHAR(50)
	DECLARE @SecondClosedDate DATE

	SELECT @op1 = Opertor
		,@USICode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'USICode'

	SELECT @op2 = Opertor
		,@LongName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'LongName'
	
	SELECT @op3 = Opertor
		,@ShortName = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'ShortName'

	SELECT @op4 = Opertor
		,@Ville = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Ville'


	SELECT @op5 = Opertor
		,@ClosedDate = CAST(ParameterValue AS DATE)
		,@Secondop5 = SecondParameterOperator
		,@SecondClosedDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator5 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'Closed'
	
	SELECT @op6 = Opertor
		,@PostalCode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'PostalCode'
	
		DECLARE @ClosedDateVarchar VARCHAR(100) = CAST(@ClosedDate AS VARCHAR)
		,@SecondClosedDateVarchar VARCHAR(100) = CAST(@SecondClosedDate AS VARCHAR)

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'USICode'

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
	SELECT usi_code AS USICode,usi_longname AS LongName,usi_shortname AS ShortName,usi_lb_ville AS Ville
		,usi_cd_postal AS PostalCode, usi_dt_fermeture as Closed FROM FRS.USI 
	) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND USICode = @USICode
					)
				OR (
					@op1 = @IsNotEqualTo
					AND USICode <> @USICode
					)
				OR (
					@op1 = @IsLessThan
					AND USICode < @USICode
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND USICode <= @USICode
					)
				OR (
					@op1 = @IsGreaterThan
					AND USICode > @USICode
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND USICode >= @USICode
					)
				OR (
					@op1 = @Contains
					AND USICode LIKE '%' + @USICode + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND USICode NOT LIKE '%' + @USICode + '%'
					)
				OR (
					@op1 = @StartsWith
					AND USICode LIKE '' + @USICode + '%'
					)
				OR (
					@op1 = @EndsWith
					AND USICode LIKE '%' + @USICode + ''
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
					@op4 = @IsEqualTo
					AND Ville = @Ville
					)
				OR (
					@op4 = @IsNotEqualTo
					AND Ville <> @Ville
					)
				OR (
					@op4 = @IsLessThan
					AND Ville < @Ville
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND Ville <= @Ville
					)
				OR (
					@op4 = @IsGreaterThan
					AND Ville > @Ville
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND Ville >= @Ville
					)
				OR (
					@op4 = @Contains
					AND Ville LIKE '%' + @Ville + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND Ville NOT LIKE '%' + @Ville + '%'
					)
				OR (
					@op4 = @StartsWith
					AND Ville LIKE '' + @Ville + '%'
					)
				OR (
					@op4 = @EndsWith
					AND Ville LIKE '%' + @Ville + ''
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
								AND Closed = @ClosedDate
								)
							OR (
								@op5 = @IsNotEqualTo
								AND Closed <> @ClosedDate
								)
							OR (
								@op5 = @IsLessThan
								AND Closed < @ClosedDate
								)
							OR (
								@op5 = @IsLessThanOrEqualTo
								AND Closed <= @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThan
								AND Closed > @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThanOrEqualTo
								AND Closed >= @ClosedDate
								)
							OR (
								@op5 = @Contains
								AND Closed LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @StartsWith
								AND Closed LIKE '' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @EndsWith
								AND Closed LIKE '%' + @ClosedDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop5 = @IsEqualTo
								AND Closed = @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsNotEqualTo
								AND Closed <> @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThan
								AND Closed < @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThanOrEqualTo
								AND Closed <= @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThan
								AND Closed > @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThanOrEqualTo
								AND Closed >= @SecondClosedDate
								)
							OR (
								@Secondop5 = @Contains
								AND Closed LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @StartsWith
								AND Closed LIKE '' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @EndsWith
								AND Closed LIKE '%' + @SecondClosedDateVarchar + ''
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
								AND Closed = @ClosedDate
								)
							OR (
								@op5 = @IsNotEqualTo
								AND Closed <> @ClosedDate
								)
							OR (
								@op5 = @IsLessThan
								AND Closed < @ClosedDate
								)
							OR (
								@op5 = @IsLessThanOrEqualTo
								AND Closed <= @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThan
								AND Closed > @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThanOrEqualTo
								AND Closed >= @ClosedDate
								)
							OR (
								@op5 = @Contains
								AND Closed LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @StartsWith
								AND Closed LIKE '' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @EndsWith
								AND Closed LIKE '%' + @ClosedDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop5 = @IsEqualTo
								AND Closed = @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsNotEqualTo
								AND Closed <> @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThan
								AND Closed < @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThanOrEqualTo
								AND Closed <= @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThan
								AND Closed > @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThanOrEqualTo
								AND Closed >= @SecondClosedDate
								)
							OR (
								@Secondop5 = @Contains
								AND Closed LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @StartsWith
								AND Closed LIKE '' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @EndsWith
								AND Closed LIKE '%' + @SecondClosedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop5 IS NULL
					AND (
						(
							@op5 = @IsEqualTo
							AND Closed = @ClosedDate
							)
						OR (
							@op5 = @IsNotEqualTo
							AND Closed <> @ClosedDate
							)
						OR (
							@op5 = @IsLessThan
							AND Closed < @ClosedDate
							)
						OR (
							@op5 = @IsLessThanOrEqualTo
							AND Closed <= @ClosedDate
							)
						OR (
							@op5 = @IsGreaterThan
							AND Closed > @ClosedDate
							)
						OR (
							@op5 = @IsGreaterThanOrEqualTo
							AND Closed >= @ClosedDate
							)
						OR (
							@op5 = @Contains
							AND Closed LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op5 = @DoesNotContain
							AND Closed NOT LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op5 = @StartsWith
							AND Closed LIKE '' + @ClosedDateVarchar + '%'
							)
						OR (
							@op5 = @EndsWith
							AND Closed LIKE '%' + @ClosedDateVarchar + ''
							)
						)
					)
				) 
				AND
				(
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND PostalCode = @PostalCode
					)
				OR (
					@op6 = @IsNotEqualTo
					AND PostalCode <> @PostalCode
					)
				OR (
					@op6 = @IsLessThan
					AND PostalCode < @PostalCode
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND PostalCode <= @PostalCode
					)
				OR (
					@op6 = @IsGreaterThan
					AND PostalCode > @PostalCode
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND PostalCode >= @PostalCode
					)
				OR (
					@op6 = @Contains
					AND PostalCode LIKE '%' + @PostalCode + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND PostalCode NOT LIKE '%' + @PostalCode + '%'
					)
				OR (
					@op6 = @StartsWith
					AND PostalCode LIKE '' + @PostalCode + '%'
					)
				OR (
					@op6 = @EndsWith
					AND PostalCode LIKE '%' + @PostalCode + ''
					)
				)
				OPTION (RECOMPILE)
				
	END
	SELECT *
		FROM (
	SELECT usi_code AS USICode,usi_longname AS LongName,usi_shortname AS ShortName,usi_lb_ville AS Ville
	,usi_cd_postal AS PostalCode,ISNULL(usi_ad_adresse_1,'')+ISNULL(' ,'+usi_ad_adresse_2,'') AS FullAddress
	, usi_dt_fermeture as Closed
	 FROM FRS.USI 
	) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND USICode = @USICode
					)
				OR (
					@op1 = @IsNotEqualTo
					AND USICode <> @USICode
					)
				OR (
					@op1 = @IsLessThan
					AND USICode < @USICode
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND USICode <= @USICode
					)
				OR (
					@op1 = @IsGreaterThan
					AND USICode > @USICode
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND USICode >= @USICode
					)
				OR (
					@op1 = @Contains
					AND USICode LIKE '%' + @USICode + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND USICode NOT LIKE '%' + @USICode + '%'
					)
				OR (
					@op1 = @StartsWith
					AND USICode LIKE '' + @USICode + '%'
					)
				OR (
					@op1 = @EndsWith
					AND USICode LIKE '%' + @USICode + ''
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
					@op4 = @IsEqualTo
					AND Ville = @Ville
					)
				OR (
					@op4 = @IsNotEqualTo
					AND Ville <> @Ville
					)
				OR (
					@op4 = @IsLessThan
					AND Ville < @Ville
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND Ville <= @Ville
					)
				OR (
					@op4 = @IsGreaterThan
					AND Ville > @Ville
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND Ville >= @Ville
					)
				OR (
					@op4 = @Contains
					AND Ville LIKE '%' + @Ville + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND Ville NOT LIKE '%' + @Ville + '%'
					)
				OR (
					@op4 = @StartsWith
					AND Ville LIKE '' + @Ville + '%'
					)
				OR (
					@op4 = @EndsWith
					AND Ville LIKE '%' + @Ville + ''
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
								AND Closed = @ClosedDate
								)
							OR (
								@op5 = @IsNotEqualTo
								AND Closed <> @ClosedDate
								)
							OR (
								@op5 = @IsLessThan
								AND Closed < @ClosedDate
								)
							OR (
								@op5 = @IsLessThanOrEqualTo
								AND Closed <= @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThan
								AND Closed > @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThanOrEqualTo
								AND Closed >= @ClosedDate
								)
							OR (
								@op5 = @Contains
								AND Closed LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @StartsWith
								AND Closed LIKE '' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @EndsWith
								AND Closed LIKE '%' + @ClosedDateVarchar + ''
								)
							)
						OR (
							(
								@Secondop5 = @IsEqualTo
								AND Closed = @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsNotEqualTo
								AND Closed <> @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThan
								AND Closed < @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThanOrEqualTo
								AND Closed <= @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThan
								AND Closed > @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThanOrEqualTo
								AND Closed >= @SecondClosedDate
								)
							OR (
								@Secondop5 = @Contains
								AND Closed LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @StartsWith
								AND Closed LIKE '' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @EndsWith
								AND Closed LIKE '%' + @SecondClosedDateVarchar + ''
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
								AND Closed = @ClosedDate
								)
							OR (
								@op5 = @IsNotEqualTo
								AND Closed <> @ClosedDate
								)
							OR (
								@op5 = @IsLessThan
								AND Closed < @ClosedDate
								)
							OR (
								@op5 = @IsLessThanOrEqualTo
								AND Closed <= @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThan
								AND Closed > @ClosedDate
								)
							OR (
								@op5 = @IsGreaterThanOrEqualTo
								AND Closed >= @ClosedDate
								)
							OR (
								@op5 = @Contains
								AND Closed LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @StartsWith
								AND Closed LIKE '' + @ClosedDateVarchar + '%'
								)
							OR (
								@op5 = @EndsWith
								AND Closed LIKE '%' + @ClosedDateVarchar + ''
								)
							)
						AND (
							(
								@Secondop5 = @IsEqualTo
								AND Closed = @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsNotEqualTo
								AND Closed <> @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThan
								AND Closed < @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsLessThanOrEqualTo
								AND Closed <= @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThan
								AND Closed > @SecondClosedDate
								)
							OR (
								@Secondop5 = @IsGreaterThanOrEqualTo
								AND Closed >= @SecondClosedDate
								)
							OR (
								@Secondop5 = @Contains
								AND Closed LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @DoesNotContain
								AND Closed NOT LIKE '%' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @StartsWith
								AND Closed LIKE '' + @SecondClosedDateVarchar + '%'
								)
							OR (
								@Secondop5 = @EndsWith
								AND Closed LIKE '%' + @SecondClosedDateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop5 IS NULL
					AND (
						(
							@op5 = @IsEqualTo
							AND Closed = @ClosedDate
							)
						OR (
							@op5 = @IsNotEqualTo
							AND Closed <> @ClosedDate
							)
						OR (
							@op5 = @IsLessThan
							AND Closed < @ClosedDate
							)
						OR (
							@op5 = @IsLessThanOrEqualTo
							AND Closed <= @ClosedDate
							)
						OR (
							@op5 = @IsGreaterThan
							AND Closed > @ClosedDate
							)
						OR (
							@op5 = @IsGreaterThanOrEqualTo
							AND Closed >= @ClosedDate
							)
						OR (
							@op5 = @Contains
							AND Closed LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op5 = @DoesNotContain
							AND Closed NOT LIKE '%' + @ClosedDateVarchar + '%'
							)
						OR (
							@op5 = @StartsWith
							AND Closed LIKE '' + @ClosedDateVarchar + '%'
							)
						OR (
							@op5 = @EndsWith
							AND Closed LIKE '%' + @ClosedDateVarchar + ''
							)
						)
					)
				)
				AND 
				(
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND PostalCode = @PostalCode
					)
				OR (
					@op6 = @IsNotEqualTo
					AND PostalCode <> @PostalCode
					)
				OR (
					@op6 = @IsLessThan
					AND PostalCode < @PostalCode
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND PostalCode <= @PostalCode
					)
				OR (
					@op6 = @IsGreaterThan
					AND PostalCode > @PostalCode
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND PostalCode >= @PostalCode
					)
				OR (
					@op6 = @Contains
					AND PostalCode LIKE '%' + @PostalCode + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND PostalCode NOT LIKE '%' + @PostalCode + '%'
					)
				OR (
					@op6 = @StartsWith
					AND PostalCode LIKE '' + @PostalCode + '%'
					)
				OR (
					@op6 = @EndsWith
					AND PostalCode LIKE '%' + @PostalCode + ''
					)
				)
				--OPTION (RECOMPILE)
				ORDER BY CASE 
				WHEN @pOrderBy = 'USICode'
					AND @pOrderType = 'ASC'
					THEN USICode
				END ASC
			,CASE 
				WHEN @pOrderBy = 'USICode'
					AND @pOrderType = 'DESC'
					THEN USICode
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
				WHEN @pOrderBy = 'Ville'
					AND @pOrderType = 'DESC'
					THEN Ville
				END DESC
				,CASE 
				WHEN @pOrderBy = 'Ville'
					AND @pOrderType = 'ASC'
					THEN Ville
				END
				ASC 
				,CASE 
				WHEN @pOrderBy = 'PostalCode'
					AND @pOrderType = 'DESC'
					THEN PostalCode
				END DESC
				,CASE 
				WHEN @pOrderBy = 'PostalCode'
					AND @pOrderType = 'ASC'
					THEN PostalCode
				END
				ASC
				OFFSET @OFFSETRows ROWS

		FETCH NEXT @pPageSize ROWS ONLY
		OPTION (RECOMPILE)

		 
END


GO