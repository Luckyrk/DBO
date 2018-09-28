CREATE PROCEDURE [dbo].[DeleteImportFile] (@pImportFile UNIQUEIDENTIFIER)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		SET XACT_ABORT ON;

		DECLARE @ImportFormatPeriodCode INT
			,@ImportFileCreationDate DATETIME
			,@FileExpiryDate DATETIME = '1900-01-01 00:00:00.000'

		SELECT @ImportFileCreationDate = I.CreationTimeStamp
			,@ImportFormatPeriodCode = IP.Code
		FROM [ImportFile] I
		INNER JOIN [ImportFormat] II ON II.GUIDReference = I.ImportFormat_Id
		INNER JOIN [ImportFormatPeriod] IP ON IP.GUIDReference = II.ImportFormatPeriod_Id
		WHERE I.GUIDReference = @pImportFile

		IF (@ImportFormatPeriodCode = 1)
			SET @FileExpiryDate = DATEADD(DAY, 15, @ImportFileCreationDate)
		ELSE IF (@ImportFormatPeriodCode = 2)
			SET @FileExpiryDate = DATEADD(MONTH, 1, @ImportFileCreationDate)
		ELSE IF (@ImportFormatPeriodCode = 3)
			SET @FileExpiryDate = DATEADD(MONTH, 3, @ImportFileCreationDate)
		ELSE IF (@ImportFormatPeriodCode = 4)
			SET @FileExpiryDate = DATEADD(MONTH, 6, @ImportFileCreationDate)
		ELSE IF (@ImportFormatPeriodCode = 5)
			SET @FileExpiryDate = DATEADD(YEAR, 1, @ImportFileCreationDate)

		DELETE S
		FROM [ImportFile] AS I JOIN [StateDefinitionHistory] AS S
		ON I.GUIDReference = S.ImportFile_Id
		WHERE DATEDIFF(DAY, GETDATE(), @FileExpiryDate) >= 0
			AND I.GUIDReference = @pImportFile

	    DELETE FROM [ImportAudit] 				
		WHERE DATEDIFF(DAY, GETDATE(), @FileExpiryDate) >= 0
			AND File_Id = @pImportFile

        IF NOT EXISTS(Select 1 from [StateDefinitionHistory] Where ImportFile_Id = @pImportFile)
		DELETE FROM [ImportFile] 				
		WHERE DATEDIFF(DAY, GETDATE(), @FileExpiryDate) >= 0
			AND GUIDReference = @pImportFile
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage,-- Message text.				
				@ErrorSeverity,-- Severity.								
				@ErrorState -- State.
				);
	END CATCH
END	