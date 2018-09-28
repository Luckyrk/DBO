
CREATE TABLE [dbo].[MorpheusErrorLog](
	[MessageId] [uniqueidentifier] NOT NULL,
	[ErrorMessage] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO