
CREATE VIEW [dbo].[FullIndividualSearch]
AS
SELECT dbo.Individual.GUIDReference
	,dbo.Country.CountryISO2A
	,dbo.Individual.IndividualId
	,dbo.PersonalIdentification.FirstOrderedName
	,dbo.PersonalIdentification.LastOrderedName
	,dbo.GeographicArea.Code GeographicAreaCode
	,CASE 
		WHEN dbo.Individual.MainPhoneAddress_Id IS NOT NULL
			THEN (
					SELECT Addressline1
					FROM dbo.[Address]
					WHERE GUIDReference = dbo.Individual.MainPhoneAddress_Id
					)
		ELSE (
				SELECT ''
				)
		END AS Phone
	,CASE 
		WHEN dbo.Individual.MainEmailAddress_Id IS NOT NULL
			THEN (
					SELECT Addressline1
					FROM dbo.[Address]
					WHERE GUIDReference = dbo.Individual.MainEmailAddress_Id
					)
		ELSE (
				SELECT ''
				)
		END AS Email
	,CASE 
		WHEN dbo.Individual.MainPostalAddress_Id IS NOT NULL
			THEN (
					SELECT Addressline1
					FROM dbo.[Address]
					WHERE GUIDReference = dbo.Individual.MainPostalAddress_Id
					)
		ELSE (
				SELECT ''
				)
		END AS PostalAddress
FROM dbo.Country
INNER JOIN dbo.Candidate ON dbo.Country.CountryId = dbo.Candidate.Country_Id
INNER JOIN dbo.Individual ON dbo.Candidate.GUIDReference = dbo.Individual.GUIDReference
INNER JOIN dbo.PersonalIdentification ON dbo.Individual.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId
LEFT JOIN dbo.GeographicArea ON dbo.GeographicArea.GUIDReference = dbo.Candidate.GeographicArea_Id