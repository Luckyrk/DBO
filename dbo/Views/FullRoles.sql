CREATE VIEW [dbo].[FullRoles]
AS
SELECT b.CountryISO2A
      ,[Code]
    ,c.Value as Role
       ,d.[Type] as ConfigSet_Type
       ,e.Name as PanelName
       ,e.PanelCode
      ,[ActiveFrom]
      ,[ActiveTo]
      ,[Order]
  FROM [DynamicRoleConfiguration] x
  Join [DynamicRole] a
  on a.DynamicRoleId = x.DynamicRoleId
  Join Country b
  on b.CountryId = a.Country_Id
  Join TranslationTerm c
  on c.CultureCode = 2057
  and c.Translation_Id = a.Translation_Id
  Join ConfigurationSet d
  on d.ConfigurationSetId = x.ConfigurationSetId
  left join Panel e
  on e.GUIDReference = d.PanelId

