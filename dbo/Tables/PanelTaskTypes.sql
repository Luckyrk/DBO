CREATE TABLE [dbo].[PanelTaskType](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[Description_Id] [uniqueidentifier] NOT NULL,
	[Country_Id] [uniqueidentifier] NOT NULL,
	[GPSUser] [nvarchar](50) NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
	[CreationTimeStamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[GUIDReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


