CREATE TYPE [dbo].[BelongingImport] AS TABLE(
	[Rownumber] [int] NULL,
	[BelongingTypeName] [nvarchar](300) NULL,
	[BelongingCode] [nvarchar](300) NULL,
	[BelongingStateCode] [nvarchar](100) NULL,
	[Alias] [nvarchar](300) NULL,
	[IndividualBusinessId] [nvarchar](200) NULL,
	[GroupBusinessId] [nvarchar](200) NULL,
	[FullRow] [nvarchar](max) NULL
)