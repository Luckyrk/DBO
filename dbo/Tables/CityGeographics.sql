CREATE TABLE [dbo].[CityGeographics](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[Description_Id] [uniqueidentifier] NOT NULL,
	[GeographicalArea_Code] [varchar](50) NOT NULL,
	[City_Id] [uniqueidentifier] NULL,
	[GPSUser] [nvarchar](50) NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
 CONSTRAINT [PK_dbo.CityGeographics] PRIMARY KEY CLUSTERED 
(
	[GUIDReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[CityGeographics]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CityGeographics_dbo.City_City_Id] FOREIGN KEY([City_Id])
REFERENCES [dbo].[City] ([GUIDReference])
GO

ALTER TABLE [dbo].[CityGeographics] CHECK CONSTRAINT [FK_dbo.CityGeographics_dbo.City_City_Id]
GO

ALTER TABLE [dbo].[CityGeographics]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CityGeographics_dbo.Translation_Description_ID] FOREIGN KEY([Description_Id])
REFERENCES [dbo].[Translation] ([TranslationId])
GO

ALTER TABLE [dbo].[CityGeographics] CHECK CONSTRAINT [FK_dbo.CityGeographics_dbo.Translation_Description_ID]
GO


