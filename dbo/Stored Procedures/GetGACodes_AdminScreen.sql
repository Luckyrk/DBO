CREATE PROCEDURE [dbo].[GetGACodes_AdminScreen] (@pCityCode UNIQUEIDENTIFIER)
AS
BEGIN
	SELECT TT.VALUE AS [GeographicAreaDescription]
		,GA.GUIDReference AS [GeographicAreId]
	FROM CITYGEOGRAPHICS CG
	JOIN GEOGRAPHICAREA GA ON CG.GeohgraphicAreaId = GA.GUIDReference
	JOIN TRANSLATION T ON GA.Translation_Id = T.TranslationId
	JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id
	WHERE TT.CULTURECODE = 2057
		AND CG.CityId = @pCityCode
END
