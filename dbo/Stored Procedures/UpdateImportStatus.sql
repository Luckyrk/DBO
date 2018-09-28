CREATE PROCEDURE UpdateImportStatus
(
 @pFileId UNIQUEIDENTIFIER,
 @pUser NVARCHAR(MAX),
 @pCountryId UNIQUEIDENTIFIER,
 @pErrorMessage NVARCHAR(MAX)
)
AS
BEGIN
	EXEC InsertImportFile 'ImportFileError',@pUser,@pFileId,@pCountryId
	EXEC InsertImportAudit @pErrorMessage,@pUser,@pFileId
END