Create VIEW [dbo].[Frozen_HouseHold_BR]      
AS
SELECT 
	cl.Sequence AS GroupBusinessID
	--, Code
	--, LEN(Code) AS GACodeLength
	,LEFT(Code, 2) AS [RegionGroup]
	, SUBSTRING(Code, 3, 3) AS [City code]
	, SUBSTRING(Code, 6, 4) AS [Zone Code]
	, SUBSTRING(Code, 10, 2) AS UF
	, SUBSTRING(Code, 12, 5) AS [County code]
	, SUBSTRING(Code, 17, 2) AS [District code]
	, SUBSTRING(Code, 19, 2) AS [Sub district code]
	, SUBSTRING(Code, 21, 4) AS [Sector code]
	, av.Value AS [Interviewer code]
	, a.Postcode AS HomePostCode 
FROM GeographicArea ga
	INNER JOIN Respondent r ON ga.GUIDReference = r.GUIDReference
	INNER JOIN Candidate c ON ga.GUIDReference = c.GeographicArea_Id
	INNER JOIN Collective cl on cl.GUIDReference = c.GUIDReference
	INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id = c.GUIDReference
	INNER JOIN Address a ON ocm.Address_Id = a.GUIDReference
	INNER JOIN AddressType at ON a.Type_Id = at.ID
	INNER JOIN Translation t ON at.Description_Id = t.TranslationId
	LEFT JOIN 
(
			SELECT av.CandidateID, av.Value FROM Attribute a
				INNER JOIN AttributeValue av ON a.GUIDReference = av.DemographicId
			WHERE a.[Key] = 'H450'
		) av ON av.CandidateId = c.GUIDReference
WHERE r.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'BR')
AND t.KeyName = 'HomeAddressType'

GO

--GRANT SELECT ON [Frozen_HouseHold_BR] TO GPSBusiness

--GO