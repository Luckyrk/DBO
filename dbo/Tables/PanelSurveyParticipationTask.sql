﻿CREATE TABLE [dbo].[PanelSurveyParticipationTask] (
    [PanelSurveyParticipationTaskId] UNIQUEIDENTIFIER NOT NULL,
    [ActiveFrom]                     DATETIME         NOT NULL,
    [ActiveTo]                       DATETIME         NULL,
    [Mandatory]                      BIT              NOT NULL,
    [GPSUser]                        NVARCHAR (MAX)   NULL,
    [GPSUpdateTimestamp]             DATETIME         NULL,
    [CreationTimeStamp]              DATETIME         NULL,
    [Task_Id]                        UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]                     UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id]                       UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PanelSurveyParticipationTask] PRIMARY KEY CLUSTERED ([PanelSurveyParticipationTaskId] ASC),
    CONSTRAINT [FK_dbo.PanelSurveyParticipationTask_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PanelSurveyParticipationTask_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelSurveyParticipationTask_dbo.SurveyParticipationTask_Task_Id] FOREIGN KEY ([Task_Id]) REFERENCES [dbo].[SurveyParticipationTask] ([SurveyParticipationTaskId])
);




GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[PanelSurveyParticipationTask]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PanelSurveyParticipationTask]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Task_Id]
    ON [dbo].[PanelSurveyParticipationTask]([Task_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelSurveyParticipationTask_U 
ON dbo.[PanelSurveyParticipationTask] FOR update 
AS 
insert into audit.[PanelSurveyParticipationTask](
insert into audit.[PanelSurveyParticipationTask](
GO
CREATE TRIGGER dbo.trgPanelSurveyParticipationTask_I
ON dbo.[PanelSurveyParticipationTask] FOR insert 
AS 
insert into audit.[PanelSurveyParticipationTask](
GO
CREATE TRIGGER dbo.trgPanelSurveyParticipationTask_D
ON dbo.[PanelSurveyParticipationTask] FOR delete 
AS 
insert into audit.[PanelSurveyParticipationTask](