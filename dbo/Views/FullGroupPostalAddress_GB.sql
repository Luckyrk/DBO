CREATE VIEW [dbo].[FullGroupPostalAddress_GB]
	AS 
	SELECT e.CountryISO2A
    ,d.Sequence as HouseholdNumber
       ,a.AddressLine1
       ,a.AddressLine2
       ,a.AddressLine3
       ,a.AddressLine4
       ,a.PostCode
       ,k.Value as Region
       ,f.Value as CouncilTaxBand
FROM dbo.Address a
JOIN AddressType b ON b.Id = a.Type_Id
and b.DiscriminatorType ='PostalAddressType'
INNER JOIN OrderedContactMechanism c ON c.Address_Id = a.GUIDReference
and c.[Order] = 1
JOIN Collective d on d.GUIDReference = c.Candidate_Id
JOIN dbo.Country e ON a.Country_Id = e.CountryId
and e.CountryISO2A = 'GB'
LEFT JOIN AttributeValue f
on f.Address_Id = c.Address_Id
Left Join Attribute g
on g.GUIDReference = f.DemographicId
and g.[Key] = 'Counciltaxband'
Left Join
(Select h.CandidateId, h.Value, h.GPSUser
From
 AttributeValue h
Join Attribute j
on j.GUIDReference = h.DemographicId
and j.[Key] = 'H502' ) k
on k.CandidateId = d.GUIDReference
GO
