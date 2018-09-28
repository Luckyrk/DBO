CREATE PROCEDURE GetImportsPostBackToMorpheusValuesByImportFileId
(
 @pImportFileId UNIQUEIDENTIFIER
)
AS
BEGIN
BEGIN TRY 
	DECLARE @CountryId UNIQUEIDENTIFIER
	DECLARE @ImportFileSuccessId UNIQUEIDENTIFIER

	SELECT @CountryId=Country_Id FROM ImportFile WHERE GUIDReference=@pImportFileId

	SELECT @ImportFileSuccessId=sd.Id 
	FROM 
	StateDefinition sd INNER JOIN Country c ON C.CountryId=sd.Country_Id
	WHERE sd.code='ImportFileSuccess' 
	AND c.CountryId=@CountryId
	
	IF EXISTS(SELECT 1 FROM ImportFile WHERE GUIDReference=@pImportFileId AND State_Id=@ImportFileSuccessId)
	BEGIN
		SELECT Id,NamedAliasKey,DemographicKey,DemographicId,CandidateId,MessageType,DemographicValue,ImportFileId,ProcessedStatus,GPSUser,CreationTimeStamp,GPSUpdateTimestamp
		FROM ImportsPostBackToMorpheusValues
		WHERE ImportFileId=@pImportFileId AND ProcessedStatus=0 
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