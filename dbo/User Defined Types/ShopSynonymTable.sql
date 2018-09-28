CREATE TYPE [dbo].[ShopSynonymTable] AS TABLE(
	[ShopCode] [int] NOT NULL,
	[Synonym] [nvarchar](150) NOT NULL,
	[OldSynonym] [nvarchar](150) NULL,
	[ShopShortName] [nvarchar](150) NOT NULL,
	[RecordType] [varchar](2) NOT NULL
)