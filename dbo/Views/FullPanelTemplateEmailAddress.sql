CREATE VIEW [dbo].[FullPanelTemplateEmailAddress]
AS
SELECT e.CountryISO2A
      ,d.AddressType
         ,d.AddressLine1
      ,c.TemplateMessageSchemeId
         , c.Description as TemplateSchemeDesc
         ,b.PanelCode
      ,b.Name as Panelname
  FROM [AddressDomain] a
  Join Panel b
  on b.GUIDReference = a.Panel_Id
  Join TemplateMessageScheme c
  on c.TemplateMessageSchemeId = a.Scheme_Id
  Join [Address] d
  on d.GUIDReference = a.AddressId
  Join Country e
  on e.CountryId = a.CountryId