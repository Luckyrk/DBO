

CREATE TABLE [dbo].[AnswersMaster](
	[GuidReference] [uniqueidentifier] NOT NULL,
	[QuestionId] [uniqueidentifier] NULL,
	[AnswerSequence] [int] NULL,
	[Description] [nvarchar](1000) NULL,
	[LocalDescription] [nvarchar](1000) NULL,
	[NextQuestion] [int] NULL,
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

ALTER TABLE [dbo].[AnswersMaster]  WITH CHECK ADD FOREIGN KEY([QuestionId])
REFERENCES [dbo].[QuestionMaster] ([GuidReference])
GO


