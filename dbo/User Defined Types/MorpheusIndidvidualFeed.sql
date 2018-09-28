
/****** Object:  UserDefinedTableType [dbo].[MorpheusIndidvidualFeed]    Script Date: 10/18/2016 8:11:48 PM ******/
CREATE TYPE [dbo].[MorpheusIndidvidualFeed] AS TABLE(
	[AppUserGUID] [nvarchar](300) NULL,
	[IndividualGUID] [nvarchar](300) NULL,
	[FirstName] [nvarchar](300) NULL,
	[LastName] [nvarchar](300) NULL,
	[DateOfBirth] [nvarchar](300) NULL,
	[Gender] [nvarchar](10) NULL,
	[IsAppUser] [nvarchar](10) NULL,	
	[LeftHousehold] [nvarchar](300) NULL,	
	[LeftHouseholdDate] [nvarchar](300) NULL,	
	[Title] [nvarchar](300) NULL
)
GO


