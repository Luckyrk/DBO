-- This has to execute Only in GB Database
create view IndividualAlisasStatusGB
as
  SELECT Country.CountryISO2A
	,Individual.IndividualID
	,Panel.PanelCode
	,NA.[Key] AS Alias
	,NA.[Type] AS AliasType
	,NAC.NAME AS Context
	,Address.Addressline1 as Email
	,PersonalIdentification.FirstOrderedName
	,PersonalIdentification.MiddleOrderedName
	,PersonalIdentification.LastOrderedName
	,StateDefinition.Code as StateCode	
FROM dbo.Individual
INNER JOIN dbo.Candidate ON dbo.Individual.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.NamedAlias AS NA ON NA.Candidate_Id = dbo.Candidate.GUIDReference
INNER JOIN dbo.NamedAliasContext AS NAC ON NA.AliasContext_Id = NAC.NamedAliasContextId
INNER JOIN dbo.PersonalIdentification ON dbo.Individual.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId
LEFT JOIN dbo.Address ON dbo.Individual.MainEmailAddress_Id = dbo.Address.GUIDReference
INNER JOIN dbo.Panelist ON dbo.Panelist.PanelMember_Id = Candidate.GUIDReference
INNER JOIN dbo.Panel ON dbo.Panel.GUIDReference = dbo.Panelist.Panel_Id
INNER JOIN dbo.StateDefinition ON dbo.Panelist.State_Id = dbo.StateDefinition.Id
GO