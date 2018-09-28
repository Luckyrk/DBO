CREATE VIEW [dbo].[Questionnaires]
AS
SELECT DISTINCT [Questionnaire_ID]
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
  FROM [FullQuestionnaires]
  CROSS JOIN CountryViewAccess
  WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME())
GO

--EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific and includes all country data for Questionnaire definitions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Questionnaires'
--GO
--GRANT SELECT ON Questionnaires TO GPSBusiness
--GRANT SELECT ON Questionnaires TO GPSBusiness_Full
--GO