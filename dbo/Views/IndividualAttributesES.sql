
CREATE VIEW [dbo].[IndividualAttributesES]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesES]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesES].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesES].CountryISO2A = dbo.CountryViewAccess.Country