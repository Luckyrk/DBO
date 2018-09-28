CREATE VIEW [dbo].[IndividualAliasPH]
AS
SELECT *
FROM [dbo].[FullIndividualAliasPH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAliasPH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAliasPH].CountryISO2A = dbo.CountryViewAccess.Country
