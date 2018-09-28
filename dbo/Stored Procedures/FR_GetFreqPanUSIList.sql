CREATE PROCEDURE [dbo].[FR_GetFreqPanUSIList]
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
	IF(@pCountryId IS NULL)
	BEGIN
	 SET @pCountryId=(SELECT CountryId FROM Country WHERE CountryISO2A='FR' )
	END

	DECLARE @GroupBusinessDigits INT

	SELECT @GroupBusinessDigits = GroupBusinessIdDigits
	FROM Country C 
	JOIN CountryConfiguration CC ON C.Configuration_Id=CC.Id
	WHERE C.CountryId=@pCountryId

	DECLARE @op1 VARCHAR(50),@op2 VARCHAR(50),@op3 VARCHAR(50),@op4 VARCHAR(50),@op5 VARCHAR(50),@op6 VARCHAR(50),@op7 VARCHAR(50),@op8 VARCHAR(50),@op9 VARCHAR(50)
	DECLARE @BusinessId VARCHAR(100),@USICode VARCHAR(500),@Order VARCHAR(500),@UpdatedDate Date,@Order1 VARCHAR(500),@Order2 VARCHAR(500),@Order3 VARCHAR(500),@Order4 VARCHAR(500),@Order5 VARCHAR(500)
	DECLARE @LogicalOperator4  VARCHAR(5)
	DECLARE @Secondop4 VARCHAR(50)
	DECLARE @SecondUpdatedDate DATE
	
	SELECT @op1 = Opertor
		,@BusinessId = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'BusinessId'

	SELECT @op2 = Opertor
		,@USICode = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'USICode'

	SELECT @op3 = Opertor
		,@Order = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Order'

	SELECT @op4 = Opertor
		,@UpdatedDate = CAST(ParameterValue AS DATE)
		,@Secondop4 = SecondParameterOperator
		,@SecondUpdatedDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator4 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'UpdatedDate'

	SELECT @op5 = Opertor
		,@Order1 = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Order1'


	SELECT @op6 = Opertor
		,@Order2 = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Order2'

	SELECT @op7 = Opertor
		,@Order3 = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Order3'

	SELECT @op8 = Opertor
		,@Order4 = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Order4'

	SELECT @op9 = Opertor
		,@Order5 = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Order5'
	
		DECLARE @UpdatedDateVarchar VARCHAR(100) = CAST(@UpdatedDate AS VARCHAR)
		,@SecondUpdatedDateVarchar VARCHAR(100) = CAST(@SecondUpdatedDate AS VARCHAR)

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'BusinessId'

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
		SET @pPageSize = 15000
