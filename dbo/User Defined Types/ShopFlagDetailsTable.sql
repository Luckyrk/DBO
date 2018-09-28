CREATE TYPE [dbo].[ShopFlagDetailsTable] AS TABLE(
	[ShopCode] [int] NOT NULL,
	[FlagId] [int] NOT NULL,
	[FlagValue] [int] NOT NULL,
	[OldFlagValue] [int] NOT NULL,
	[RecordType] [varchar](2) NOT NULL
)
GO