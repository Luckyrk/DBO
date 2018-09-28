CREATE PROCEDURE InserttoImportsPostBackToMorpheusMessageLogs
(
 @pImportsPostBackToMorpheusValueId UNIQUEIDENTIFIER,
 @pStatus BIT,
 @pMessageBody NVARCHAR(MAX),
 @pUser NVARCHAR(500)
)
AS
BEGIN
	INSERT INTO ImportsPostBackToMorpheusMessageLogs([Id],[MessageBody],[MessageStatus],[GpsUser],[CreationTimeStamp])
	VALUES(@pImportsPostBackToMorpheusValueId,@pMessageBody,@pStatus,@pUser,GETDATE())
END