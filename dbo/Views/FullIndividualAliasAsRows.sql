
CREATE VIEW [dbo].[FullIndividualAliasAsRows]
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Individual.IndividualID
	,NA.[Key] AS Alias
	,NA.[Type] AS AliasType
	,NAC.NAME AS Context
	,NA.GPSUser
	,NA.CreationTimeStamp
	,NA.GPSUpdateTimestamp
FROM dbo.Individual
INNER JOIN dbo.Candidate ON dbo.Individual.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.NamedAlias AS NA ON NA.Candidate_Id = dbo.Candidate.GUIDReference
INNER JOIN dbo.NamedAliasContext AS NAC ON NA.AliasContext_Id = NAC.NamedAliasContextId