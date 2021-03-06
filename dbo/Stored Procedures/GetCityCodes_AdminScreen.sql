CREATE PROCEDURE [dbo].[GetCityCodes_AdminScreen] (@pLocalOfficeCode UNIQUEIDENTIFIER)
AS
BEGIN
	SELECT TT.VALUE AS [CityDescription]
		,C.GUIDReference AS [CityId]
	FROM CITY C
	JOIN TRANSLATION T ON C.Description_Id = T.TranslationId
	JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id
	WHERE CULTURECODE = 2057 AND C.LOCALOFFICE_ID=@pLocalOfficeCode
END