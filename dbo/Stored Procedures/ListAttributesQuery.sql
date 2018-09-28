CREATE PROCEDURE [dbo].[ListAttributesQuery]
 @pCountryId UNIQUEIDENTIFIER
 ,@pCultureCode INT = 2057
 ,@pOrderBy VARCHAR(100)
 ,@pOrderType VARCHAR(10)
 ,@pPageNumber INT = 1
 ,@pPageSize INT = 100
 ,@pIsExport BIT = 0
 ,@pParametersTable dbo.GridParametersTable readonly
as
begin


select A.GUIDReference as Id,dbo.GetTranslationValue(Tr.TranslationId,@pCultureCode) as Demographic, isnull(A.ShortCode,'') as ShortCode,dbo.GetTranslationValue(Tra.TranslationId,@pCultureCode) as CategoryType ,
CASE A.[Type]
  WHEN 'String' THEN 0
  WHEN 'Boolean' THEN 0
  
  ELSE 1
END as HasGroupings ,A.CreationTimeStamp,A. Active,Ats.[Type] as Scope, A.[Type] as [Type],A.IsCalculated as IsCalculated,A.[Key] as AttributeKey, A.TimeDisplay as TimeDisplay
 into #tempDemographics

from Attribute A
inner join AttributeCategory At on A.Category_Id=At.GUIDReference
inner join Translation Tr on Tr.TranslationId=A.Translation_Id
inner join Translation tra on Tra.TranslationId=At.Translation_Id
inner join AttributeScope Ats on Ats.GUIDReference = A.[Scope_Id]
where A.Country_Id=@pCountryId


DECLARE @Demographic  NVARCHAR(max)
Declare @AttributeKey NVARCHAR(max)
DECLARE @CategoryType NVARCHAR(max)
DECLARE @ShortCode NVARCHAR(max)
DECLARE @Active bit
DECLARE @Scope NVARCHAR(max)
DECLARE @Type NVARCHAR(max)
DECLARE @IsCalculated NVARCHAR(max)
DECLARE @TimeDisplay NVARCHAR(max)
DECLARE @op1 NVARCHAR(50) ,@op2 NVARCHAR(50),@op3 NVARCHAR(50),@op4 NVARCHAR(50),@op5 NVARCHAR(50),@op6 NVARCHAR(50),@op7 NVARCHAR(50),@op8 NVARCHAR(50),@op9 NVARCHAR(50)
SELECT @op1 = Opertor ,@Demographic = ParameterValue  FROM @pParametersTable WHERE ParameterName = 'Demographic'

SELECT @op2 = Opertor ,@CategoryType = ParameterValue FROM @pParametersTable WHERE ParameterName = 'CategoryType'
SELECT @op3 = Opertor ,@Active = cast(ParameterValue as bit) FROM @pParametersTable WHERE ParameterName = 'Active'
SELECT @op4 = Opertor ,@ShortCode = ParameterValue  FROM @pParametersTable WHERE ParameterName = 'ShortCode'
SELECT @op5 = Opertor ,@Scope = ParameterValue FROM @pParametersTable WHERE ParameterName = 'Scope'
SELECT @op6 = Opertor ,@Type = ParameterValue FROM @pParametersTable WHERE ParameterName = 'Type'
SELECT @op7 = Opertor ,@IsCalculated = ParameterValue FROM @pParametersTable WHERE ParameterName = 'IsCalculated'
SELECT @op8 = Opertor ,@AttributeKey = ParameterValue  FROM @pParametersTable WHERE ParameterName = 'AttributeKey'
SELECT @op9 = Opertor ,@TimeDisplay = cast(ParameterValue as bit) FROM @pParametersTable WHERE ParameterName = 'TimeDisplay'

