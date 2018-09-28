CREATE TABLE [dbo].[Questionnaire] (
 	[Questionnaire_ID] [int] IDENTITY(1,1) NOT NULL,
	[SurveyName] [nvarchar](200) NULL,
	[ClientName] [nvarchar](200) NULL,
	[ClientTeamPerson] [nvarchar](200) NULL,
	[QuestionnaireType] [nvarchar](200) NULL,
	[Department] [varchar](25) NULL,
	[Comment] [nvarchar](400) NULL,
	[CreationTimestamp] [datetime] NULL,
	[GPSUPdateTimestamp] [datetime] NULL,
	[GPSUser] [nvarchar](50) NULL,
	[CollaborationType] [varchar](50) NULL,
	[Points] int NULL,
    [QuestionnaireLink] NVARCHAR(4000) NULL, 
    CONSTRAINT [PK_FRS.Questionnaire] PRIMARY KEY CLUSTERED ([Questionnaire_ID] ASC)
);