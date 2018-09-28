CREATE PROCEDURE GetTranslationValueByKey (
	@pKeyName VARCHAR(100)
	,@pCultureCode INT
	)
AS
BEGIN
BEGIN TRY 
	SELECT Value as TranslationValue
	FROM TranslationTerm
	WHERE Translation_Id = (
			SELECT TranslationId
			FROM Translation
			WHERE KeyName = @pKeyName
			)
		AND CultureCode = @pCultureCode
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH 
END