DECLARE @OFFSETRows INT = 0
IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 15000;

		 DECLARE @IsEqualTo VARCHAR(50) = 'IsEqualTo'
		,@IsNotEqualTo VARCHAR(50) = 'IsNotEqualTo'
		,@StartsWith VARCHAR(50) = 'StartsWith'
		,@Contains VARCHAR(50) = 'Contains'
		,@DoesNotContain VARCHAR(50) = 'DoesNotContain'
		,@EndsWith VARCHAR(50) = 'EndsWith'
		,@IsTrue VARCHAR(50) = 'Is True'
		,@IsFalse VARCHAR(50) = 'Is False'

			IF (@pOrderBy IS NULL)

	BEGIN

		SET @pOrderBy = 'CreationTimeStamp'		

	END



	IF (@pOrderType IS NULL)

		SET @pOrderType = 'desc'

	IF (@pIsExport = 0)
		select count(0)
		from #tempDemographics 	WHERE 

	(

		(@op1 IS NULL)

		OR (

			@op1 = @IsEqualTo 

			AND Demographic= @Demographic 

			)
			
	OR (

			@op1 = @IsNotEqualTo 

			AND Demographic <> @Demographic 

			)
			OR (

			@op1 = @StartsWith 

			AND Demographic LIKE '' + @Demographic + '%'

			)
		OR (

			@op1 = @Contains

			AND Demographic like '%' + @Demographic + '%'

			)
OR (

			@op1 = @DoesNotContain 

			AND Demographic not like '%' + @Demographic + '%'

			)
			OR (

			@op1 = @EndsWith 

			AND Demographic  like '%' + @Demographic + ''

			)
			 )
			 and
			 (
		(@op4 IS NULL)

		OR (

			@op4 = @IsEqualTo 

			AND ShortCode= @ShortCode

			)
			
	OR (

			@op4 = @IsNotEqualTo 

			AND ShortCode <> @ShortCode 

			)
			OR (

			@op4 = @StartsWith 

			AND ShortCode LIKE '' + @ShortCode + '%'

			)
		OR (

			@op4 = @Contains

			AND ShortCode like '%' + @ShortCode + '%'

			)
OR (

			@op4 = @DoesNotContain 

			AND ShortCode not like '%' + @ShortCode + '%'

			)
			OR (

			@op4 = @EndsWith 

			AND ShortCode  like '%' + @ShortCode + ''

			))
				and


					 (
		(@op2 IS NULL)

		OR (

			@op2 = @IsEqualTo 

			AND CategoryType= @CategoryType

			)
			
	OR (

			@op2 = @IsNotEqualTo 

			AND CategoryType <> @CategoryType 

			)
			OR (

			@op2 = @StartsWith 

			AND CategoryType LIKE '' + @CategoryType + '%'

			)
		OR (

			@op2 = @Contains

			AND CategoryType like '%' + @CategoryType + '%'

			)
OR (

			@op2 = @DoesNotContain 

			AND CategoryType not like '%' + @CategoryType + '%'

			)
			OR (

			@op2 = @EndsWith 

			AND CategoryType  like '%' + @CategoryType + ''

			))
			and



			 
			 (
		(@op3 IS NULL)

		OR (

			@op3 = @IsTrue 

			AND Active= @Active

			)
	)
	 and
			 (
		(@op4 IS NULL)

		OR (

			@op4 = @IsEqualTo 

			AND ShortCode= @ShortCode

			)
			
	OR (

			@op4 = @IsNotEqualTo 

			AND ShortCode <> @ShortCode 

			)
			OR (

			@op4 = @StartsWith 

			AND ShortCode LIKE '' + @ShortCode + '%'

			)
		OR (

			@op4 = @Contains

			AND ShortCode like '%' + @ShortCode + '%'

			)
OR (

			@op4 = @DoesNotContain 

			AND ShortCode not like '%' + @ShortCode + '%'

			)
			OR (

			@op4 = @EndsWith 

			AND ShortCode  like '%' + @ShortCode + ''

			))
			 and
			 (
		(@op5 IS NULL)

		OR (

			@op5 = @IsEqualTo 

			AND Scope= @Scope

			)
			
	OR (

			@op5 = @IsNotEqualTo 

			AND Scope <> @Scope 

			)
			OR (

			@op5 = @StartsWith 

			AND Scope LIKE '' + @Scope + '%'

			)
		OR (

			@op5 = @Contains

			AND Scope like '%' + @Scope + '%'

			)
OR (

			@op5 = @DoesNotContain 

			AND Scope not like '%' + @Scope + '%'

			)
			OR (

			@op5 = @EndsWith 

			AND Scope  like '%' + @Scope + ''

			)
			)
			 and
			 (
		(@op6 IS NULL)

		OR (

			@op6 = @IsEqualTo 

			AND [Type]= @Type

			)
			
	OR (

			@op6 = @IsNotEqualTo 

			AND [Type] <> @Type 

			)
			OR (

			@op6 = @StartsWith 

			AND [Type] LIKE '' + @Type + '%'

			)
		OR (

			@op6 = @Contains

			AND [Type] like '%' + @Type + '%'

			)
OR (

			@op6 = @DoesNotContain 

			AND [Type] not like '%' + @Type + '%'

			)
			OR (

			@op6 = @EndsWith 

			AND [Type]  like '%' + @Type + ''

			)
			)
			and

			 
			 (
		(@op7 IS NULL)

		OR (

			@op7 = @IsEqualTo 

			AND IsCalculated= @IsCalculated

			)

			)
			and
			(
		(@op9 IS NULL)

		OR (

			@op9 = @IsEqualTo 

			AND TimeDisplay= @TimeDisplay

			)

			)
			and
			(

		(@op8 IS NULL)

		OR (

			@op8 = @IsEqualTo 

			AND AttributeKey= @AttributeKey 

			)
			
	OR (

			@op8 = @IsNotEqualTo 

			AND AttributeKey <> @AttributeKey 

			)
			OR (

			@op8 = @StartsWith 

			AND AttributeKey LIKE '' + @AttributeKey+ '%'

			)
		OR (

			@op8 = @Contains

			AND AttributeKey like '%' + @AttributeKey + '%'

			)
OR (

			@op8 = @DoesNotContain 

			AND AttributeKey not like '%' + @AttributeKey + '%'

			)
			OR (

			@op8 = @EndsWith
			
			AND AttributeKey  like '%' + @AttributeKey + ''

			)
			 )

