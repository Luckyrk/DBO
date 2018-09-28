CREATE TYPE [dbo].[MorpheusEReceiptsType] AS TABLE 
(
 AppUserGUID	NVARCHAR (300),
 EmailAddress  NVARCHAR (MAX),
 CreatedDateTime  DATETIME,
 CreatedBy NVARCHAR (MAX),
 UpdatedDateTime DATETIME,
 UpdatedBy NVARCHAR (MAX),
 [Status] INT
)