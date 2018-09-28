
CREATE VIEW [dbo].[IndividualAttributesGB]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesGB]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesGB].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesGB].CountryISO2A = dbo.CountryViewAccess.Country