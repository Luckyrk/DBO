CREATE VIEW [dbo].[IncentiveAccounts]
AS
SELECT [CountryISO2A]
	,[AccountType]
	,[GroupId]
	,[IndividualId]
	,[Beneficiary]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,CurrentBalance
FROM [dbo].[FullIncentiveAccounts]
INNER JOIN dbo.CountryViewAccess ON dbo.FullIncentiveAccounts.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullIncentiveAccounts.CountryISO2A = dbo.CountryViewAccess.Country