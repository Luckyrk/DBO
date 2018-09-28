CREATE TYPE [dbo].[IncentiveTransactionsImportFeedUpdate] AS TABLE (
    [Rownumber]				INT            NULL,
    [BusinessId]			NVARCHAR (MAX) NULL,
    [GroupId]				NVARCHAR (MAX) NULL,
    [IncentiveCode]			INT NULL,
    [TransactionDate]		DATETIME NULL,
    [Comments]				NVARCHAR (MAX) NULL,
    [Points]				INT NULL,
    [PanelNameOrPanelCode]  NVARCHAR (MAX) NULL,
    [SynchronisationDate]   DATETIME NULL,
    [TransactionSource]     NVARCHAR (MAX) NULL,
	[FullRow]               NVARCHAR (MAX) NULL,
	[GACode]				NVARCHAR (100) NULL
   );