IF (@pIsExport = 0)
	BEGIN
		SELECT COUNT(0)
		FROM (
	--SELECT idfoyer AS Idfoyer,usi_code AS USICode,freq_no_ordre AS [Order],CAST(freq_dt_update AS DATE) AS UpdatedDate
	--FROM FRS.FREQUENTER_PAN_USI
	SELECT Idfoyer,Order1,Order2,Order3,Order4,CASE WHEN Order4='' THEN '' ELSE Order5 END AS Order5,UpdatedDate, BusinessId FROM (
		SELECT idfoyer AS Idfoyer,
	            max(iif(FU.freq_no_ordre = 1, usi_shortname, '')) AS Order1
               ,max(iif(FU.freq_no_ordre = 2, usi_shortname, '')) AS Order2
               ,max(iif(FU.freq_no_ordre = 3, usi_shortname, '')) AS Order3
               ,max(iif(FU.freq_no_ordre = 4, usi_shortname, '')) AS Order4
			   ,max(iif(FU.freq_no_ordre = 5, usi_shortname, '')) AS Order5
			   ,max(FU.freq_dt_update) AS UpdatedDate
	 ,CASE WHEN LEN(idfoyer) < @GroupBusinessDigits
		THEN RIGHT(REPLICATE('0', @GroupBusinessDigits), (@GroupBusinessDigits - LEN(idfoyer))) + cast(idfoyer AS NVARCHAR)
		ELSE cast(idfoyer AS NVARCHAR)
		END +'-0' + CAST(pan_no_individu AS VARCHAR) AS BusinessId

	FROM FRS.FREQUENTER_PAN_USI FU Join [FRS].[USI] U
	on FU.usi_code= U.usi_code
	group by idfoyer,pan_no_individu
	) TT --WHERE Order1<>'' AND Order2<>'' AND Order3<>''
	) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND BusinessId = @BusinessId
					)
				OR (
					@op1 = @IsNotEqualTo
					AND BusinessId <> @BusinessId
					)
				OR (
					@op1 = @IsLessThan
					AND BusinessId < @BusinessId
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND BusinessId <= @BusinessId
					)
				OR (
					@op1 = @IsGreaterThan
					AND BusinessId > @BusinessId
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND BusinessId >= @BusinessId
					)
				OR (
					@op1 = @Contains
					AND BusinessId LIKE '%' + @BusinessId + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND BusinessId NOT LIKE '%' + @BusinessId + '%'
					)
				OR (
					@op1 = @StartsWith
					AND BusinessId LIKE '' + @BusinessId + '%'
					)
				OR (
					@op1 = @EndsWith
					AND BusinessId LIKE '%' + @BusinessId + ''
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

								AND UpdatedDate = @UpdatedDate

								)

							OR (

								@op4 = @IsNotEqualTo

								AND UpdatedDate <> @UpdatedDate

								)

							OR (

								@op4 = @IsLessThan

								AND UpdatedDate < @UpdatedDate

								)

							OR (

								@op4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThan

								AND UpdatedDate > @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @UpdatedDate

								)

							OR (

								@op4 = @Contains

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @StartsWith

								AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @EndsWith

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''

								)

							)

						OR (

							(

								@Secondop4 = @IsEqualTo

								AND UpdatedDate = @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsNotEqualTo

								AND UpdatedDate <> @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThan

								AND UpdatedDate < @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThan

								AND UpdatedDate > @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @Contains

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @StartsWith

								AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @EndsWith

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''

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

								AND UpdatedDate = @UpdatedDate

								)

							OR (

								@op4 = @IsNotEqualTo

								AND UpdatedDate <> @UpdatedDate

								)

							OR (

								@op4 = @IsLessThan

								AND UpdatedDate < @UpdatedDate

								)

							OR (

								@op4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThan

								AND UpdatedDate > @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @UpdatedDate

								)

							OR (

								@op4 = @Contains

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @StartsWith

								AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @EndsWith

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''

								)

							)

						AND (

							(

								@Secondop4 = @IsEqualTo

								AND UpdatedDate = @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsNotEqualTo

								AND UpdatedDate <> @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThan

								AND UpdatedDate < @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThan

								AND UpdatedDate > @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @Contains

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @StartsWith

								AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @EndsWith

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop4 IS NULL

					AND (

						(

							@op4 = @IsEqualTo

							AND UpdatedDate = @UpdatedDate

							)

						OR (

							@op4 = @IsNotEqualTo

							AND UpdatedDate <> @UpdatedDate

							)

						OR (

							@op4 = @IsLessThan

							AND UpdatedDate < @UpdatedDate

							)

						OR (

							@op4 = @IsLessThanOrEqualTo

							AND UpdatedDate <= @UpdatedDate

							)

						OR (

							@op4 = @IsGreaterThan

							AND UpdatedDate > @UpdatedDate

							)

						OR (

							@op4 = @IsGreaterThanOrEqualTo

							AND UpdatedDate >= @UpdatedDate

							)

						OR (

							@op4 = @Contains

							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'

							)

						OR (

							@op4 = @DoesNotContain

							AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'

							)

						OR (

							@op4 = @StartsWith

							AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'

							)

						OR (

							@op4 = @EndsWith

							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''

							)

						)

					)

				)
				AND
				(
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND Order1 = @Order1
					)
				OR (
					@op5 = @IsNotEqualTo
					AND Order1 <> @Order1
					)
				OR (
					@op5 = @IsLessThan
					AND Order1 < @Order1
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND Order1 <= @Order1
					)
				OR (
					@op5 = @IsGreaterThan
					AND Order1 > @Order1
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND Order1 >= @Order1
					)
				OR (
					@op5 = @Contains
					AND Order1 LIKE '%' + @Order1 + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND Order1 NOT LIKE '%' + @Order1 + '%'
					)
				OR (
					@op5 = @StartsWith
					AND Order1 LIKE '' + @Order1 + '%'
					)
				OR (
					@op5 = @EndsWith
					AND Order1 LIKE '%' + @Order1 + ''
					)
				)
				AND
				(
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND Order2 = @Order2
					)
				OR (
					@op6 = @IsNotEqualTo
					AND Order2 <> @Order2
					)
				OR (
					@op6 = @IsLessThan
					AND Order2 < @Order2
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND Order2 <= @Order2
					)
				OR (
					@op6 = @IsGreaterThan
					AND Order2 > @Order2
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND Order2 >= @Order2
					)
				OR (
					@op6 = @Contains
					AND Order2 LIKE '%' + @Order2 + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND Order2 NOT LIKE '%' + @Order2 + '%'
					)
				OR (
					@op6 = @StartsWith
					AND Order2 LIKE '' + @Order2 + '%'
					)
				OR (
					@op6 = @EndsWith
					AND Order2 LIKE '%' + @Order2 + ''
					)
				)
				AND
				(
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND Order3 = @Order3
					)
				OR (
					@op7 = @IsNotEqualTo
					AND Order3 <> @Order3
					)
				OR (
					@op7 = @IsLessThan
					AND Order3 < @Order3
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND Order3 <= @Order3
					)
				OR (
					@op7 = @IsGreaterThan
					AND Order3 > @Order3
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND Order3 >= @Order3
					)
				OR (
					@op7 = @Contains
					AND Order3 LIKE '%' + @Order3 + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND Order3 NOT LIKE '%' + @Order3 + '%'
					)
				OR (
					@op7 = @StartsWith
					AND Order3 LIKE '' + @Order3 + '%'
					)
				OR (
					@op7 = @EndsWith
					AND Order3 LIKE '%' + @Order3 + ''
					)
				)
				AND
				(
				(@op8 IS NULL)
				OR (
					@op8 = @IsEqualTo
					AND Order4 = @Order4
					)
				OR (
					@op8 = @IsNotEqualTo
					AND Order4 <> @Order4
					)
				OR (
					@op8 = @IsLessThan
					AND Order4 < @Order4
					)
				OR (
					@op8 = @IsLessThanOrEqualTo
					AND Order4 <= @Order4
					)
				OR (
					@op8 = @IsGreaterThan
					AND Order4 > @Order4
					)
				OR (
					@op8 = @IsGreaterThanOrEqualTo
					AND Order4 >= @Order4
					)
				OR (
					@op8 = @Contains
					AND Order4 LIKE '%' + @Order4 + '%'
					)
				OR (
					@op8 = @DoesNotContain
					AND Order4 NOT LIKE '%' + @Order4 + '%'
					)
				OR (
					@op8 = @StartsWith
					AND Order4 LIKE '' + @Order4 + '%'
					)
				OR (
					@op8 = @EndsWith
					AND Order4 LIKE '%' + @Order4 + ''
					)
				)
				AND
				(
				(@op9 IS NULL)
				OR (
					@op9 = @IsEqualTo
					AND Order5 = @Order5
					)
				OR (
					@op9 = @IsNotEqualTo
					AND Order5 <> @Order5
					)
				OR (
					@op9 = @IsLessThan
					AND Order5 < @Order5
					)
				OR (
					@op9 = @IsLessThanOrEqualTo
					AND Order5 <= @Order5
					)
				OR (
					@op9 = @IsGreaterThan
					AND Order5 > @Order5
					)
				OR (
					@op9 = @IsGreaterThanOrEqualTo
					AND Order5 >= @Order5
					)
				OR (
					@op9 = @Contains
					AND Order5 LIKE '%' + @Order5 + '%'
					)
				OR (
					@op9 = @DoesNotContain
					AND Order5 NOT LIKE '%' + @Order5 + '%'
					)
				OR (
					@op9 = @StartsWith
					AND Order5 LIKE '' + @Order5 + '%'
					)
				OR (
					@op9 = @EndsWith
					AND Order5 LIKE '%' + @Order5 + ''
					)
				)

				OPTION (RECOMPILE)

				

	END

	SELECT Idfoyer,pan_no_individu,Order1,Order2,Order3,Order4,CASE WHEN Order4='' THEN '' ELSE Order5 END AS Order5,CAST(UpdatedDate AS DATE),BusinessId

		FROM (

	--SELECT idfoyer AS Idfoyer,usi_code AS USICode,freq_no_ordre AS [Order],CAST(freq_dt_update AS DATE) AS UpdatedDate

	--FROM FRS.FREQUENTER_PAN_USI
		SELECT Idfoyer,pan_no_individu,Order1,Order2,Order3,Order4,CASE WHEN Order4='' THEN '' ELSE Order5 END AS Order5,UpdatedDate,BusinessId FROM (
		SELECT idfoyer AS Idfoyer,pan_no_individu,
	            max(iif(FU.freq_no_ordre = 1, usi_shortname, '')) AS Order1
               ,max(iif(FU.freq_no_ordre = 2, usi_shortname, '')) AS Order2
               ,max(iif(FU.freq_no_ordre = 3, usi_shortname, '')) AS Order3
               ,max(iif(FU.freq_no_ordre = 4, usi_shortname, '')) AS Order4
			   ,max(iif(FU.freq_no_ordre = 5, usi_shortname, '')) AS Order5
			   ,max(FU.freq_dt_update) AS UpdatedDate
	 ,CASE WHEN LEN(idfoyer) < @GroupBusinessDigits
		THEN RIGHT(REPLICATE('0', @GroupBusinessDigits), (@GroupBusinessDigits - LEN(idfoyer))) + cast(idfoyer AS NVARCHAR)
		ELSE cast(idfoyer AS NVARCHAR)
		END +'-0' + CAST(pan_no_individu AS VARCHAR) AS BusinessId

	FROM FRS.FREQUENTER_PAN_USI FU Join [FRS].[USI] U
	on FU.usi_code= U.usi_code
	group by idfoyer,pan_no_individu
	) TT --WHERE Order1<>'' AND Order2<>'' AND Order3<>''

	) AS TEMPTABLE

		WHERE (

				(@op1 IS NULL)

				OR (

					@op1 = @IsEqualTo

					AND BusinessId = @BusinessId

					)

				OR (

					@op1 = @IsNotEqualTo

					AND BusinessId <> @BusinessId

					)

				OR (

					@op1 = @IsLessThan

					AND BusinessId < @BusinessId

					)

				OR (

					@op1 = @IsLessThanOrEqualTo

					AND BusinessId <= @BusinessId

					)

				OR (

					@op1 = @IsGreaterThan

					AND BusinessId > @BusinessId

					)

				OR (

					@op1 = @IsGreaterThanOrEqualTo

					AND BusinessId >= @BusinessId

					)

				OR (

					@op1 = @Contains

					AND BusinessId LIKE '%' + @BusinessId + '%'

					)

				OR (

					@op1 = @DoesNotContain

					AND BusinessId NOT LIKE '%' + @BusinessId + '%'

					)

				OR (

					@op1 = @StartsWith

					AND BusinessId LIKE '' + @BusinessId + '%'

					)

				OR (

					@op1 = @EndsWith

					AND BusinessId LIKE '%' + @BusinessId + ''

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

								AND UpdatedDate = @UpdatedDate

								)

							OR (

								@op4 = @IsNotEqualTo

								AND UpdatedDate <> @UpdatedDate

								)

							OR (

								@op4 = @IsLessThan

								AND UpdatedDate < @UpdatedDate

								)

							OR (

								@op4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThan

								AND UpdatedDate > @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @UpdatedDate

								)

							OR (

								@op4 = @Contains

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @StartsWith

								AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @EndsWith

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''

								)

							)

						OR (

							(

								@Secondop4 = @IsEqualTo

								AND UpdatedDate = @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsNotEqualTo

								AND UpdatedDate <> @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThan

								AND UpdatedDate < @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThan

								AND UpdatedDate > @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @Contains

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @StartsWith

								AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @EndsWith

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''

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

								AND UpdatedDate = @UpdatedDate

								)

							OR (

								@op4 = @IsNotEqualTo

								AND UpdatedDate <> @UpdatedDate

								)

							OR (

								@op4 = @IsLessThan

								AND UpdatedDate < @UpdatedDate

								)

							OR (

								@op4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThan

								AND UpdatedDate > @UpdatedDate

								)

							OR (

								@op4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @UpdatedDate

								)

							OR (

								@op4 = @Contains

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @StartsWith

								AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'

								)

							OR (

								@op4 = @EndsWith

								AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''

								)

							)

						AND (

							(

								@Secondop4 = @IsEqualTo

								AND UpdatedDate = @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsNotEqualTo

								AND UpdatedDate <> @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThan

								AND UpdatedDate < @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsLessThanOrEqualTo

								AND UpdatedDate <= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThan

								AND UpdatedDate > @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @IsGreaterThanOrEqualTo

								AND UpdatedDate >= @SecondUpdatedDate

								)

							OR (

								@Secondop4 = @Contains

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @DoesNotContain

								AND UpdatedDate NOT LIKE '%' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @StartsWith

								AND UpdatedDate LIKE '' + @SecondUpdatedDateVarchar + '%'

								)

							OR (

								@Secondop4 = @EndsWith

								AND UpdatedDate LIKE '%' + @SecondUpdatedDateVarchar + ''

								)

							)

						)

					)

				OR (

					@Secondop4 IS NULL

					AND (

						(

							@op4 = @IsEqualTo

							AND UpdatedDate = @UpdatedDate

							)

						OR (

							@op4 = @IsNotEqualTo

							AND UpdatedDate <> @UpdatedDate

							)

						OR (

							@op4 = @IsLessThan

							AND UpdatedDate < @UpdatedDate

							)

						OR (

							@op4 = @IsLessThanOrEqualTo

							AND UpdatedDate <= @UpdatedDate

							)

						OR (

							@op4 = @IsGreaterThan

							AND UpdatedDate > @UpdatedDate

							)

						OR (

							@op4 = @IsGreaterThanOrEqualTo

							AND UpdatedDate >= @UpdatedDate

							)

						OR (

							@op4 = @Contains

							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + '%'

							)

						OR (

							@op4 = @DoesNotContain

							AND UpdatedDate NOT LIKE '%' + @UpdatedDateVarchar + '%'

							)

						OR (

							@op4 = @StartsWith

							AND UpdatedDate LIKE '' + @UpdatedDateVarchar + '%'

							)

						OR (

							@op4 = @EndsWith

							AND UpdatedDate LIKE '%' + @UpdatedDateVarchar + ''

							)

						)

					)

				)
				AND
				(
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND Order1 = @Order1
					)
				OR (
					@op5 = @IsNotEqualTo
					AND Order1 <> @Order1
					)
				OR (
					@op5 = @IsLessThan
					AND Order1 < @Order1
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND Order1 <= @Order1
					)
				OR (
					@op5 = @IsGreaterThan
					AND Order1 > @Order1
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND Order1 >= @Order1
					)
				OR (
					@op5 = @Contains
					AND Order1 LIKE '%' + @Order1 + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND Order1 NOT LIKE '%' + @Order1 + '%'
					)
				OR (
					@op5 = @StartsWith
					AND Order1 LIKE '' + @Order1 + '%'
					)
				OR (
					@op5 = @EndsWith
					AND Order1 LIKE '%' + @Order1 + ''
					)
				)
				AND
				(
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND Order2 = @Order2
					)
				OR (
					@op6 = @IsNotEqualTo
					AND Order2 <> @Order2
					)
				OR (
					@op6 = @IsLessThan
					AND Order2 < @Order2
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND Order2 <= @Order2
					)
				OR (
					@op6 = @IsGreaterThan
					AND Order2 > @Order2
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND Order2 >= @Order2
					)
				OR (
					@op6 = @Contains
					AND Order2 LIKE '%' + @Order2 + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND Order2 NOT LIKE '%' + @Order2 + '%'
					)
				OR (
					@op6 = @StartsWith
					AND Order2 LIKE '' + @Order2 + '%'
					)
				OR (
					@op6 = @EndsWith
					AND Order2 LIKE '%' + @Order2 + ''
					)
				)
				AND
				(
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND Order3 = @Order3
					)
				OR (
					@op7 = @IsNotEqualTo
					AND Order3 <> @Order3
					)
				OR (
					@op7 = @IsLessThan
					AND Order3 < @Order3
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND Order3 <= @Order3
					)
				OR (
					@op7 = @IsGreaterThan
					AND Order3 > @Order3
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND Order3 >= @Order3
					)
				OR (
					@op7 = @Contains
					AND Order3 LIKE '%' + @Order3 + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND Order3 NOT LIKE '%' + @Order3 + '%'
					)
				OR (
					@op7 = @StartsWith
					AND Order3 LIKE '' + @Order3 + '%'
					)
				OR (
					@op7 = @EndsWith
					AND Order3 LIKE '%' + @Order3 + ''
					)
				)
				AND
				(
				(@op8 IS NULL)
				OR (
					@op8 = @IsEqualTo
					AND Order4 = @Order4
					)
				OR (
					@op8 = @IsNotEqualTo
					AND Order4 <> @Order4
					)
				OR (
					@op8 = @IsLessThan
					AND Order4 < @Order4
					)
				OR (
					@op8 = @IsLessThanOrEqualTo
					AND Order4 <= @Order4
					)
				OR (
					@op8 = @IsGreaterThan
					AND Order4 > @Order4
					)
				OR (
					@op8 = @IsGreaterThanOrEqualTo
					AND Order4 >= @Order4
					)
				OR (
					@op8 = @Contains
					AND Order4 LIKE '%' + @Order4 + '%'
					)
				OR (
					@op8 = @DoesNotContain
					AND Order4 NOT LIKE '%' + @Order4 + '%'
					)
				OR (
					@op8 = @StartsWith
					AND Order4 LIKE '' + @Order4 + '%'
					)
				OR (
					@op8 = @EndsWith
					AND Order4 LIKE '%' + @Order4 + ''
					)
				)
				AND
				(
				(@op9 IS NULL)
				OR (
					@op9 = @IsEqualTo
					AND Order5 = @Order5
					)
				OR (
					@op9 = @IsNotEqualTo
					AND Order5 <> @Order5
					)
				OR (
					@op9 = @IsLessThan
					AND Order5 < @Order5
					)
				OR (
					@op9 = @IsLessThanOrEqualTo
					AND Order5 <= @Order5
					)
				OR (
					@op9 = @IsGreaterThan
					AND Order5 > @Order5
					)
				OR (
					@op9 = @IsGreaterThanOrEqualTo
					AND Order5 >= @Order5
					)
				OR (
					@op9 = @Contains
					AND Order5 LIKE '%' + @Order5 + '%'
					)
				OR (
					@op9 = @DoesNotContain
					AND Order5 NOT LIKE '%' + @Order5 + '%'
					)
				OR (
					@op9 = @StartsWith
					AND Order5 LIKE '' + @Order5 + '%'
					)
				OR (
					@op9 = @EndsWith
					AND Order5 LIKE '%' + @Order5 + ''
					)
				)			

				ORDER BY CASE 

				WHEN @pOrderBy = 'BusinessId'

					AND @pOrderType = 'ASC'

					THEN BusinessId

				END ASC

			,CASE 

				WHEN @pOrderBy = 'BusinessId'

					AND @pOrderType = 'DESC'

					THEN BusinessId

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

				WHEN @pOrderBy = 'Order1'

					AND @pOrderType = 'ASC'

					THEN Order1

				END ASC

			,CASE 

				WHEN @pOrderBy = 'Order1'

					AND @pOrderType = 'DESC'

					THEN Order1

				END DESC
				,CASE 

				WHEN @pOrderBy = 'Order2'

					AND @pOrderType = 'ASC'

					THEN Order2

				END ASC

			,CASE 

				WHEN @pOrderBy = 'Order2'

					AND @pOrderType = 'DESC'

					THEN Order2

				END DESC
				,CASE 

				WHEN @pOrderBy = 'Order3'

					AND @pOrderType = 'ASC'

					THEN Order3

				END ASC

			,CASE 

				WHEN @pOrderBy = 'Order3'

					AND @pOrderType = 'DESC'

					THEN Order3

				END DESC
				,CASE 

				WHEN @pOrderBy = 'Order4'

					AND @pOrderType = 'ASC'

					THEN Order4

				END ASC

			,CASE 

				WHEN @pOrderBy = 'Order4'

					AND @pOrderType = 'DESC'

					THEN Order4

				END DESC
				,CASE 

				WHEN @pOrderBy = 'Order5'

					AND @pOrderType = 'ASC'

					THEN Order5

				END ASC

			,CASE 

				WHEN @pOrderBy = 'Order5'

					AND @pOrderType = 'DESC'

					THEN Order5

				END DESC
				OFFSET @OFFSETRows ROWS



		FETCH NEXT @pPageSize ROWS ONLY

		OPTION (RECOMPILE)



		 

END


GO