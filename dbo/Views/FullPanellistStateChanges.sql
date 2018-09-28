GO
CREATE VIEW [dbo].[FullPanellistStateChanges]  
AS   
select  
[dbo].Country.CountryISO2A, PAN.PanelMemberID, Panel.PanelCode, Panel.Name PanelName, Panel.Type,  
sdh.CreationDate [Date], FromState.Code FromState, ToState.Code ToState,sdh.CollaborateInFuture as FutureCollaboration,  
Reason.Code ReasonCode, sdh.GPSUser,sdh.Comments 
   
from [dbo].StateDefinitionHistory sdh  
inner join [dbo].StateDefinition as FromState on sdh.From_Id = FromState.Id  
 inner join [dbo].StateDefinition as ToState on sdh.To_Id = ToState.Id  
 left join [dbo].ReasonForChangeState as Reason on Reason.Id = sdh.ReasonForchangeState_Id  
inner join [dbo].Country on Country.CountryId = FromState.Country_Id  
inner join [dbo].Panelist on Panelist.GUIDReference = sdh.Panelist_Id  
inner join [dbo].Panel on Panel.GUIDReference = Panelist.Panel_Id  
Inner Join StateModel on StateModel.GUIDReference = ToState.StateModel_Id  
and StateModel.[Type] = 'Domain.PanelManagement.Candidates.Panelist'  
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

GO