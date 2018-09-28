CREATE FUNCTION [dbo].[GetTranslationValue_tbl] (@pTranslationId UNIQUEIDENTIFIER,@pCultureCode INT = NULL) 
returns table as
return
(
SELECT TOP 1 CASE 
       WHEN T.KeyName = 'NullTitle' THEN '' 
          WHEN @pCultureCode is null THEN T.KeyName
          WHEN TT.Translation_Id IS NULL THEN '{' + T.KeyName + '}'
          ELSE TT.Value
       END Value,
	   CASE WHEN T.KeyName = 'NullTitle' THEN '' 
	   ELSE T.KeyName END KeyName
FROM Translation T
LEFT JOIN TranslationTerm TT ON TT.Translation_Id = T.TranslationId
AND (CultureCode = @pCultureCode or @pCultureCode is null)
WHERE T.TranslationId = @pTranslationId
)