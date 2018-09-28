
CREATE VIEW [dbo].[addresses]
AS
SELECT ord.Candidate_Id
	,aty.DiscriminatorType
	,tr1.KeyName
	,adr.addressline1
	,adr.addressline2
	,adr.addressline3
	,adr.addressline4
	,adr.postcode
FROM dbo.OrderedContactMechanism ord
INNER JOIN dbo.Address adr ON adr.GUIDReference = ord.Address_Id
INNER JOIN dbo.AddressType aty ON aty.Id = adr.Type_Id
INNER JOIN dbo.Translation tr1 ON tr1.TranslationId = aty.Description_Id