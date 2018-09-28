
CREATE VIEW [dbo].[FullIndividualAddressEmailPhone]
	WITH SCHEMABINDING
AS
SELECT dbo.Country.CountryISO2A
	,dbo.AddressType.DiscriminatorType
	,CAST(b.KeyName AS NVARCHAR(255)) AS AddressType
	,dbo.Individual.IndividualId
	,dbo.OrderedContactMechanism.[Order]
	,dbo.Address.AddressLine1
	,dbo.Address.AddressLine2
	,dbo.Address.AddressLine3
	,dbo.Address.AddressLine4
	,dbo.Address.PostCode
	,dbo.Address.GPSUser
	,dbo.Address.GPSUpdateTimestamp
	,dbo.Address.CreationTimeStamp
FROM dbo.Address
INNER JOIN dbo.AddressType ON dbo.AddressType.Id = dbo.Address.Type_Id
INNER JOIN dbo.OrderedContactMechanism ON dbo.OrderedContactMechanism.Address_Id = dbo.Address.GUIDReference
INNER JOIN dbo.Candidate ON dbo.Candidate.GUIDReference = dbo.OrderedContactMechanism.Candidate_Id
INNER JOIN dbo.Individual ON dbo.Individual.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.Translation AS b ON b.TranslationId = dbo.AddressType.Description_Id