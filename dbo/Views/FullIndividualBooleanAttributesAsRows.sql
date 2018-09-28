
CREATE VIEW [dbo].[FullIndividualBooleanAttributesAsRows]
AS
SELECT IRA.CountryISO2A
	,IRA.IndividualId
	,IRA.[Key]
	,CAST(TYPETERM.Value AS VARCHAR(255)) AS Attribute
	,IRA.Value
	,IRA.GPSUser
	,IRA.CreationTimeStamp
	,IRA.GPSUpdateTimestamp
FROM
	--dbo.Individual
	--INNER JOIN dbo.Candidate ON dbo.Individual.GUIDReference = dbo.Candidate.GUIDReference
	--INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
	--INNER JOIN dbo.AttributeValue ON dbo.Candidate.GUIDReference = dbo.AttributeValue.CandidateId
	--INNER JOIN dbo.Attribute ON dbo.AttributeValue.DemographicId = dbo.Attribute.GUIDReference
	[IXV_Individual_ATTRIBUTE_AsRows](NOEXPAND) IRA
INNER JOIN dbo.Translation AS TYPETRANS ON TYPETRANS.TranslationId = IRA.Translation_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS TYPETERM ON TYPETRANS.TranslationId = TYPETERM.Translation_Id
WHERE IRA.[Type] = 'Boolean'


GO