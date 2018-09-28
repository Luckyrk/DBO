
CREATE VIEW [dbo].[DeliveryAddress]
	WITH SCHEMABINDING
AS
SELECT DISTINCT a.GUIDReference AS DeliveryAddressID
	,AddressLine1
	,AddressLine2
	,AddressLine3
	,AddressLine4
	,PostCode
--, Type_Id AS AddressTypeID
--, AddressType
--, t.KeyName
--, c.GUIDReference AS CandidateID
FROM [dbo].[Address] a
INNER JOIN dbo.OrderedContactMechanism ocm ON ocm.Address_Id = a.GUIDReference
INNER JOIN dbo.Candidate c ON ocm.Candidate_Id = c.GUIDReference
INNER JOIN dbo.Country cty ON cty.CountryID = c.Country_ID
INNER JOIN dbo.CountryViewAccess cva ON cva.Country = cty.CountryISO2A
INNER JOIN dbo.AddressType at ON a.Type_Id = at.Id
INNER JOIN dbo.Translation t ON at.Description_Id = t.TranslationId
WHERE cva.UserId = SUSER_SNAME()
	AND t.KeyName IN (
		'DeliveryAddressType'
		,'PostalAddressType'
		,'HomeAddressType'
		)