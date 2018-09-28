
CREATE VIEW [dbo].[GetStateReasons]
AS
SELECT C.[CountryISO2A]
	,SM.[Type]
	,RFS.Code Code
	,TT.Value Value
FROM ReasonForChangeState RFS
INNER JOIN [dbo].[Country] AS C ON RFS.[Country_Id] = C.[CountryId]
INNER JOIN [dbo].StateModel AS SM ON RFS.StateModel_Id = SM.GUIDReference
	AND RFS.Country_Id = SM.Country_Id
INNER JOIN [dbo].[TranslationTerm] AS TT ON (RFS.Description_Id = TT.[Translation_Id])
	AND (TT.[CultureCode] = 2057)
INNER JOIN [dbo].[Translation] AS T ON (T.[Discriminator] = 'BusinessTranslation')
	AND (RFS.Description_Id = T.TranslationId)
	AND TT.CultureCode = 2057