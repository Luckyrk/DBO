CREATE VIEW [dbo].[IndividualIncentives]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[GroupId]
	,[PanelCode]
	,[PanelName]
	,[CreationDate]
	,[TransactionDate]
	,[DepositorId]
	,[Amount]
	,[Code]
	,[Description]
	,[Balance]
	,[Comments]
	,[TransactionSource]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
FROM dbo.FullIndividualIncentives
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualIncentives.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualIncentives.CountryISO2A = dbo.CountryViewAccess.Country