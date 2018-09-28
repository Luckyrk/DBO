CREATE TABLE MorpheusEReceipts
(
 MorpheusEReceiptsId UNIQUEIDENTIFIER NOT NULL,
 CandidateId UNIQUEIDENTIFIER NOT NULL,
 EmailAddress NVARCHAR(2000) NOT NULL,
 StateId UNIQUEIDENTIFIER NOT NULL,
 CountryId UNIQUEIDENTIFIER NULL,
 GPSUser NVARCHAR(200),
 CreationTimeStamp DATETIME,
 GPSUpdateTimestamp DATETIME,
 CONSTRAINT [PK_MorpheusEReceipts] PRIMARY KEY ([MorpheusEReceiptsId] ASC),
 CONSTRAINT [FK_MorpheusEReceipts_Candidate] FOREIGN KEY ([CandidateId]) REFERENCES Candidate(GUIDReference),
 CONSTRAINT [FK_MorpheusEReceipts_StateDefinition] FOREIGN KEY ([StateId]) REFERENCES StateDefinition(Id),
 CONSTRAINT [UQ_MorpheusEReceipts] UNIQUE NONCLUSTERED ([CandidateId],[EmailAddress])
)