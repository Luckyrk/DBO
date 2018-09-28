CREATE PROCEDURE UpdateStatusImportsPostBackToMorpheusValue
(
 @pImportsPostBackToMorpheusValueId UNIQUEIDENTIFIER,
 @pStatus BIT,
 @pMessageBody NVARCHAR(MAX),
 @ErrorLog NVARCHAR(MAX)=NULL
)
AS
BEGIN
BEGIN TRY 
 UPDATE ImportsPostBackToMorpheusValues SET ProcessedStatus=@pStatus WHERE Id=@pImportsPostBackToMorpheusValueId
 
 IF @pStatus=1
 BEGIN
	INSERT INTO ImportsPostBackToMorpheusValuesPurge(Id,NamedAliasKey,DemographicKey,DemographicId,CandidateId,MessageType,DemographicValue,ImportFileId,ProcessedStatus,GPSUser,CreationTimeStamp,GPSUpdateTimestamp)
	SELECT Id,NamedAliasKey,DemographicKey,DemographicId,CandidateId,MessageType,DemographicValue,ImportFileId,ProcessedStatus,GPSUser,CreationTimeStamp,GPSUpdateTimestamp
	FROM ImportsPostBackToMorpheusValues
	WHERE Id=@pImportsPostBackToMorpheusValueId

	DELETE FROM ImportsPostBackToMorpheusValues WHERE Id=@pImportsPostBackToMorpheusValueId 
 END

 IF @ErrorLog IS NOT NULL
 BEGIN
	UPDATE ImportsPostBackToMorpheusMessageLogs SET MessageStatus=0 WHERE [Id]=@pImportsPostBackToMorpheusValueId

	INSERT INTO PostBackGpsToMorpheusErrorLog(Id,PostBackToMorpheusMessageId,MessageBody,ERRORMESSAGE,CreationTimeStamp)
	SELECT NEWID(),@pImportsPostBackToMorpheusValueId,@pMessageBody,@ErrorLog,GETDATE()
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