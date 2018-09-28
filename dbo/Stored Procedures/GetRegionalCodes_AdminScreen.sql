
CREATE PROCEDURE [dbo].[GetRegionalCodes_AdminScreen]

AS

BEGIN

SELECT TT.VALUE AS [RegionalCodeDescription],R.GUIDReference AS [RegionalCodeId] FROM REGION R
JOIN TRANSLATION T ON R.Description_Id=T.TranslationId
JOIN TRANSLATIONTERM TT ON T.TranslationId=TT.Translation_Id  WHERE CULTURECODE=2057

END