CREATE TABLE [dbo].[DemographicsDummy](
		[Rownumber] [int] NULL,
		[DemographicName] [nvarchar](max) NULL,
		[DemographicValue] [nvarchar](max) NULL,
		[UseShortCode] [bit] NULL,
		[fileid] [NVARCHAR](500)
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]