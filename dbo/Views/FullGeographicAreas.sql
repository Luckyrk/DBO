
CREATE VIEW [dbo].[FullGeographicAreas]
AS
SELECT [dbo].Country.CountryISO2A
	,[dbo].GeographicArea.Code
	,CAST(TRANSTERM.Value AS NVARCHAR(255)) AS KeyName
	,[dbo].GeographicArea.CreationTimeStamp
	,[dbo].GeographicArea.GPSUpdateTimestamp
	,[dbo].GeographicArea.GPSUser
FROM [dbo].GeographicArea
INNER JOIN [dbo].Respondent ON [dbo].GeographicArea.GUIDReference = [dbo].Respondent.GUIDReference
INNER JOIN [dbo].Country ON [dbo].Respondent.CountryID = [dbo].Country.CountryId
INNER JOIN [dbo].Translation ON [dbo].Translation.TranslationId = [dbo].GeographicArea.Translation_Id
LEFT JOIN (
	SELECT *
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS TRANSTERM ON [dbo].Translation.TranslationId = TRANSTERM.Translation_Id