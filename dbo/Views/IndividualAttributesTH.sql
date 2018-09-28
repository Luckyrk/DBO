
CREATE VIEW [dbo].[IndividualAttributesTH]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesTH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesTH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesTH].CountryISO2A = dbo.CountryViewAccess.Country