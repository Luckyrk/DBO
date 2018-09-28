create PROCEDURE [dbo].[SetKitActiveStatus_AdminScreen]
(
	 @GUIDReference UNIQUEIDENTIFIER
)
AS
BEGIN
BEGIN TRY 
	UPDATE [dbo].[StockKit]
	SET IsActive = CASE
						WHEN IsActive = CAST(0 AS BIT) THEN CAST(1 AS BIT)
						WHEN IsActive = CAST(1 AS BIT) THEN CAST(0 AS BIT)
					END
	WHERE GUIDReference = @GUIDReference

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

