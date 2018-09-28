
CREATE VIEW [dbo].[GetEventFrequency]
AS
SELECT c.CountryISO2A
	,t.KeyName AS Frequency
FROM EventFrequency ef
INNER JOIN Translation t ON ef.Translation_Id = t.TranslationId
INNER JOIN Country c ON ef.Country_Id = c.CountryId