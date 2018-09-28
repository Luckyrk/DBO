GO

CREATE VIEW [dbo].[Frozen_Paineis_individuos_MX]  
AS  
select DISTINCT  
p.PanelCode as idpainel,  
MX.Sequence as iddomicilio,  
cast(substring(i.IndividualId,(charindex('-',i.IndividualId,0)+1),2) as bigint) as idindividuo,  
--t.Value as [Data_Entrada],  
pl.CreationDate AS [Data_Entrada],  
 CASE  
 WHEN STATUSDATES.DroppedOffDate IS NOT NULL AND STATUSGroupMembershipDATES.GroupDroppedOffDate IS NOT NULL  
 THEN iif(CAST(STATUSDATES.DroppedOffDate AS DATETIME)>CASt(STATUSGroupMembershipDATES.GroupDroppedOffDate AS DATETIME) ,STATUSDATES.DroppedOffDate,STATUSGroupMembershipDATES.GroupDroppedOffDate)    
 WHEN  STATUSDATES.DroppedOffDate IS NULL THEN STATUSGroupMembershipDATES.GroupDroppedOffDate  
 ELSE  STATUSDATES.DroppedOffDate END as [Data_Saida]  
,  
CASE  
WHEN DroppedOffDate IS NOT NULL THEN fpl.[ReasonCode]   
ELSE NULL END as Cause_Saida,  
'E' as Tipo_Envio,  
gt.Value as [Censo_Year]  
,CM.GPSUpdateTimestamp AS CMGPSUpdateTimestamp  
,PL.GPSUpdateTimestamp AS PLGPSUpdateTimestamp  
from   
panelist pl  
inner join country c on c.CountryId=pl.Country_Id  
inner join panel p on p.GUIDReference=pl.Panel_Id  
inner join collective MX on MX.GUIDReference=pl.PanelMember_Id-- MX.GUIDReference=pl.PanelMember_Id  
inner join CollectiveMembership cm on  cm.Group_Id=MX.GUIDReference  
inner join dbo.StateDefinition ON pl.State_Id = dbo.StateDefinition.Id  
LEFT JOIN (SELECT hist.Country_Id  
              ,Panelist_Id  
              ,max(CreationDate) AS DroppedOffDate  
     ,LIVESTATE.id AS DropStateId  
       FROM dbo.StateDefinitionHistory HIST WITH (NOLOCK) 
       INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id AND HIST.Country_Id = Livestate.Country_Id  
    WHERE LIVESTATE.Code='PanelistDroppedOffState'  
       GROUP BY hist.Country_Id  
              ,Panelist_Id  
     ,LIVESTATE.id  
       ) AS STATUSDATES ON STATUSDATES.Panelist_Id = pl.GUIDReference AND pl.State_Id=STATUSDATES.DropStateId  
LEFT JOIN (SELECT hist.Country_Id  
              ,GroupMembership_Id  
              ,max(CreationDate) AS GroupDroppedOffDate  
     ,LIVESTATE.id AS DropStateId  
       FROM dbo.StateDefinitionHistory HIST WITH (NOLOCK) 
       INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id AND HIST.Country_Id = Livestate.Country_Id  
    WHERE LIVESTATE.Code IN ('GroupMembershipNonResident','GroupMembershipDeceased')  
       GROUP BY hist.Country_Id  
              ,GroupMembership_Id  
      ,LIVESTATE.id  
       ) AS STATUSGroupMembershipDATES ON STATUSGroupMembershipDATES.GroupMembership_Id = cm.CollectiveMembershipId  AND cm.State_Id=STATUSGroupMembershipDATES.DropStateId  
inner join Individual i on i.GUIDReference=cm.Individual_Id  
left outer join (SELECT ROW_NUMBER() OVER(PArtition BY PanelMemberId,PanelCode ORDER BY [Date] DESC) AS RNO,*   
FROM  [FullPanellistStateChanges] WHERE CountryISO2A='MX' AND ToState='PanelistDroppedOffState'  AND [ReasonCode] IS NOT NULL   
) fpl on fpl.CountryISO2A='MX' and fpl.PanelCode=p.PanelCode and   
fpl.PanelMemberID=cast(MX.Sequence as nvarchar(10)) and  fpl.ToState='PanelistDroppedOffState' AND [ReasonCode] IS NOT NULL   
AND RNO=1  
--left outer join  
--(  
--select av.CandidateId,av.Value  
--from AttributeValue av   
--inner join Country ac on ac.CountryId=av.Country_Id  
--left outer join Attribute a on a.GUIDReference=av.DemographicId   
--where ac.CountryISO2A='MX' and a.[Key]='Dateofresidency'  
--)t on t.CandidateId=cm.Individual_Id  
left outer join  
(  
select av.CandidateId,av.Value  
from AttributeValue av   
inner join Country ac on ac.CountryId=av.Country_Id  
left outer join Attribute a on a.GUIDReference=av.DemographicId   
where ac.CountryISO2A='MX' and a.[Key]='CensoYear'  
)gt on gt.CandidateId=cm.Group_Id  
where c.CountryISO2A='MX'  
union  
select DISTINCT  
p.PanelCode as idpainel,  
MX.Sequence as iddomicilio,  
cast(substring(i.IndividualId,(charindex('-',i.IndividualId,0)+1),2) as bigint) as idindividuo,  
--t.Value as [Data_Entrada],  
pl.CreationDate AS [Data_Entrada],  
 CASE  
 WHEN STATUSDATES.DroppedOffDate IS NOT NULL AND STATUSGroupMembershipDATES.GroupDroppedOffDate IS NOT NULL  
 THEN iif(CAST(STATUSDATES.DroppedOffDate AS DATETIME)>CASt(STATUSGroupMembershipDATES.GroupDroppedOffDate AS DATETIME) ,STATUSDATES.DroppedOffDate,STATUSGroupMembershipDATES.GroupDroppedOffDate)    
 WHEN  STATUSDATES.DroppedOffDate IS NULL THEN STATUSGroupMembershipDATES.GroupDroppedOffDate  
 ELSE  STATUSDATES.DroppedOffDate END as [Data_Saida]  
