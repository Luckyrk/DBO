
CREATE VIEW [dbo].[FullEventReasons]
AS
SELECT ct.CountryISO2A
	,er.CommEventReasonCode
	,tt.Value AS CommEventReasonDescription
FROM dbo.[CommunicationEventReasonType] er
INNER JOIN country ct ON ct.CountryId = er.Country_Id
INNER JOIN Translation tr ON tr.TranslationId = er.TagTranslation_Id
INNER JOIN TranslationTerm tt ON tr.TranslationId = tt.Translation_Id AND tt.CultureCode = 2057