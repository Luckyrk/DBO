CREATE TYPE [dbo].[tbl_DemandedProductAnswer] AS TABLE (
    [Rownumber]                    INT           NULL,
    [AnswerCode]                   VARCHAR (100) NULL,
    [BusinessId]                   VARCHAR (100) NULL,
    [PanelCode]                    VARCHAR (100) NULL,
    [ProductCategoryCode]          VARCHAR (100) NULL,
    [YearPeriod]                   VARCHAR (100) NULL,
    [CollaborationMethodologyCode] VARCHAR (50)  NULL,
    [Bought]                       VARCHAR (100) NULL,
    [EndDate]                      VARCHAR (100) NULL,
    [Comment]                      VARCHAR (100) NULL,
    [FullRow]                      VARCHAR (MAX) NULL);

