CREATE VIEW [dbo].[FullQuestionnaires]
AS
SELECT [Questionnaire_ID]
      ,[SurveyName]
      ,[ClientName]
      ,[ClientTeamPerson]
      ,[QuestionnaireType]
      ,[Department]
      ,[Comment]
      ,[CreationTimestamp]
      ,[GPSUPdateTimestamp]
      ,[GPSUser]
      ,[CollaborationType]
      ,[Points]
  FROM [Questionnaire]

GO

--EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Contains all country data for Questionnaire definitions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullQuestionnaires'
--GO
--GRANT SELECT ON FullQuestionnaires TO GPSBusiness
--GRANT SELECT ON FullQuestionnaires TO GPSBusiness_Full
--GO