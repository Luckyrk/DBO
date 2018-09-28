CREATE TABLE [dbo].[MorpheusQueueLog](
	[MessageId] [uniqueidentifier] NOT NULL,
	[QueueId]  [varchar](500) NULL,
	[MessageBody] [nvarchar](max) NULL,
	[MessageStatus] [int] NULL,
	[CountryCode] [varchar](10) NULL,
	CreationTimeStamp DATETIME
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX MorpheusQueueLogMessageIdIndex
ON [dbo].[MorpheusQueueLog] ([MessageId])