select Id,Demographic,CategoryType,ShortCode
 
, HasGroupings ,CreationTimeStamp,Active,Scope,[Type],IsCalculated,AttributeKey,TimeDisplay
 

from #tempDemographics 	WHERE 

	(

		(@op1 IS NULL)

		OR (

			@op1 = @IsEqualTo 

			AND Demographic= @Demographic 

			)
			
	OR (

			@op1 = @IsNotEqualTo 

			AND Demographic <> @Demographic 

			)
			OR (

			@op1 = @StartsWith 

			AND Demographic LIKE '' + @Demographic + '%'

			)
		OR (

			@op1 = @Contains

			AND Demographic like '%' + @Demographic + '%'

			)
OR (

			@op1 = @DoesNotContain 

			AND Demographic not like '%' + @Demographic + '%'

			)
			OR (

			@op1 = @EndsWith 

			AND Demographic  like '%' + @Demographic + ''

			)
			 )
			 and
			 (
		(@op2 IS NULL)

		OR (

			@op2 = @IsEqualTo 

			AND CategoryType= @CategoryType

			)
			
	OR (

			@op2 = @IsNotEqualTo 

			AND CategoryType <> @CategoryType 

			)
			OR (

			@op2 = @StartsWith 

			AND CategoryType LIKE '' + @CategoryType + '%'

			)
		OR (

			@op2 = @Contains

			AND CategoryType like '%' + @CategoryType + '%'

			)
OR (

			@op2 = @DoesNotContain 

			AND CategoryType not like '%' + @CategoryType + '%'

			)
			OR (

			@op2 = @EndsWith 

			AND CategoryType  like '%' + @CategoryType + ''

			)
			)
			and

			 
			 (
		(@op3 IS NULL)

		OR (

			@op3 = @IsEqualTo 

			AND Active= @Active

			)

			)
			 and
			 (
		(@op4 IS NULL)

		OR (

			@op4 = @IsEqualTo 

			AND ShortCode= @ShortCode

			)
			
	OR (

			@op4 = @IsNotEqualTo 

			AND ShortCode <> @ShortCode 

			)
			OR (

			@op4 = @StartsWith 

			AND ShortCode LIKE '' + @ShortCode + '%'

			)
		OR (

			@op4 = @Contains

			AND ShortCode like '%' + @ShortCode + '%'

			)
OR (

			@op4 = @DoesNotContain 

			AND ShortCode not like '%' + @ShortCode + '%'

			)
			OR (

			@op4 = @EndsWith 

			AND ShortCode  like '%' + @ShortCode + ''

			))
			 and
			 (
		(@op5 IS NULL)

		OR (

			@op5 = @IsEqualTo 

			AND Scope= @Scope

			)
			
	OR (

			@op5 = @IsNotEqualTo 

			AND Scope <> @Scope 

			)
			OR (

			@op5 = @StartsWith 

			AND Scope LIKE '' + @Scope + '%'

			)
		OR (

			@op5 = @Contains

			AND Scope like '%' + @Scope + '%'

			)
OR (

			@op5 = @DoesNotContain 

			AND Scope not like '%' + @Scope + '%'

			)
			OR (

			@op5 = @EndsWith 

			AND Scope  like '%' + @Scope + ''

			)
			)
			 and
			 (
		(@op6 IS NULL)

		OR (

			@op6 = @IsEqualTo 

			AND [Type]= @Type

			)
			
	OR (

			@op6 = @IsNotEqualTo 

			AND [Type] <> @Type 

			)
			OR (

			@op6 = @StartsWith 

			AND [Type] LIKE '' + @Type + '%'

			)
		OR (

			@op6 = @Contains

			AND [Type] like '%' + @Type + '%'

			)
OR (

			@op6 = @DoesNotContain 

			AND [Type] not like '%' + @Type + '%'

			)
			OR (

			@op6 = @EndsWith 

			AND [Type]  like '%' + @Type + ''

			)
			)
			and

			 
			 (
		(@op7 IS NULL)

		OR (

			@op7 = @IsEqualTo 

			AND IsCalculated= @IsCalculated

			)

			)
			and
			(
		(@op9 IS NULL)

		OR (

			@op9 = @IsEqualTo 

			AND TimeDisplay= @TimeDisplay

			))
				and
			(

		(@op8 IS NULL)

		OR (

			@op8 = @IsEqualTo 

			AND AttributeKey= @AttributeKey 

			)
			
	OR (

			@op8 = @IsNotEqualTo 

			AND AttributeKey <> @AttributeKey 

			)
			OR (

			@op8 = @StartsWith 

			AND AttributeKey LIKE '' + @AttributeKey+ '%'

			)
		OR (

			@op8 = @Contains

			AND AttributeKey like '%' + @AttributeKey + '%'

			)
OR (

			@op8 = @DoesNotContain 

			AND AttributeKey not like '%' + @AttributeKey + '%'

			)
			OR (

			@op8 = @EndsWith 

			AND AttributeKey  like '%' + @AttributeKey + ''

			)
			 )
