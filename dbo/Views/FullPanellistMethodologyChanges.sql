CREATE VIEW [dbo].[FullPanellistMethodologyChanges]
	AS 
	select

[dbo].Country.CountryISO2A, PAN.PanelMemberID, Panel.PanelCode, Panel.Name PanelName, Panel.Type,

sdh.Date [Date], FromState.Code FromMethodology, ToState.Code ToMethodology,

Reason.Code ReasonCode,tt.Value as ReasonCodeDescription,sdh.Comments, sdh.GPSUser

 

from [dbo].CollaborationMethodologyHistory sdh

 left join [dbo].CollaborationMethodology as FromState on sdh.OldCollaborationMethodology_Id = FromState.GUIDReference
 
 join [dbo].CollaborationMethodology as ToState on sdh.NewCollaborationMethodology_Id = ToState.GUIDReference

 left join [dbo].CollaborationMethodologyChangeReason as Reason on Reason.ChangeReasonId = sdh.CollaborationMethodologyChangeReason_Id

 left join TranslationTerm tt on tt.Translation_Id=Reason.Description_Id and tt.CultureCode=2057

inner join [dbo].Panelist on Panelist.GUIDReference = sdh.Panelist_Id
inner join [dbo].Country on Country.CountryId = Panelist.Country_Id
inner join [dbo].Panel on Panel.GUIDReference = Panelist.Panel_Id



INNER JOIN (

      SELECT GUIDReference

            ,Individual.IndividualId PanelMemberID, dbo.IndividualIdSplitter.GroupID

      FROM [dbo].Individual inner join dbo.IndividualIdSplitter on dbo.IndividualIdSplitter.IndividualId = Individual.IndividualId

     

      UNION ALL

     

      SELECT GUIDReference

            ,CONVERT(VARCHAR, Sequence) PanelMemberID, CONVERT(VARCHAR, Sequence) GroupID

      FROM Collective

      ) AS PAN ON PAN.GUIDReference = dbo.Panelist.PanelMember_Id

where Panelist_Id is not null