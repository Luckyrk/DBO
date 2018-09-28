CREATE PROCEDURE [dbo].[GetCritxl] @Year NVARCHAR(10)
	,@Period NVARCHAR(10)
	,@CountryId UNIQUEIDENTIFIER
	,@CultureCode INT = 2057
AS
BEGIN
	SELECT A.GUIDReference AS AttributeId
		,TT.Value + IIF(A.ShortCode IS NOT NULL, '  (' + A.ShortCode + ')', '') AS AttributeName
		,CAST(MAX(CAST(x.UseShortCode AS INT)) AS BIT) AS UseShortCode
	FROM Critxl X
	JOIN Country CN ON CN.CountryId = X.Country_Id
	JOIN Attribute A ON X.AttributeKey = A.[Key] AND A.Country_Id = X.Country_Id
	JOIN TranslationTerm TT ON TT.CultureCode = @CultureCode AND TT.Translation_Id = A.Translation_Id	
	LEFT JOIN FieldConfiguration FC ON FC.CountryConfiguration_Id = CN.Configuration_Id
		AND FC.[Key] = 'ShortCode'
		AND FC.[Visible] = 1
	WHERE X.Country_Id = @CountryId
		AND X.[Year] = @Year
		AND X.Period = @Period
	GROUP BY A.GUIDReference, TT.Value, A.ShortCode

	SELECT CAST(MAX(CAST(x.Locked AS INT)) AS BIT) AS Locked
	FROM Critxl X
	WHERE X.Country_Id = @CountryId
		AND X.[Year] = @Year
		AND X.Period = @Period

	SELECT DISTINCT CONCAT (
			X.[Year]
			,'.'
			,RIGHT(CONCAT (
					'00'
					,X.Period
					), 2)
			)
	FROM Critxl X
	WHERE X.Country_Id = @CountryId
	ORDER BY 1
END