
CREATE VIEW [dbo].[IndividualAttributesIE]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesIE]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesIE].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesIE].CountryISO2A = dbo.CountryViewAccess.Country