CREATE PROCEDURE InsertMorpheusMessageLog
(
	@pMessageBody NVARCHAR(MAX),
	@pStatus BIT,
	@pGPSUser NVARCHAR(200),
	@pSystemDate DATETIME
)
AS
BEGIN
	DECLARE @messageId UNIQUEIDENTIFIER = NEWID()

	INSERT INTO dbo.ImportsPostBackToMorpheusMessageLogs(Id,[MessageBody],[MessageStatus],[GpsUser],[CreationTimeStamp],[IsFromUi]) 
	VALUES (@messageId,@pMessageBody,@pStatus,@pGPSUser,@pSystemDate,0)

	SELECT @messageId
END