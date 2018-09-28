/*##########################################################################
-- Name				: GetTranslationValue
-- Date             : 2014-11-05
-- Author           : Teena Areti
-- Purpose          : To retrieve the Key or Value When supplied tranlsation id and culture code.
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : SP
-- PARAM Definitions
					@pTranslationId UNIQUEIDENTIFIER
					,@pCultureCode INT=null
##########################################################################
-- version  user                  date        change 
-- 1.0  Teena Areti				2014-11-05   Initial
-- 1.1  Teena Areti				2014-12-09   Code for null handling
##########################################################################*/
CREATE FUNCTION [dbo].[GetTranslationValue] (
	@pTranslationId UNIQUEIDENTIFIER
	,@pCultureCode INT = NULL
	)
RETURNS NVARCHAR(1000)
AS
BEGIN
	DECLARE @retValue NVARCHAR(1000)

	SET @retValue = NULL

	IF @pCultureCode IS NOT NULL
	BEGIN
		SET @retValue = (
				SELECT TOP 1 CASE 
						WHEN T.KeyName = 'NullTitle'
							THEN ''
						WHEN TT.Translation_Id IS NULL
							THEN '{' + T.KeyName + '}'
						ELSE TT.Value
						END
				FROM Translation T
				LEFT JOIN TranslationTerm TT ON TT.Translation_Id = T.TranslationId
					AND CultureCode = @pCultureCode
				WHERE T.TranslationId = @pTranslationId
				)
	END
	ELSE
		SET @retValue = (
				SELECT TOP 1 IIF(KeyName = 'NullTitle', '', KeyName)
				FROM Translation
				WHERE TranslationId = @pTranslationId
				)

	RETURN ISNULL(@retValue, '')

END