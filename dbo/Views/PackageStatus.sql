
CREATE VIEW [dbo].[PackageStatus]
	WITH SCHEMABINDING
AS
SELECT p.GUIDReference AS PackageID
	,State_Id
	--, Reward_Id
	--, Debit_Id
	,c.CountryISO2A
	,DateSent
	,sd.Label_ID
	,t.KeyName
	,tt.Value
FROM [dbo].[Package] p
INNER JOIN dbo.StateDefinition sd ON p.State_ID = sd.ID
INNER JOIN dbo.Translation t ON sd.Label_ID = t.TranslationId
INNER JOIN dbo.TranslationTerm tt ON t.TranslationID = tt.Translation_ID
LEFT JOIN dbo.Country c ON c.CountryID = p.Country_ID
	AND tt.CultureCode IN (
		CASE c.CountryISO2A
			WHEN 'TW'
				THEN 1028
			WHEN 'FR'
				THEN 1036
			WHEN 'ES'
				THEN 3082
			WHEN 'GB'
				THEN 2057
			WHEN 'PH'
				THEN 1124
			WHEN 'MY'
				THEN 1086
			END
		)