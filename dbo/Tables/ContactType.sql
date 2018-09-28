
CREATE TABLE [dbo].[ContactType](
	[GuidReference] [uniqueidentifier] NOT NULL,
	[Code] [int] NULL,
	[LocalDescription] [nvarchar](max) NULL,
	[Description] [nvarchar](200) NULL,
	[IsActive] [bit] NULL,
	[CountryId] [uniqueidentifier] NULL,
	[GPSUser] [nvarchar](200) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[GuidReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


