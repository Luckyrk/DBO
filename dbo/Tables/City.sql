CREATE TABLE [dbo].[City](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[Description_Id] [uniqueidentifier] NOT NULL,
	[City_Code] [varchar](50) NOT NULL,
	[LocalOffice_id] [uniqueidentifier] NULL,
	[GPSUser] [nvarchar](50) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
 CONSTRAINT [PK_dbo.City] PRIMARY KEY CLUSTERED 
(
	[GUIDReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK_dbo.City_dbo.LocalOffice_LocalOffice_id] FOREIGN KEY([LocalOffice_id])
REFERENCES [dbo].[LocalOffice] ([GUIDReference])
GO

ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK_dbo.City_dbo.LocalOffice_LocalOffice_id]
GO

ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK_dbo.City_dbo.Translation_Description_Id] FOREIGN KEY([Description_Id])
REFERENCES [dbo].[Translation] ([TranslationId])
GO

ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK_dbo.City_dbo.Translation_Description_Id]
GO


