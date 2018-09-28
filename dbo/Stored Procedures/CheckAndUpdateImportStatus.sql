CREATE PROCEDURE CheckAndUpdateImportStatus
(
	@pFileId UNIQUEIDENTIFIER,
	@pUser NVARCHAR(MAX),
	@pCountryId UNIQUEIDENTIFIER
)

AS
BEGIN
SET NOCOUNT ON;
DECLARE @RTNVALUE BIT=0
IF EXISTS (
		SELECT 1
		FROM ImportFile I
		INNER JOIN StateDefinition SD ON SD.Id = I.State_Id AND I.GUIDReference = @pFileId
		WHERE SD.Code = 'ImportFilePending' AND SD.Country_Id = @pCountryId
		)
BEGIN

	EXEC InsertImportFile 'ImportFileProcessing'
		,@pUser
		,@pFileId
		,@pCountryId

	SET @RTNVALUE = 1

END
SELECT @RTNVALUE
END