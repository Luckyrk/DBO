CREATE PROCEDURE [dbo].[UpdateImportFormat]
(
@pImportFormatId UNIQUEIDENTIFIER,
@pImportPeriodId UNIQUEIDENTIFIER
)
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;

	UPDATE ImportFormat SET ImportFormatPeriod_Id = @pImportPeriodId
	WHERE GUIDReference = @pImportFormatId
	         
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

