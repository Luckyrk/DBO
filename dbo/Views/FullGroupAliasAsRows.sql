
CREATE VIEW [dbo].[FullGroupAliasAsRows]
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Collective.Sequence GroupId
	,NA.[Key] AS Alias
	,NA.[Type] AS AliasType
	,NAC.NAME AS Context
FROM dbo.Collective
INNER JOIN dbo.Candidate ON dbo.Collective.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.NamedAlias AS NA ON NA.Candidate_Id = dbo.Candidate.GUIDReference
INNER JOIN dbo.NamedAliasContext AS NAC ON NA.AliasContext_Id = NAC.NamedAliasContextId