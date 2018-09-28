
CREATE VIEW [dbo].[GetIncentiveTypeList]
AS
SELECT C.[CountryISO2A]
	,IncentiveType.[Type]
	,Code
	,TT.Value
FROM IncentivePointAccountEntryType AS IncentiveType
INNER JOIN [dbo].[Country] AS C ON IncentiveType.[Country_Id] = C.[CountryId]
LEFT JOIN [dbo].[TranslationTerm] AS TT ON (IncentiveType.[TypeName_Id] = TT.[Translation_Id])
	AND (TT.[CultureCode] = 2057)
LEFT JOIN [dbo].[Translation] AS T ON (T.[Discriminator] = 'BusinessTranslation')
	AND (IncentiveType.[TypeName_Id] = T.[TranslationId])