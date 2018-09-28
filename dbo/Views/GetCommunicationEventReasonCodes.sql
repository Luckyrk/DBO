
CREATE VIEW [dbo].[GetCommunicationEventReasonCodes]
AS
SELECT C.[CountryISO2A]
	,CommEventReasonCode Code
	,TT.Value Value
FROM CommunicationEventReasonType CMT
INNER JOIN Country C ON C.CountryId = CMT.Country_Id
LEFT JOIN [dbo].[TranslationTerm] AS TT ON (CMT.DescriptionTranslation_Id = TT.[Translation_Id])
	AND (TT.[CultureCode] = 2057)
LEFT JOIN [dbo].[Translation] AS T ON (T.[Discriminator] = 'BusinessTranslation')
	AND (CMT.DescriptionTranslation_Id = T.TranslationId)