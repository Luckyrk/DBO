CREATE TYPE [dbo].[FlagsEntryRecords] AS TABLE(
[AttributeId] [int] NULL,
[AttributeValId] [int] NULL,
	[flag_detail] [varchar](100) NULL,
	[flag_valeur] [int] NULL
	,[attribute] [varchar](100) NULL,
	[value] [varchar](100) NULL,
	[shopCodeValue] [int] NULL,
	[RowType] [varchar](100) NULL
)
GO