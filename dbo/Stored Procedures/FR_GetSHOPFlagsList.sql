GO
CREATE PROCEDURE [dbo].[FR_GetSHOPFlagsList]

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

	DECLARE @op1 VARCHAR(50),@op2 VARCHAR(50)



	DECLARE @AttributeId VARCHAR(100),@AttributeName VARCHAR(500)



	SELECT @op1 = Opertor

		,@AttributeId = ParameterValue

	FROM @pParametersTable

	WHERE ParameterName = 'AttributeId'



	SELECT @op2 = Opertor

		,@AttributeName = ParameterValue

	FROM @pParametersTable

	WHERE ParameterName = 'AttributeName'


	IF (@pOrderBy IS NULL)

		SET @pOrderBy = 'AttributeId'



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

	SELECT flag_attribut AS AttributeId,flag_detail AS AttributeName

	FROM [FRS].[SHOPS_ATTRIBUTE] WHERE flag_attribut>=0

	) AS TEMPTABLE

		WHERE (

				(@op1 IS NULL)

				OR (

					@op1 = @IsEqualTo

					AND AttributeId = TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsNotEqualTo

					AND AttributeId <> TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsLessThan

					AND AttributeId < TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsLessThanOrEqualTo

					AND AttributeId <= TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsGreaterThan

					AND AttributeId > TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsGreaterThanOrEqualTo

					AND AttributeId >= TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @Contains

					AND AttributeId LIKE '%' + @AttributeId + '%'

					)

				OR (

					@op1 = @DoesNotContain

					AND AttributeId NOT LIKE '%' + @AttributeId + '%'

					)

				OR (

					@op1 = @StartsWith

					AND AttributeId LIKE '' + @AttributeId + '%'

					)

				OR (

					@op1 = @EndsWith

					AND AttributeId LIKE '%' + @AttributeId + ''

					)

				)

			AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND AttributeName = @AttributeName

					)

				OR (

					@op2 = @IsNotEqualTo

					AND AttributeName <> @AttributeName

					)

				OR (

					@op2 = @IsLessThan

					AND AttributeName < @AttributeName

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND AttributeName <= @AttributeName

					)

				OR (

					@op2 = @IsGreaterThan

					AND AttributeName > @AttributeName

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND AttributeName >= @AttributeName

					)

				OR (

					@op2 = @Contains

					AND AttributeName LIKE '%' + @AttributeName + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND AttributeName NOT LIKE '%' + @AttributeName + '%'

					)

				OR (

					@op2 = @StartsWith

					AND AttributeName LIKE '' + @AttributeName + '%'

					)

				OR (

					@op2 = @EndsWith

					AND AttributeName LIKE '%' + @AttributeName + ''

					)

				)	

				

	END

	SELECT *

		FROM (

	SELECT flag_attribut AS AttributeId,flag_detail AS AttributeName

	FROM [FRS].[SHOPS_ATTRIBUTE]  WHERE flag_attribut>=0

	) AS TEMPTABLE

		WHERE (

				(@op1 IS NULL)

				OR (

					@op1 = @IsEqualTo

					AND AttributeId = TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsNotEqualTo

					AND AttributeId <> TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsLessThan

					AND AttributeId < TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsLessThanOrEqualTo

					AND AttributeId <= TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsGreaterThan

					AND AttributeId > TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @IsGreaterThanOrEqualTo

					AND AttributeId >= TRY_PARSE(@AttributeId as int)

					)

				OR (

					@op1 = @Contains

					AND AttributeId LIKE '%' + @AttributeId + '%'

					)

				OR (

					@op1 = @DoesNotContain

					AND AttributeId NOT LIKE '%' + @AttributeId + '%'

					)

				OR (

					@op1 = @StartsWith

					AND AttributeId LIKE '' + @AttributeId + '%'

					)

				OR (

					@op1 = @EndsWith

					AND AttributeId LIKE '%' + @AttributeId + ''

					)

				)

			AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND AttributeName = @AttributeName

					)

				OR (

					@op2 = @IsNotEqualTo

					AND AttributeName <> @AttributeName

					)

				OR (

					@op2 = @IsLessThan

					AND AttributeName < @AttributeName

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND AttributeName <= @AttributeName

					)

				OR (

					@op2 = @IsGreaterThan

					AND AttributeName > @AttributeName

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND AttributeName >= @AttributeName

					)

				OR (

					@op2 = @Contains

					AND AttributeName LIKE '%' + @AttributeName + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND AttributeName NOT LIKE '%' + @AttributeName + '%'

					)

				OR (

					@op2 = @StartsWith

					AND AttributeName LIKE '' + @AttributeName + '%'

					)

				OR (

					@op2 = @EndsWith

					AND AttributeName LIKE '%' + @AttributeName + ''

					)

				)			

				

				ORDER BY CASE 

				WHEN @pOrderBy = 'AttributeId'

					AND @pOrderType = 'ASC'

					THEN AttributeId

				END ASC

			,CASE 

				WHEN @pOrderBy = 'AttributeId'

					AND @pOrderType = 'DESC'

					THEN AttributeId

				END DESC

			,CASE 

				WHEN @pOrderBy = 'AttributeName'

					AND @pOrderType = 'ASC'

					THEN AttributeName

				END ASC

			,CASE 

				WHEN @pOrderBy = 'AttributeName'

					AND @pOrderType = 'DESC'

					THEN AttributeName

					END DESC

					 OFFSET @OFFSETRows ROWS



		FETCH NEXT @pPageSize ROWS ONLY

		OPTION (RECOMPILE)



		 

END



