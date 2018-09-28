CREATE VIEW [dbo].[FullQuestionnaireTransactions]
AS
SELECT  e.CountryISO2A
      ,[QuestionnaireTransactionID]
	  ,case when c.[Type] = 'HouseHold' then cast(d.Sequence as nvarchar(30))
            when c.[Type] = 'Individual' then  g.IndividualId
			else null
		End as PanelMemberId
      ,[QuestionnaireID]
      ,[InvitationDate]
      ,f.Code as StateCode
      ,a.[GPSUser]
      ,a.[GPSUPdateTimestamp]
      ,[CompletionDate]
      ,[NumberofDays]
	  ,j.Sequence as GroupId
      --,g.IndividualId as GroupContact
      ,[UID]
      ,[panelist_code]
      ,[QuestionnaireDate]
  FROM [QuestionnaireTransaction] a
  Left Join Panelist b on b.GUIDReference = a.PanelistID
  Left Join Panel c on c.GUIDReference = b.Panel_Id
  Left Join Collective d on d.GUIDReference = b.PanelMember_Id
  Join Country e on e.CountryId = a.CountryID
  Join StateDefinition f on f.Id = a.StateID
  Join Individual g on g.GUIDReference = a.IndividualId
  Join CollectiveMembership h on h.Individual_Id = a.IndividualId
  Join Collective j on j.GUIDReference = h.Group_Id

  GO

--EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Includes all country data. Shows QuestionnaireTransaction data which consists of surveys and questionnaires.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullQuestionnaireTransactions'
--GO

--GRANT SELECT ON FullQuestionnaireTransactions TO GPSBusiness
--GRANT SELECT ON FullQuestionnaireTransactions TO GPSBusiness_Full
--GO