CREATE TABLE [dbo].[AttributeHistoryDenorm]
(
	GUIDReference	UNIQUEIDENTIFIER,
	BusinessId		VARCHAR(20),
	BelongingType	NVARCHAR(200),
	BelongingCode	INT,
	AttributeKey	NVARCHAR(200),
	CurrAtt_Value	NVARCHAR(200),
	History_Value	NVARCHAR(200),
	ValueDesc		NVARCHAR(500),
	AuditDate		DATETIME,
	GPSUser			NVARCHAR(200),
	AuditOperation	CHAR(1),
	CDCROW_Id		BIGINT,
	CountryISO2A	CHAR(2)
)
GO

CREATE INDEX IDX_BusinessId ON AttributeHistoryDenorm (BusinessId, CountryISO2A)
GO

CREATE INDEX IDX_AuditDate ON AttributeHistoryDenorm (AuditDate, CountryISO2A)
GO

CREATE INDEX IDX_CDCROW_Id ON AttributeHistoryDenorm (CDCROW_Id)
GO