CREATE TYPE [dbo].[RepeatableFeed] AS TABLE 
(
	 [Rownumber] INT NULL
	,[AddressLine1]                      NVARCHAR (200)  NULL
	,[AddressLine2]                      NVARCHAR (200)  NULL
	,[AddressLine3]                      NVARCHAR (200)  NULL
	,[AddressLine4]                      NVARCHAR (200)  NULL
	,[PostCode]                          NVARCHAR (100)  NULL
	,[AddressType]						 NVARCHAR (200)  NULL
	,[Order]							 INT
)