CREATE PROCEDURE [dbo].[DeleteFormDetails] (
	@pRuleId UNIQUEIDENTIFIER
	
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		SET XACT_ABORT ON;
		DECLARE @FormRule_Id UNIQUEIDENTIFIER;
		SELECT @FormRule_Id = GUIDReference FROM [dbo].[FormRule] where ruleid = @pRuleId
		IF EXISTS( SELECT 1 FROM formrule where ruleid = @pRuleId)	
		BEGIN		
		DELETE
		FROM [dbo].[FormRuleParameters]
		WHERE FormRule_Id = @FormRule_Id
		END
		
		DELETE FROM [dbo].[FormRule] WHERE ruleid = @pRuleId

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