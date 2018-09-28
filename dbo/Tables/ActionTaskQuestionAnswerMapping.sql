
CREATE TABLE [dbo].[ActionTaskQuestionAnswerMapping](
	[GuidReference] [uniqueidentifier] NULL,
	[IndividualId] [uniqueidentifier] NULL,
	[ActionTaskTypeId] [uniqueidentifier] NULL,
	[QuestionId] [uniqueidentifier] NULL,
	[AnswerId] [uniqueidentifier] NULL,
	[AnswerText] [nvarchar](1000) NULL,
	[GPSUser] [nvarchar](200) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL
) ON [PRIMARY]

GO


