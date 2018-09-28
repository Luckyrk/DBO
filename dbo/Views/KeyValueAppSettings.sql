
CREATE VIEW [dbo].[KeyValueAppSettings]
AS
SELECT cnt.CountryISO2A
	,kas.[KeyName]
	,kas.[Comment]
	,kas.[DefaultValue]
	,kvas.Value
FROM [dbo].[KeyValueAppSetting] kvas
LEFT JOIN [dbo].[KeyAppSetting] kas ON Kvas.KeyAppSetting_Id = kas.GUIDReference
LEFT JOIN dbo.Country cnt ON cnt.CountryId = kvas.Country_Id