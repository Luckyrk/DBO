CREATE VIEW [dbo].[IndividualReferers]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[RefererId]	
FROM dbo.[FullIndividualReferers]
INNER JOIN dbo.CountryViewAccess ON dbo.[FullIndividualReferers].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.[FullIndividualReferers].CountryISO2A = dbo.CountryViewAccess.Country