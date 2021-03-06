﻿CREATE TABLE ImportsPostBackToMorpheusValuesPurge
(
 Id UNIQUEIDENTIFIER NOT NULL,
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