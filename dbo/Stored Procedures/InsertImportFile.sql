CREATE PROCEDURE InsertImportFile @pCode VARCHAR(100)
	,@pUser VARCHAR(100)
	,@pFileId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
	IF (@pCode='ImportFilePending')
	BEGIN
		UPDATE ImportFile
		SET State_Id = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = @pCode
					AND Country_Id = @pCountryId
				) , [Date]=(select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
				WHERE GUIDReference = @pFileId
	END
	ELSE
	BEGIN
		UPDATE ImportFile
		SET State_Id = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = @pCode
				AND Country_Id = @pCountryId
			) WHERE GUIDReference = @pFileId
	END
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