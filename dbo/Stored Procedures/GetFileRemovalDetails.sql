CREATE PROC [dbo].[GetFileRemovalDetails]
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	SELECT GUIDReference AS Id ,Period FROM dbo.ImportFormatPeriod 
	         
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
GO
