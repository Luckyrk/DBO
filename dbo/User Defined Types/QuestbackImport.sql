GO
CREATE TYPE [dbo].[QuestbackImport] AS TABLE(
	[Rownumber] [int] NULL,
	[Datepointsgranted] VARCHAR(MAX),
	[Bonuspoints] VARCHAR(MAX),
	[Description] VARCHAR(MAX),
	[ProjectID] VARCHAR(MAX),
	[Projecttitle] VARCHAR(MAX),
	[Pseudo] VARCHAR(MAX),
	[Account] VARCHAR(MAX),
	[Firstname] VARCHAR(MAX),
	Name VARCHAR(MAX),
	[Email] VARCHAR(MAX),
	[ForeignID] VARCHAR(MAX),
	[Dateofentrytothepanel] VARCHAR(MAX),
	[Panelstatus] VARCHAR(MAX),
	[FullRow] VARCHAR(MAX),
	[IncentivePoint] VARCHAR(MAX)

)
GO
