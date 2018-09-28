CREATE TABLE [dbo].[InterviewerGeographicArea](
	[ID] [uniqueidentifier] NOT NULL,
	[Interviewer_Id] [uniqueidentifier] NULL,
	[GeographicArea_Id] [uniqueidentifier] NULL,
	[GPSUser] [nvarchar](100) NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
	[CreationTimeStamp] [datetime] NULL,
	[Country_Id] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_InterviewerGeographicArea] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[InterviewerGeographicArea]  WITH CHECK ADD  CONSTRAINT [FK_dbo.interviewerGeographicArea_dbo.GeographicArea_GeographicArea_Id] FOREIGN KEY([GeographicArea_Id])
REFERENCES [dbo].[GeographicArea] ([GUIDReference])
GO

ALTER TABLE [dbo].[InterviewerGeographicArea] CHECK CONSTRAINT [FK_dbo.interviewerGeographicArea_dbo.GeographicArea_GeographicArea_Id]
GO

ALTER TABLE [dbo].[InterviewerGeographicArea]  WITH CHECK ADD  CONSTRAINT [FK_dbo.InterviewerGeographicArea_dbo.Interviewer_Interviewer_Id] FOREIGN KEY([Interviewer_Id])
REFERENCES [dbo].[Interviewer] ([ID])
GO

ALTER TABLE [dbo].[InterviewerGeographicArea] CHECK CONSTRAINT [FK_dbo.InterviewerGeographicArea_dbo.Interviewer_Interviewer_Id]
GO


