CREATE PROC [dbo].[GetFormIdByRuleID]
(   
	@pFormRuleID			UNIQUEIDENTIFIER 	
)
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;
	  
	SELECT fr.FormId as FormId
FROM [dbo].[FormRule] fr
WHERE  fr.RuleId = @pFormRuleID             
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

