CREATE VIEW [dbo].[ FullPanellistDynamicRoles] as 
SELECT cnt.CountryISO2A
  , dr.Code
  , tra.KeyName RoleName
  , col.Sequence GroupId
  , ind.IndividualId
  , pan.PanelCode
  , pan.Name PanelName
  , case when pan.Type = 'Individual'
       then ind.IndividualId
       else
          cast(col.Sequence as nvarchar)
       end as PanelMemberId
  FROM [dbo].[DynamicRoleAssignment]  dra
  inner join dbo.DynamicRole dr on dr.DynamicRoleId = dra.DynamicRole_Id
  inner join dbo.Translation tra on tra.TranslationId = dr.Translation_Id
  inner join dbo.Individual ind on ind.GUIDReference = dra.Candidate_Id
  left join dbo.CollectiveMembership cmem on cmem.Individual_Id = ind.GUIDReference
  left join dbo.Collective col on col.GUIDReference = cmem.Group_Id
  inner join dbo.Country cnt on cnt.CountryId = dr.Country_Id
  inner join dbo.Panelist pst on pst.GUIDReference = dra.Panelist_Id
  inner join dbo.Panel pan on pan.GUIDReference = pst.Panel_Id
  where dra.Panelist_Id is not null 
