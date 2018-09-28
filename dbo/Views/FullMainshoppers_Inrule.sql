CREATE VIEW FullMainshoppers_Inrule
AS
SELECT distinct ct.CountryISO2A
       ,ind.IndividualId AS MainShopperId 
       ,c.Sequence as GroupId     
       ,pan.PanelCode
       ,pan.NAME PanelName
       ,stat.Code PanellistState
       ,pst.CreationDate AS SignupDate   
FROM dbo.Individual ind
INNER JOIN dbo.CollectiveMembership cm on CM.Individual_Id = ind.GUIDReference
INNER JOIN dbo.Collective c on c.GUIDReference = cm.Group_Id
INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = cm.Individual_Id
INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = ind.GUIDReference
INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id and drMs.code = 2
WHERE stat.Code IN (
              'PanelistLiveState'
              ,'PanelistInterestedState'
              ,'PanelistPreLiveState'
			  ,'PanelistDroppedOffState'
              ) 

UNION ALL

SELECT distinct ct.CountryISO2A
       ,ind.IndividualId AS MainShopperId 
       ,c.Sequence as GroupId     
       ,pan.PanelCode
       ,pan.NAME PanelName
       ,stat.Code PanellistState
       ,pst.CreationDate AS SignupDate   
FROM dbo.Individual ind
INNER JOIN dbo.CollectiveMembership cm on CM.Individual_Id = ind.GUIDReference
INNER JOIN dbo.Collective c on c.GUIDReference = cm.Group_Id
INNER JOIN dbo.Panelist pst ON pst.PanelMember_Id = cm.Group_Id
INNER JOIN dbo.Country ct ON ct.CountryId = pst.Country_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
INNER JOIN dbo.StateDefinition stat ON stat.Id = pst.State_Id
INNER JOIN dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = ind.GUIDReference
INNER JOIN dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id and drMs.code = 2
WHERE stat.Code IN (
              'PanelistLiveState'
              ,'PanelistInterestedState'
              ,'PanelistPreLiveState'
			  ,'PanelistDroppedOffState'
              ) 
       --AND Ct.CountryISO2A = 'TW'
GO
