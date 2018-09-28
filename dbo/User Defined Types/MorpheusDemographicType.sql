CREATE TYPE [dbo].[MorpheusDemographicType] AS TABLE 
(
 AppUserGUID	NVARCHAR (300),
 AttributeKey	NVARCHAR (300),
 AttributeName  NVARCHAR (MAX),
 AttributeValue  NVARCHAR (MAX)
)
