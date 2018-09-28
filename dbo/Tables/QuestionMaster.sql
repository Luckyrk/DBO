
CREATE TABLE [dbo].[QuestionMaster](
	[GuidReference] [uniqueidentifier] NOT NULL,
	[Code] [int] NULL,
	[ContactTypeId] [uniqueidentifier] NULL,
	[Type] [nvarchar](50) NULL,
	[Description] [nvarchar](1000) NULL,
	[LocalDescription] [nvarchar](1000) NULL,
	[NextQuestion] [nvarchar](1000) NULL,
	[CountryId] [uniqueidentifier] NULL,
	[GPSUser] [nvarchar](200) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[GuidReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[QuestionMaster]  WITH CHECK ADD FOREIGN KEY([ContactTypeId])
REFERENCES [dbo].[ContactType] ([GuidReference])
GO


