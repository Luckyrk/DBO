CREATE PROCEDURE GetFileImportData @pFileId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT IFile.GUIDReference AS FileId
		,IFile.Content AS content
		,IFile.NAME AS [FileName]
		,IFormat.[Type] AS FormatType
		,IFormat.DefinedQuote AS DefinedQuote
		,IFormat.Delimiter AS Delimiter
	FROM ImportFile IFile
	INNER JOIN ImportFormat IFormat ON IFile.ImportFormat_Id = IFormat.GUIDReference
	WHERE IFile.GUIDReference = @pFileId
END