ORDER BY CASE 

					WHEN @pOrderBy = 'Demographic'

						AND @pOrderType = 'ASC'

						THEN Demographic

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Demographic'

						AND @pOrderType = 'DESC'

						THEN Demographic
						end desc
,case
					WHEN @pOrderBy = 'CategoryType'

						AND @pOrderType = 'ASC'

						THEN CategoryType

					END ASC

				,
				case
					WHEN @pOrderBy = 'ShortCode'

						AND @pOrderType = 'ASC'

						THEN ShortCode

					END ASC,
				CASE 

					WHEN @pOrderBy = 'CategoryType'

						AND @pOrderType = 'DESC'

						THEN CategoryType


					END DESC 
					,CASE 

					WHEN @pOrderBy = 'ShortCode'

						AND @pOrderType = 'DESC'

						THEN ShortCode


					END DESC 
					,case
					WHEN @pOrderBy = 'Active'

						AND @pOrderType = 'ASC'

						THEN Active

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Active'

						AND @pOrderType = 'DESC'

						THEN Active
					END DESC
					,case
					WHEN @pOrderBy = 'Scope'

						AND @pOrderType = 'ASC'

						THEN Scope

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Scope'

						AND @pOrderType = 'DESC'

						THEN Scope
					END DESC
					,case
					WHEN @pOrderBy = 'Type'

						AND @pOrderType = 'ASC'

						THEN [Type]

					END ASC

				,CASE 

					WHEN @pOrderBy = 'Type'

						AND @pOrderType = 'DESC'

						THEN [Type]
					END DESC
					,case
					WHEN @pOrderBy = 'IsCalculated'

						AND @pOrderType = 'ASC'

						THEN IsCalculated

					END ASC

				,CASE 

					WHEN @pOrderBy = 'IsCalculated'

						AND @pOrderType = 'DESC'

						THEN IsCalculated
					END DESC
					,case
					WHEN @pOrderBy = 'AttributeKey'

						AND @pOrderType = 'ASC'

						THEN AttributeKey

					END ASC

				,CASE 

					WHEN @pOrderBy = 'AttributeKey'

						AND @pOrderType = 'DESC'

						THEN AttributeKey
					END DESC

				,case
					WHEN @pOrderBy = 'TimeDisplay'

						AND @pOrderType = 'ASC'

						THEN TimeDisplay

					END ASC

				,CASE 

					WHEN @pOrderBy = 'TimeDisplay'

						AND @pOrderType = 'DESC'

						THEN TimeDisplay
					END DESC
					
					OFFSET @OFFSETRows ROWS
			FETCH NEXT @pPageSize ROWS ONLY

			OPTION (RECOMPILE)
end

