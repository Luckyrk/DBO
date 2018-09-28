CREATE VIEW [dbo].[IndividualRedemptionsStatusChanges]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[GroupId]
	,[PanelCode]
	,[PanelName]
	,[CreationDate]
	,[TransactionDate]
	,[Amount]
	,[Code]
	,[Description]
	,[FromCode]
	,[ToCode]
	,[ChangedDate]
	,[GPSUser]
FROM dbo.[FullIndividualRedemptionsStatusChanges]
INNER JOIN dbo.CountryViewAccess ON dbo.[FullIndividualRedemptionsStatusChanges].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.[FullIndividualRedemptionsStatusChanges].CountryISO2A = dbo.CountryViewAccess.Country
