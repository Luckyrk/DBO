CREATE TABLE MorpheusEReceiptsHistory
(
 MorpheusEReceiptsHistoryId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
 MorpheusEReceiptsId UNIQUEIDENTIFIER NOT NULL,
 CandidateId UNIQUEIDENTIFIER NOT NULL,
 EmailAddress NVARCHAR(2000) NOT NULL,
  From_Id UNIQUEIDENTIFIER NOT NULL,
 To_Id UNIQUEIDENTIFIER NOT NULL,
 GPSUser NVARCHAR(200),
 CreationTimeStamp DATETIME,
 GPSUpdateTimestamp DATETIME,
 CONSTRAINT [FK_MorpheusEReceipts_StateDefinition_From_Id] FOREIGN KEY ([From_Id]) REFERENCES StateDefinition(Id),
 CONSTRAINT [FK_MorpheusEReceipts_StateDefinition_To_Id] FOREIGN KEY ([To_Id]) REFERENCES StateDefinition(Id)
)