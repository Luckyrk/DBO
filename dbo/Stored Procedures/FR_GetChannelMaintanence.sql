GO
CREATE PROCEDURE [dbo].[FR_GetChannelMaintanence]
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
	DECLARE @Channel VARCHAR(100),@Description VARCHAR(500)

	SELECT @op1 = Opertor
		,@Channel = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Channel'

	SELECT @op2 = Opertor
		,@Description = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Description'

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'Channel'

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
	SELECT civ_cd_circ_vente AS Channel,civ_lb_circ_vente AS [Description] FROM FRS.CIRCUIT_VENTE 
	) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Channel = @Channel
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Channel <> @Channel
					)
				OR (
					@op1 = @IsLessThan
					AND Channel < @Channel
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Channel <= @Channel
					)
				OR (
					@op1 = @IsGreaterThan
					AND Channel > @Channel
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Channel >= @Channel
					)
				OR (
					@op1 = @Contains
					AND Channel LIKE '%' + @Channel + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Channel NOT LIKE '%' + @Channel + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Channel LIKE '' + @Channel + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Channel LIKE '%' + @Channel + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND [Description] = @Description
					)
				OR (
					@op2 = @IsNotEqualTo
					AND [Description] <> @Description
					)
				OR (
					@op2 = @IsLessThan
					AND [Description] < @Description
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND [Description] <= @Description
					)
				OR (
					@op2 = @IsGreaterThan
					AND [Description] > @Description
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND [Description] >= @Description
					)
				OR (
					@op2 = @Contains
					AND [Description] LIKE '%' + @Description + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND [Description] NOT LIKE '%' + @Description + '%'
					)
				OR (
					@op2 = @StartsWith
					AND [Description] LIKE '' + @Description + '%'
					)
				OR (
					@op2 = @EndsWith
					AND [Description] LIKE '%' + @Description + ''
					)
				)
					OPTION (RECOMPILE)
	END
	SELECT *
		FROM (
	SELECT civ_cd_circ_vente AS Channel,civ_lb_circ_vente AS [Description] FROM FRS.CIRCUIT_VENTE 
	) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND Channel = @Channel
					)
				OR (
					@op1 = @IsNotEqualTo
					AND Channel <> @Channel
					)
				OR (
					@op1 = @IsLessThan
					AND Channel < @Channel
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND Channel <= @Channel
					)
				OR (
					@op1 = @IsGreaterThan
					AND Channel > @Channel
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND Channel >= @Channel
					)
				OR (
					@op1 = @Contains
					AND Channel LIKE '%' + @Channel + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND Channel NOT LIKE '%' + @Channel + '%'
					)
				OR (
					@op1 = @StartsWith
					AND Channel LIKE '' + @Channel + '%'
					)
				OR (
					@op1 = @EndsWith
					AND Channel LIKE '%' + @Channel + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND [Description] = @Description
					)
				OR (
					@op2 = @IsNotEqualTo
					AND [Description] <> @Description
					)
				OR (
					@op2 = @IsLessThan
					AND [Description] < @Description
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND [Description] <= @Description
					)
				OR (
					@op2 = @IsGreaterThan
					AND [Description] > @Description
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND [Description] >= @Description
					)
				OR (
					@op2 = @Contains
					AND [Description] LIKE '%' + @Description + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND [Description] NOT LIKE '%' + @Description + '%'
					)
				OR (
					@op2 = @StartsWith
					AND [Description] LIKE '' + @Description + '%'
					)
				OR (
					@op2 = @EndsWith
					AND [Description] LIKE '%' + @Description + ''
					)
				)
				--OPTION (RECOMPILE)
				ORDER BY CASE 
				WHEN @pOrderBy = 'Channel'
					AND @pOrderType = 'ASC'
					THEN Channel
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Channel'
					AND @pOrderType = 'DESC'
					THEN Channel
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Description'
					AND @pOrderType = 'ASC'
					THEN [Description]
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Description'
					AND @pOrderType = 'DESC'
					THEN [Description]
				END DESC OFFSET @OFFSETRows ROWS

		FETCH NEXT @pPageSize ROWS ONLY
		OPTION (RECOMPILE)

		 
END


GO