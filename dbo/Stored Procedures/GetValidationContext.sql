CREATE PROC [dbo].[GetValidationContext]
(   
	@pFormID			UNIQUEIDENTIFIER 	
)
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;
	  
	select Name from FormRule fr
INNER JOIN dbo.BusinessRule br
ON fr.RuleId = br.GUIDReference
where fr.FormId = @pFormID            
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END