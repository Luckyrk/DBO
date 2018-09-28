
CREATE VIEW [dbo].[Emails]
AS
SELECT [CountryISO2A]
	,[DocumentId]
	,[PanelMemberId]
	,[EmailDate]
	,[Subject]
	,[From]
	,[To]
	,[EmailContent]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,[Unusable]
	,[ActionTaskId]
	,[CommunicationEventId]
FROM [dbo].[FullEmails]
INNER JOIN dbo.CountryViewAccess ON dbo.FullEmails.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullEmails.CountryISO2A = dbo.CountryViewAccess.Country