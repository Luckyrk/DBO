CREATE PROCEDURE InsertMorpheusErrorLog
(
	@pMessageId UNIQUEIDENTIFIER,
	@pMessageBody NVARCHAR(MAX),
	@pError NVARCHAR(200),
	@pSystemDate DATETIME
)
AS
BEGIN
	
	UPDATE dbo.ImportsPostBackToMorpheusMessageLogs SET [MessageStatus] = 0 WHERE Id = @pMessageId

	INSERT INTO dbo.PostBackGpsToMorpheusErrorLog(Id,[PostBackToMorpheusMessageId],[MessageBody],[ERRORMESSAGE],[CreationTimeStamp]) 
	VALUES (NEWID(),@pMessageId,@pMessageBody,@pError,@pSystemDate)
END