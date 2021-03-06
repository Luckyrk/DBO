
CREATE PROCEDURE [dbo].[GetLocalOfficesCodes_AdminScreen] (@pRegionalCode UNIQUEIDENTIFIER)
AS
BEGIN
	SELECT TT.VALUE AS [LocalOfficeDescription]
		,L.GUIDReference AS [LocalOfficeId]
	FROM LOCALOFFICE L
	JOIN TRANSLATION T ON L.Description_Id = T.TranslationId
	JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id
	WHERE CULTURECODE = 2057 AND L.REGION_ID=@pRegionalCode
END

