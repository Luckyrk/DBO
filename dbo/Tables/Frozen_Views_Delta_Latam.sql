CREATE TABLE [dbo].[Frozen_Views_Delta_Latam](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[HouseHoldId] [bigint] NULL,
	[Modifieddate] [datetime] NULL,
	[Syncdate] [datetime] NULL,
	[CountryISO2A] [nvarchar](4) NULL,
	[ViewName] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
