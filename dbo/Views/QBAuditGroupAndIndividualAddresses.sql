
CREATE VIEW [dbo].[QBAuditGroupAndIndividualAddresses]
AS

SELECT d.CountryISO2A
     ,case when b.sequence is not null then 'Group' else 'Individual' End as CandidateType
     ,b.Sequence as GroupId
    ,c.IndividualId 
    ,a.HomePhone
	,a.WorkPhone
	,a.MobilePhone
	,a.PersonalEmailAddress AS EmailAddress
	,a.HomeAddress
	,a.PostalAddress
	,a.GPSUser
	,a.GPSUpdateTimestamp
	,a.AuditOperation
  FROM 
 (
	SELECT max(iif(tr1.KeyName = 'HomePhoneType', adr.addressline1, NULL)) AS HomePhone
		,max(iif(tr1.KeyName = 'WorkPhoneType', adr.addressline1, NULL)) AS WorkPhone
		,max(iif(tr1.KeyName = 'MobilePhoneType', adr.addressline1, NULL)) AS MobilePhone
		,max(iif(tr1.KeyName = 'PersonalEmailAddressType', adr.addressline1, NULL)) AS PersonalEmailAddress
		,max(iif(tr1.KeyName = 'HomeAddressType', adr.addressline1 + ', ' + ISNULL(adr.addressline2, '') + ', ' + ISNULL(adr.addressline3, '') + ', ' + ISNULL(adr.addressline4, '') + ', ' + ISNULL(adr.postcode, ''), NULL)) AS HomeAddress
		,max(iif(tr1.KeyName = 'PostalAddressType', adr.addressline1 + ', ' + ISNULL(adr.addressline2, '') + ', ' + ISNULL(adr.addressline3, '') + ', ' + ISNULL(adr.addressline4, '') + ', ' + ISNULL(adr.postcode, ''), NULL)) AS PostalAddress
		,ord.Candidate_Id
		,adr.GPSUser
		,adr.GPSUpdateTimestamp
		,adr.AuditOperation
		,adr.Country_Id
	FROM dbo.OrderedContactMechanism ord
	INNER JOIN [GPS_PM_FRA_Audit].[audit].[Address] adr ON adr.GUIDReference = ord.Address_Id
	INNER JOIN dbo.AddressType aty ON aty.Id = adr.Type_Id
	INNER JOIN dbo.Translation tr1 ON tr1.TranslationId = aty.Description_Id
	WHERE tr1.KeyName IN (
			'HomePhoneType'
			,'WorkPhoneType'
			,'MobilePhoneType'
			,'PersonalEmailAddressType'
			,'HomeAddressType'
			,'PostalAddressType'
			)
	GROUP BY Candidate_Id
			,adr.GPSUser
		    ,adr.GPSUpdateTimestamp
		    ,adr.AuditOperation
			,adr.Country_Id
	) a
  Left Join Collective b
  on b.GUIDReference = a.Candidate_Id
  Left Join Individual c
  on c.GUIDReference = a.Candidate_Id
  Join Country d
  on d.CountryId = a.Country_Id
  where a.GPSUser in ('QBImport','QBFRImport')
  and a.AuditOperation in ('I', 'N')

 GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CandidateType  - Indicates Group or Individual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'CandidateType'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'HomePhone  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'HomePhone'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'WorkPhone  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'WorkPhone'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MobilePhone  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'MobilePhone'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'EmailAddress  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'EmailAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'HomeAddress  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'HomeAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PostalAddress  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'PostalAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUser  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'GPSUser'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUpdateTimestamp  - update timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'GPSUpdateTimestamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CreationTimeStamp  - creation timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'CreationTimeStamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AuditOperation  - audit operation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses', @level2type=N'COLUMN',@level2name=N'AuditOperation'
GO
EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'ContactInfo, QBAuditGroupAndIndividualAddresses' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Contact Information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'All Country data. Shows all the contact information for the Main contact including the main shopper individualID, name Panel, collaboration method, phone numbers, address information and comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditGroupAndIndividualAddresses'
GO


