
CREATE VIEW [dbo].[IndividualAttributesTW]
AS
 SELECT *
FROM [dbo].[FullIndividualAttributesTW]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesTW].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesTW].CountryISO2A = dbo.CountryViewAccess.Country