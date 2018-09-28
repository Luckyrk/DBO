CREATE VIEW [dbo].[FullAttributesSummary_GB]
AS
SELECT b.CountryISO2A
		,a.[Key] as Attribute_Key
		,g.KeyName as KeyName
		,c.Value as Attribute_Desc
		,d.[Type] as ScopeType
		,f.Value as Category
		,a.[Type] as AttributeType
  FROM [Attribute] a
  Join Country b  on b.CountryId = a.Country_Id
  Join TranslationTerm c  on c.Translation_Id = a.Translation_Id
	and c.CultureCode = 2057
  Join AttributeScope d  on d.GUIDReference = a.Scope_Id
  Join AttributeCategory e  on e.GUIDReference = a.Category_Id
	and e.Country_Id = b.CountryId
  Join TranslationTerm f  on f.Translation_Id = e.Translation_Id
	and f.CultureCode = 2057
  Join Translation g  on g.TranslationId = a.Translation_Id
  where CountryISO2A = 'GB'