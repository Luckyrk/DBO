CREATE PROCEDURE [dbo].[GetFormAttributeDetails] (	
	@pFormID UNIQUEIDENTIFIER
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		SET XACT_ABORT ON;

		SELECT frp.GUIDReference AS Id
				,frp.AttributeName AS AttributeName
				,frp.Property_Id AS PropertyId
				,frp.Demographic_Id AS DemographicId
			FROM [dbo].[FormRule] fr
			INNER JOIN [dbo].[FormRuleParameters] frp ON fr.GUIDReference = frp.FormRule_Id
			WHERE fr.FormId = @pFormID
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage,-- Message text.
				@ErrorSeverity,-- Severity.				
				@ErrorState -- State.
				);
	END CATCH
END