CREATE VIEW FullSMSMessages
AS
SELECT b.[CountryISO2A]
	,a.[CommsMessageTemplateComponentId]
	,a.[Description]
	,a.[Subject]
	,a.[TextContent]
	,a.[ActiveFrom]
	,a.[ActiveTo]
	,a.GPSUser
	,a.CreationTimeStamp
	,a.GPSUpdateTimestamp
FROM [dbo].[CommsMessageTemplateComponent] a
INNER JOIN dbo.Country b ON a.CountryID = b.CountryId
WHERE a.commsmessagetemplatesubtypeid = 1
	AND a.CommsMessageTemplateTypeId = 2