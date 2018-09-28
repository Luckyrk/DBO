CREATE TABLE ImportsPostBackToMorpheusValues
(
 Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
 NamedAliasKey NVARCHAR(MAX),
 DemographicKey NVARCHAR(500),
 DemographicId UNIQUEIDENTIFIER,
 CandidateId UNIQUEIDENTIFIER,
 MessageType NVARCHAR(500),
 DemographicValue NVARCHAR(MAX),
 ImportFileId UNIQUEIDENTIFIER,
 ProcessedStatus BIT,
 GPSUser NVARCHAR(200),
 CreationTimeStamp  DATETIME,
 GPSUpdateTimestamp DATETIME
)

GO
CREATE NONCLUSTERED INDEX [IX_ImportsPostBackToMorpheusValues_ImportFileId] ON [dbo].[ImportsPostBackToMorpheusValues]([ImportFileId] ASC)
GO