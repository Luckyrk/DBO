CREATE VIEW FullPanellistIncentives
AS
SELECT 
      c.CountryISO2A
      ,d.PanelCode
         ,d.Name
         ,d.Type
         ,e.Sequence as GroupId
         ,f.IndividualId
      ,b.Code
         ,b.Description
  FROM [Panelist] a
  Join IncentiveLevel b
  on b.GUIDReference = a.IncentiveLevel_Id
  Join Country c
  on c.CountryId = a.Country_Id
  Join Panel d
  on d.GUIDReference = a.Panel_Id
  Left Join Collective e
  on e.GUIDReference = a.PanelMember_Id
  Left Join Individual f
  on f.GUIDReference = a.PanelMember_Id

