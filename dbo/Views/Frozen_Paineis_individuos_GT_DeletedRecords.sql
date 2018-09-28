CREATE VIEW [dbo].[Frozen_Paineis_individuos_GT_DeletedRecords]  
AS  
select DISTINCT  
p.PanelCode as idpainel,  
cl.Sequence as iddomicilio,  
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
--,CM.AuditDate AS CMGPSUpdateTimestamp  
,PL.AuditDate AS PLGPSUpdateTimestamp  
from   
(  
 SELECT * FROM  GPS_PM_Latam_Audit.audit.panelist WHERE  __$operation=1 AND AuditOperation='D'  
) pl  
inner join country c on c.CountryId=pl.Country_Id AND pl.__$operation=1 AND pl.AuditOperation='D'  
inner join panel p on p.GUIDReference=pl.Panel_Id AND pl.__$operation=1 AND pl.AuditOperation='D'  
inner join collective cl on cl.GUIDReference=pl.PanelMember_Id-- cl.GUIDReference=pl.PanelMember_Id  
inner join CollectiveMembership cm on  cm.Group_Id=cl.GUIDReference  
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
       ) AS STATUSGroupMembershipDATES ON STATUSGroupMembershipDATES.GroupMembership_Id =   
       cm.CollectiveMembershipId  AND cm.State_Id=STATUSGroupMembershipDATES.DropStateId  
inner join Individual i on i.GUIDReference=cm.Individual_Id  
left outer join (SELECT ROW_NUMBER() OVER(PArtition BY PanelMemberId,PanelCode ORDER BY [Date] DESC) AS RNO,*   
FROM  [FullPanellistStateChanges] WHERE CountryISO2A='GT' AND ToState='PanelistDroppedOffState'  AND [ReasonCode] IS NOT NULL   
) fpl on fpl.CountryISO2A='GT' and fpl.PanelCode=p.PanelCode and   
fpl.PanelMemberID=cast(cl.Sequence as nvarchar(10)) and  fpl.ToState='PanelistDroppedOffState' AND [ReasonCode] IS NOT NULL   
AND RNO=1  
--left outer join  
--(  
--select av.CandidateId,av.Value  
--from AttributeValue av   
--inner join Country ac on ac.CountryId=av.Country_Id  
--left outer join Attribute a on a.GUIDReference=av.DemographicId   
--where ac.CountryISO2A='GT' and a.[Key]='Dateofresidency'  
--)t on t.CandidateId=cm.Individual_Id  
left outer join  
(  
select av.CandidateId,av.Value  
from GPS_PM_Latam_Audit.audit.AttributeValue av   
inner join Country ac on ac.CountryId=av.Country_Id AND av.__$operation=1 AND av.AuditOperation='D'  
left outer join Attribute a on a.GUIDReference=av.DemographicId   
where ac.CountryISO2A='GT' and a.[Key]='CensoYear' AND av.__$operation=1 AND av.AuditOperation='D'  
) gt on gt.CandidateId=cm.Group_Id  
where c.CountryISO2A='GT'  
AND ((PL.__$operation=1 AND PL.AuditOperation='D'))  
  
  
union  
select DISTINCT  
p.PanelCode as idpainel,  
cl.Sequence as iddomicilio,  
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
--,CM.GP AS CMGPSUpdateTimestamp  
,PL.AuditDate AS PLGPSUpdateTimestamp  
from   
(SELECT * FROM  GPS_PM_Latam_Audit.audit.panelist WHERE  __$operation=1 AND AuditOperation='D') pl  
inner join country c on c.CountryId=pl.Country_Id AND pl.__$operation=1 AND pl.AuditOperation='D'  
inner join panel p on p.GUIDReference=pl.Panel_Id AND pl.__$operation=1 AND pl.AuditOperation='D'  
inner join CollectiveMembership cm  on cm.Individual_Id=pl.PanelMember_Id-- cl.GUIDReference=pl.PanelMember_Id  
inner join collective cl on  cm.Group_Id=cl.GUIDReference  
inner join dbo.StateDefinition ON pl.State_Id = dbo.StateDefinition.Id  
LEFT JOIN (SELECT hist.Country_Id  
              ,Panelist_Id  
              ,max(CreationDate) AS DroppedOffDate  
     ,LIVESTATE.id AS DropStateId  
       FROM dbo.StateDefinitionHistory HIST  WITH (NOLOCK)
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
       FROM dbo.StateDefinitionHistory HIST  WITH (NOLOCK)
       INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id AND HIST.Country_Id = Livestate.Country_Id  
    WHERE LIVESTATE.Code IN ('GroupMembershipNonResident','GroupMembershipDeceased')  
       GROUP BY hist.Country_Id  
              ,GroupMembership_Id  
     ,LIVESTATE.id  
       ) AS STATUSGroupMembershipDATES ON STATUSGroupMembershipDATES.GroupMembership_Id = cm.CollectiveMembershipId  
     AND STATUSGroupMembershipDATES.DropStateId=cm.State_Id  
inner join Individual i on i.GUIDReference=cm.Individual_Id  
left outer join (SELECT ROW_NUMBER() OVER(PArtition BY PanelMemberId,PanelCode ORDER BY [Date] DESC) AS RNO,*   
FROM  [FullPanellistStateChanges] WHERE CountryISO2A='GT' AND ToState='PanelistDroppedOffState'  AND [ReasonCode] IS NOT NULL   
) fpl on fpl.CountryISO2A='GT' and fpl.PanelCode=p.PanelCode and   
fpl.PanelMemberID=cast(cl.Sequence as nvarchar(10)) and  fpl.ToState='PanelistDroppedOffState' AND [ReasonCode] IS NOT NULL  
AND RNO=1  
--left outer join  
--(  
--select av.CandidateId,av.Value  
--from AttributeValue av   
--inner join Country ac on ac.CountryId=av.Country_Id  
--left outer join Attribute a on a.GUIDReference=av.DemographicId   
--where ac.CountryISO2A='GT' and a.[Key]='Dateofresidency'  
--)t on t.CandidateId=cm.Individual_Id  
left outer join  
(  
select av.CandidateId,av.Value  
from GPS_PM_Latam_Audit.audit.AttributeValue av  
inner join Country ac on ac.CountryId=av.Country_Id AND av.__$operation=1 AND av.AuditOperation='D'  
left outer join Attribute a on a.GUIDReference=av.DemographicId   
where ac.CountryISO2A='GT' and a.[Key]='CensoYear'   
AND av.__$operation=1 AND av.AuditOperation='D'  
)gt on gt.CandidateId=cm.Group_Id  
where c.CountryISO2A='GT'  
AND ((PL.__$operation=1 AND PL.AuditOperation='D'))  

GO
