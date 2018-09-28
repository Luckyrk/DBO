CREATE TABLE ImportsPostBackToMorpheusConfiguration
(
  Id UNIQUEIDENTIFIER NOT NULL,
  ImportDefinitionTypeName NVARCHAR(200),
  DemogrpahicId UNIQUEIDENTIFIER,
  DemogrpahicKey NVARCHAR(MAX),
  CountryId UNIQUEIDENTIFIER,
  NamedAliasContextId UNIQUEIDENTIFIER,
  CountryISO2A NVARCHAR(50),
  MessageType NVARCHAR(500),
  EnableKeyAppSettingKey NVARCHAR(MAX),
  MessageTypePropertyName NVARCHAR(500),
  IsPostBackRequired BIT,
  GPSUser NVARCHAR(200),
  CreationTimeStamp  DATETIME,
  GPSUpdateTimestamp DATETIME
)