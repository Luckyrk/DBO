
CREATE VIEW [dbo].[IndividualAttributesPH]
AS
SELECT *
FROM [dbo].[FullIndividualAttributesPH]
INNER JOIN dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesPH].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND [dbo].[FullIndividualAttributesPH].CountryISO2A = dbo.CountryViewAccess.Country