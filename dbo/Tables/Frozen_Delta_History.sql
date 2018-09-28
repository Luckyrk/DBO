CREATE TABLE [dbo].[Frozen_Delta_History](
	[Id] [uniqueidentifier] NOT NULL,
	[CountryCode] [varchar](10) NULL,
	[ViewName] [varchar](500) NULL,
	[LastRunDate] [datetime] NULL,
	[Country_LastRunDate] [datetime] NULL,
	[CreationDateTime] [datetime] NULL,
	[GPSUpdateTimeStamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Frozen_Delta_History] ADD  DEFAULT (newid()) FOR [Id]
GO