GO
CREATE TYPE [dbo].[FormRuleParameterDetails] AS TABLE(
	[FormRule_Id] [uniqueidentifier] NOT NULL,
	[Demographic_Id] [uniqueidentifier] NOT NULL,
	[AttributeName] [nvarchar](150) NOT NULL,
	[Property_Id] [nvarchar](150) NOT NULL,
	[GPSUser] [nvarchar](50) NULL
)
GO


