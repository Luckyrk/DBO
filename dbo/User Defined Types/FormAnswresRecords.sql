GO
CREATE TYPE [dbo].[FormAnswresRecords] AS TABLE(
	[RowNumber] [int] NULL,
	[DemographicId] [uniqueidentifier] NULL,
	[DemographicType] [varchar](50) NULL,
	[AttributeValueId] [uniqueidentifier] NULL,
	[Value] [nvarchar](100) NULL,
	[CandidateId] [uniqueidentifier] NULL,
	[RespondentId] [uniqueidentifier] NULL,
	[DiscriminatorType] [nvarchar](400) NULL,
	[BelongingTypeId] [uniqueidentifier] NULL,
	[BelongingCode] [nvarchar](400) NULL,
	[StateId] [uniqueidentifier] NULL,
	[BelongingType] [nvarchar](400) NULL,
	[BelongingSectionId] [uniqueidentifier] NULL,
	[FreeText] NVARCHAR(400) 
)
GO