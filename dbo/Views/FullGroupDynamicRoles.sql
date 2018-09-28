CREATE VIEW [dbo].[ FullGroupDynamicRoles] as   
SELECT cnt.CountryISO2A
  , dr.Code
  , tra.KeyName RoleName
  , col.Sequence GroupId
  , ind.IndividualId
  FROM [dbo].[DynamicRoleAssignment]  dra
  inner join dbo.DynamicRole dr on dr.DynamicRoleId = dra.DynamicRole_Id
  inner join dbo.Translation tra on tra.TranslationId = dr.Translation_Id
  inner join dbo.Collective col on col.GUIDReference = dra.Group_Id
  inner join dbo.Country cnt on cnt.CountryId = dr.Country_Id
  inner join dbo.Individual ind on ind.GUIDReference = dra.Candidate_Id
  where dra.Group_id is not null 
