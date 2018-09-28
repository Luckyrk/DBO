CREATE VIEW [dbo].[Frozen_Paineis_Domicilios_GT]  
AS   
select DISTINCT  
p.PanelCode as idpainel,  
GT.Sequence as iddomicilio,  
pl.CreationDate as [Data_Entrada],  
CASE 
WHEN  sd.Code='PanelistDroppedOffState' THEN  STATUSDATES.DroppedOffDate
ELSE NULL 
END AS  [Data_Saida], 
CASE 
WHEN  sd.Code='PanelistDroppedOffState' THEN 
IIF( fpl.[ReasonCode] IS NOT NULL AND LEN(fpl.[ReasonCode]) < 2, RIGHT(CONCAT('00000',fpl.[ReasonCode]), 2), CONCAT(fpl.[ReasonCode], ''))
ELSE NULL END as Cause_Saida,  
'E' as Tipo_Envio,pl.GPSUpdateTimestamp   
from   
panelist pl  
inner join country c on c.CountryId=pl.Country_Id  
inner join panel p on p.GUIDReference=pl.Panel_Id  
inner join collective GT on GT.GUIDReference=pl.PanelMember_Id  
inner join dbo.StateDefinition sd ON pl.State_Id = sd.Id  
LEFT JOIN (SELECT hist.Country_Id  
              ,Panelist_Id  
              ,max(iif(LIVESTATE.Code = 'PanelistInterestedState', CreationDate, NULL)) AS InterestedDate  
              ,max(iif(LIVESTATE.Code = 'PanelistPreLiveState', CreationDate, NULL)) AS PreLiveDate  
              ,max(iif(LIVESTATE.Code = 'PanelistLiveState', CreationDate, NULL)) AS LiveDate  
              ,max(iif(LIVESTATE.Code = 'PanelistDroppedOffState', CreationDate, NULL)) AS DroppedOffDate  
              ,max(iif(LIVESTATE.Code = 'PanelistRefusalState', CreationDate, NULL)) AS RefusalDate  
              ,max(iif(LiveState.code='PanelistSelectedState',CreationDate,Null)) as SelectedDate  
       FROM dbo.StateDefinitionHistory HIST  WITH (NOLOCK)
       INNER JOIN dbo.StateDefinition LIVESTATE ON HIST.To_Id = LIVESTATE.id AND HIST.Country_Id = Livestate.Country_Id  
       GROUP BY hist.Country_Id  
              ,Panelist_Id  
       ) AS STATUSDATES ON STATUSDATES.Panelist_Id = pl.GUIDReference  
left outer join (SELECT ROW_NUMBER() OVER(PArtition BY PanelMemberId,PanelCode ORDER BY [Date] DESC) AS RNO,* FROM [FullPanellistStateChanges] WHERE CountryISO2A='GT' AND ToState='PanelistDroppedOffState' ) fpl   
on fpl.CountryISO2A='GT' and fpl.PanelCode=p.PanelCode and fpl.PanelMemberID=cast(GT.Sequence as nvarchar(10)) and  fpl.ToState='PanelistDroppedOffState'   
AND RNO=1  
where c.CountryISO2A='GT'  

GO

--EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Gives Panellist details like panel code , drop out date , reason along with these columns date of residency of the members of that group ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Frozen_Paineis_Domicilios_GT'
--GO

--GRANT SELECT ON [Frozen_Paineis_Domicilios_GT] TO GPSBusiness

--GO