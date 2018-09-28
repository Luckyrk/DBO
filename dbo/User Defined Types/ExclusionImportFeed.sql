CREATE TYPE [dbo].[ExclusionImportFeed] AS TABLE (
     [Rownumber]                         INT             NULL
	,[BusinessId]                        VARCHAR (100)   NULL
	,[RangeFrom]                         DATETIME        NULL
	,[RangeTo]                           DATETIME        NULL
	,[ReasonType]                        VARCHAR (100)   NULL
	,[AllIndividuals]                    VARCHAR (100)   NULL
	,[FullRow]							 NVARCHAR (MAX)	 NULL
    );

