CREATE TYPE [dbo].[Demographics] AS TABLE (
    [Rownumber]        INT            NULL,
    [DemographicName]  NVARCHAR (MAX) NULL,
    [DemographicValue] NVARCHAR (MAX) NULL,
	[UseShortCode] BIT null);

