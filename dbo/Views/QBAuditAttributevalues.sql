

CREATE VIEW [dbo].[QBAuditAttributeValues]
AS

SELECT c.CountryISO2A
       ,b.[Key] as AttributeKey
	   ,b.ShortCode
       ,d.Value as Attribute_Desc
	   ,e.IndividualId
	   ,g.Sequence as GroupId
	   ,b.Type as AttributeType
	   ,a.Value as AttributeValue
	   ,f.Value as EnumValue
	   ,a.[GPSUser]
       ,a.[GPSUpdateTimestamp]
       ,a.[CreationTimeStamp]
	   ,a.AuditOperation
  FROM [GPS_PM_FRA_Audit].audit.[AttributeValue] a
  Join Attribute b
  on b.GUIDReference = a.DemographicId
  Join Country c
  on c.CountryId = b.Country_Id
  Join Translationterm d
  on d.Translation_Id = b.Translation_Id
  and d.CultureCode = 2057
  Left join Individual e
  on e.GUIDReference = a.CandidateId
  Left join Collective g
  on g.GUIDReference = a.CandidateId
 Left Join EnumDefinition f
 on f.Id = a.EnumDefinition_Id
 where a.GPSUser in ('QBImport','QBFRImport')
 and a.AuditOperation in ('I', 'N')
 Order by a.AuditDate

 GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'countryiso2a  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'countryiso2a'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AttributeKey  - The atrribute key name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'Attributekey'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'ShortCode - The atrribute key name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'ShortCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AttributeDesc  - The atrribute description.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'AttributeDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Individuald  - Holds the Individual ID for the Group eg: 123456-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'IndividualId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AttributeType - Type as in Enum, Date, Int, String etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'AttributeType'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AttributeValue  - The value of the attribute.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'AttributeValue'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'EnumValue  - The Enum value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'AttributeValue'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUser  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'GPSUser'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUpdateTimestamp  - update timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'GPSUpdateTimestamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CreationTimeStamp  - creation timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'CreationTimeStamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AuditOperation  - audit operation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues', @level2type=N'COLUMN',@level2name=N'AuditOperation'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'QBAuditAttributeValues - shows attribute values fom the Questback import' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Demographics' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Provides one row per GroupID or IndividualId per Attribute. Shows data for all Countries.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditAttributeValues'
GO
