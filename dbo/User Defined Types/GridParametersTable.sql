CREATE TYPE [dbo].[GridParametersTable] AS TABLE (
    [ParameterName]           VARCHAR (100) NOT NULL,
    [ParameterValue]          VARCHAR (100) NULL,
    [Opertor]                 VARCHAR (100) NULL,
    [LogicalOperator]         VARCHAR (100) NULL,
    [SecondParameterOperator] VARCHAR (100) NULL,
    [SecondParameterValue]    VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([ParameterName] ASC));

