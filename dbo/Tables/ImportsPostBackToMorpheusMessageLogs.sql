CREATE TABLE ImportsPostBackToMorpheusMessageLogs
(
 [Id] UNIQUEIDENTIFIER,
 [MessageBody] NVARCHAR(MAX),
 [MessageStatus] BIT,
 [GpsUser] NVARCHAR(500),
 [CreationTimeStamp] DATETIME, 
 [IsFromUi] BIT NULL DEFAULT(0)
)