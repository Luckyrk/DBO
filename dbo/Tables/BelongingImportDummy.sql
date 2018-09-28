
CREATE TABLE [dbo].[BelongingImportDummy] (
	[Rownumber]				INT NULL,
	[BelongingTypeName]		NVARCHAR(300) NULL,
	[BelongingCode]			NVARCHAR(300) NULL,
	[BelongingStateCode]	NVARCHAR(100) NULL,
	[Alias]					NVARCHAR(300) NULL,
	[IndividualBusinessId]	NVARCHAR(200) NULL,
	[GroupBusinessId]		NVARCHAR(200) NULL,
	[FullRow]				NVARCHAR(MAX) NULL,
	[FileId]				UNIQUEIDENTIFIER NOT NULL
);