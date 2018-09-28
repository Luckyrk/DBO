CREATE TABLE [dbo].[CountryViewAccess] (
    [UserId]      NVARCHAR (50) NOT NULL,
    [Country]     NVARCHAR (2)  NOT NULL,
    [CultureCode] INT           NOT NULL,
    [AllowPID]    BIT           NOT NULL
);

