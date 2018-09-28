CREATE VIEW QuestionnaireTransactions
AS
SELECT 
dbo.[FullQuestionnaireTransactions].CountryISO2A
      ,[QuestionnaireTransactionID]
	  , PanelMemberId
      ,[QuestionnaireID]
      ,[InvitationDate]
      ,StateCode
      ,[GPSUser]
      ,[GPSUPdateTimestamp]
      ,[CompletionDate]
      ,[NumberofDays]
	  ,GroupId
      --,GroupContact
      ,[UID]
      ,[panelist_code]
      ,[QuestionnaireDate] 
FROM 
dbo.[FullQuestionnaireTransactions]
 INNER JOIN dbo.CountryViewAccess ON dbo.FullQuestionnaireTransactions.CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME())  AND dbo.FullQuestionnaireTransactions.CountryISO2A = dbo.CountryViewAccess.Country
GO

--EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific and includes all country data. Shows QuestionnaireTransaction data which consists of surveys and questionnaires.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QuestionnaireTransactions'
--GO

--GRANT SELECT ON QuestionnaireTransactions TO GPSBusiness
--GRANT SELECT ON QuestionnaireTransactions TO GPSBusiness_Full