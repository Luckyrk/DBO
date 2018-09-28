CREATE TABLE [dbo].[Frozen_HouseHold_MX_Delta_BackUp](
	[GroupBusinessId] [varchar](100) NOT NULL,
	[RegionGroup] [nvarchar](max) NULL,
	[City code] [nvarchar](max) NULL,
	[Zone Code] [nvarchar](max) NULL,
	[County code] [nvarchar](max) NULL,
	[District code] [nvarchar](max) NULL,
	[Sub district code] [nvarchar](max) NULL,
	[Sector code] [nvarchar](max) NULL,
	[Interviewer code] [nvarchar](max) NULL,
	[Load_date] [datetime] NULL,
	[isUpdated] [int] NOT NULL,
	[Country_Load_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Frozen_HouseHold_MX_Delta_BackUp] ADD  DEFAULT ((1)) FOR [isUpdated]
GO