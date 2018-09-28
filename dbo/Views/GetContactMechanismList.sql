
CREATE VIEW [dbo].[GetContactMechanismList]
AS
SELECT C.[CountryISO2A]
	,ContactMechanismCode Code
	,TT.Value Value
FROM ContactMechanismType CMT
INNER JOIN Country C ON C.CountryId = CMT.Country_Id
LEFT JOIN [dbo].[TranslationTerm] AS TT ON (CMT.TypeTranslation_Id = TT.[Translation_Id])
	AND (TT.[CultureCode] = 2057)
LEFT JOIN [dbo].[Translation] AS T ON (T.[Discriminator] = 'BusinessTranslation')
	AND (CMT.TypeTranslation_Id = T.TranslationId)