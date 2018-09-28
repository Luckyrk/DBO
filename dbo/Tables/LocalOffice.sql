CREATE TABLE [dbo].[LocalOffice](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[Description_Id] [uniqueidentifier] NOT NULL,
	[Office_Code] [varchar](100) NOT NULL,
	[GPSUser] [nvarchar](50) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
	[Region_Id] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Office] PRIMARY KEY CLUSTERED 
(
	[GUIDReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LocalOffice]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LocalOffice_dbo.Region_Region_Id] FOREIGN KEY([Region_Id])
REFERENCES [dbo].[Region] ([GUIDReference])
GO

ALTER TABLE [dbo].[LocalOffice] CHECK CONSTRAINT [FK_dbo.LocalOffice_dbo.Region_Region_Id]
GO

ALTER TABLE [dbo].[LocalOffice]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LocalOffice_dbo.Translation_Description_ID] FOREIGN KEY([Description_Id])
REFERENCES [dbo].[Translation] ([TranslationId])
GO

ALTER TABLE [dbo].[LocalOffice] CHECK CONSTRAINT [FK_dbo.LocalOffice_dbo.Translation_Description_ID]
GO