,  
CASE  
WHEN DroppedOffDate IS NOT NULL THEN fpl.[ReasonCode]   
ELSE NULL END as Cause_Saida,  
'E' as Tipo_Envio,  
gt.Value as [Censo_Year]  
,CM.GPSUpdateTimestamp AS CMGPSUpdateTimestamp  
,PL.GPSUpdateTimestamp AS PLGPSUpdateTimestamp  
from   
panelist pl  
inner join country c on c.CountryId=pl.Country_Id  
inner join panel p on p.GUIDReference=pl.Panel_Id  
inner join CollectiveMembership cm  on cm.Individual_Id=pl.PanelMember_Id-- MX.GUIDReference=pl.PanelMember_Id  
inner join collective MX on  cm.Group_Id=MX.GUIDReference  
inner join dbo.StateDefinition ON pl.State_Id = dbo.StateDefinition.Id  
LEFT JOIN (SELECT hist.Country_Id  
              ,Panelist_Id  
              ,max(CreationDate) AS DroppedOffDate  
     ,LIVESTATE.id AS DropStateId  
       FROM dbo.StateDefinitionHistory HIST WITH (NOLOCK) 
       INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id AND HIST.Country_Id = Livestate.Country_Id  
    WHERE LIVESTATE.Code='PanelistDroppedOffState'  
       GROUP BY hist.Country_Id  
              ,Panelist_Id  
     ,LIVESTATE.id  
       ) AS STATUSDATES ON STATUSDATES.Panelist_Id = pl.GUIDReference AND pl.State_Id=STATUSDATES.DropStateId  
LEFT JOIN (SELECT hist.Country_Id  
              ,GroupMembership_Id  
              ,max(CreationDate) AS GroupDroppedOffDate  
     ,LIVESTATE.id AS DropStateId  
       FROM dbo.StateDefinitionHistory HIST WITH (NOLOCK) 
       INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id AND HIST.Country_Id = Livestate.Country_Id  
    WHERE LIVESTATE.Code IN ('GroupMembershipNonResident','GroupMembershipDeceased')  
       GROUP BY hist.Country_Id  
              ,GroupMembership_Id  
     ,LIVESTATE.id  
       ) AS STATUSGroupMembershipDATES ON STATUSGroupMembershipDATES.GroupMembership_Id = cm.CollectiveMembershipId  
     AND STATUSGroupMembershipDATES.DropStateId=cm.State_Id  
inner join Individual i on i.GUIDReference=cm.Individual_Id  
left outer join (SELECT ROW_NUMBER() OVER(PArtition BY PanelMemberId,PanelCode ORDER BY [Date] DESC) AS RNO,*   
FROM  [FullPanellistStateChanges] WHERE CountryISO2A='MX' AND ToState='PanelistDroppedOffState'  AND [ReasonCode] IS NOT NULL   
) fpl on fpl.CountryISO2A='MX' and fpl.PanelCode=p.PanelCode and   
fpl.PanelMemberID=cast(MX.Sequence as nvarchar(10)) and  fpl.ToState='PanelistDroppedOffState' AND [ReasonCode] IS NOT NULL  
AND RNO=1  
--left outer join  
--(  
--select av.CandidateId,av.Value  
--from AttributeValue av   
--inner join Country ac on ac.CountryId=av.Country_Id  
--left outer join Attribute a on a.GUIDReference=av.DemographicId   
--where ac.CountryISO2A='MX' and a.[Key]='Dateofresidency'  
--)t on t.CandidateId=cm.Individual_Id  
left outer join  
(  
select av.CandidateId,av.Value  
from AttributeValue av   
inner join Country ac on ac.CountryId=av.Country_Id  
left outer join Attribute a on a.GUIDReference=av.DemographicId   
where ac.CountryISO2A='MX' and a.[Key]='CensoYear'  
)gt on gt.CandidateId=cm.Group_Id  
where c.CountryISO2A='MX'  

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Gives Panellist details like panel code ,signup date, drop out date , reason ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Frozen_Paineis_individuos_MX'
GO

--GRANT SELECT ON [Frozen_Paineis_individuos_MX] TO GPSBusiness

--GO