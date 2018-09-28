
CREATE VIEW [dbo].[ExclusionTypes]
AS
SELECT et.GUIDReference
	,t.KeyName AS ExclusionReasonType
	,c.CountryISO2A
FROM ExclusionType et
INNER JOIN Translation t ON t.TranslationId = et.Translation_Id
INNER JOIN Country c ON c.CountryId = et.Country_Id