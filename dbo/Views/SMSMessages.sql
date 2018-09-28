
CREATE VIEW [dbo].[SMSMessages]
AS
SELECT [CountryISO2A]
	,[CommsMessageTemplateComponentId]
	,[Description]
	,[Subject]
	,[TextContent]
	,[ActiveFrom]
	,[ActiveTo]
FROM [dbo].[FullSMSMessages]
INNER JOIN dbo.CountryViewAccess ON dbo.FullSMSMessages.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullSMSMessages.CountryISO2A = dbo.CountryViewAccess.Country