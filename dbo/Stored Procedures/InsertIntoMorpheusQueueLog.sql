CREATE PROCEDURE InsertIntoMorpheusQueueLog
(
	@MessageId NVARCHAR(500),
	@QueueId NVARCHAR(2000),
	@MessageBody NVARCHAR(MAX),
	@CountryCode NVARCHAR(500)
)
AS
BEGIN
	INSERT INTO dbo.MorpheusQueueLog([MessageId],[QueueId],[MessageBody],[MessageStatus],[CountryCode]) 
	VALUES (@MessageId,@QueueId,@MessageBody,0,@CountryCode)
END