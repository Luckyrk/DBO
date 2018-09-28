CREATE TABLE [dbo].[Region](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[Region_Code] [varchar](50) NULL,
	[Description_Id] [uniqueidentifier] NOT NULL,
	[GPSUser] [nvarchar](50) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
 CONSTRAINT [PK_dbo.Region] PRIMARY KEY CLUSTERED 
(
	[GUIDReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Region]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Region_dbo.Translation_Description_ID] FOREIGN KEY([Description_Id])
REFERENCES [dbo].[Translation] ([TranslationId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Region] CHECK CONSTRAINT [FK_dbo.Region_dbo.Translation_Description_ID]
GO


