CREATE VIEW [dbo].[FullDeviceAttributes]
AS
SELECT b.CountryISO2A
,a.[SerialNumber]
,f.[Key]
,e.Value
FROM [StockItem] a
Join Country b
on b.CountryId = a.Country_Id
Join Respondent c
on c.GUIDReference = a.GUIDReference
and c.CountryID = a.Country_Id
Join AttributeValue e
on e.RespondentId = c.GUIDReference
Join Attribute f
on f.GUIDReference = e.DemographicId
