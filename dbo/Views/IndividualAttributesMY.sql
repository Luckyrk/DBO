
CREATE VIEW [dbo].[IndividualAttributesMY]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesMY]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesMY].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesMY].CountryISO2A = dbo.CountryViewAccess.Country