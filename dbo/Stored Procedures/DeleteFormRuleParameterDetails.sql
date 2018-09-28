CREATE PROCEDURE [dbo].[DeleteFormRuleParameterDetails] @formRuleParameter [dbo].[FormRuleParameterDetails] READONLY
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		SET XACT_ABORT ON;

  DELETE FROM [dbo].[FormRuleParameters] 
  FROM [dbo].[FormRuleParameters] T INNER JOIN @formRuleParameter P
  ON T.Demographic_Id = P.Demographic_Id
  AND T.AttributeName = P.AttributeName
  AND T.Property_Id = P.Property_Id
  AND T.FormRule_Id = P.FormRule_Id

	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage
				,-- Message text.
				@ErrorSeverity
				,-- Severity.
				@ErrorState -- State.
				);
	END CATCH
END