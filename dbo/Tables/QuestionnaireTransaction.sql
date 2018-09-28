CREATE TABLE [dbo].[QuestionnaireTransaction] (
    [QuestionnaireTransactionID] BIGINT IDENTITY(1,1) NOT NULL,
    [PanelistID]                 UNIQUEIDENTIFIER NULL,
    [CountryID]                  UNIQUEIDENTIFIER NOT NULL,
    [QuestionnaireID]            INT              NOT NULL,
    [InvitationDate]             DATETIME         NULL,
    [StateID]                    UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUPdateTimestamp]         DATETIME         NULL,
	[CompletionDate]			 DATETIME		  NULL,
	[NumberofDays]				 INT		      NULL,
	[GroupContactId]			 UNIQUEIDENTIFIER NULL,
	[UID]						 NVARCHAR(100)     NULL,
	[InterviewerId]				 BIGINT   NULL,
	[PanelistName]				 NVARCHAR(300)    NULL,
	panelist_code				 Varchar(200)	  NULL,
	QuestionnaireDate			 DATETIME		  NULL,
	IndividualId				 UNIQUEIDENTIFIER NULL,
    FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Country] ([CountryId]),
    FOREIGN KEY ([PanelistID]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    FOREIGN KEY ([QuestionnaireID]) REFERENCES [dbo].[Questionnaire] ([Questionnaire_ID]),
    FOREIGN KEY ([StateID]) REFERENCES [dbo].[StateDefinition] ([Id]),
	PRIMARY KEY CLUSTERED 
	(
		[QuestionnaireTransactionID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)ON [PRIMARY];