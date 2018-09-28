﻿CREATE TABLE [dbo].[SurveyParticipationTask] (
    [SurveyParticipationTaskId] UNIQUEIDENTIFIER NOT NULL,
    [Name]                      NVARCHAR (50)    NOT NULL,
	[Code]						BIGINT IDENTITY(1,1) NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
	[PanelTaskType_Id] uniqueidentifier NULL,
    CONSTRAINT [PK_dbo.SurveyParticipationTask] PRIMARY KEY CLUSTERED ([SurveyParticipationTaskId] ASC),
    CONSTRAINT [FK_dbo.SurveyParticipationTask_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]));




GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[SurveyParticipationTask]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgSurveyParticipationTask_U 
ON dbo.[SurveyParticipationTask] FOR update 
AS 
insert into audit.[SurveyParticipationTask](
insert into audit.[SurveyParticipationTask](
GO
CREATE TRIGGER dbo.trgSurveyParticipationTask_I
ON dbo.[SurveyParticipationTask] FOR insert 
AS 
insert into audit.[SurveyParticipationTask](
GO
CREATE TRIGGER dbo.trgSurveyParticipationTask_D
ON dbo.[SurveyParticipationTask] FOR delete 
AS 
insert into audit.[SurveyParticipationTask](