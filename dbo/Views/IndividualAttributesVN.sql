
CREATE VIEW [dbo].[IndividualAttributesVN]
AS
SELECT    *
FROM         [dbo].[FullIndividualAttributesVN] INNER JOIN
                      dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesVN].CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1)
		 AND [dbo].[FullIndividualAttributesVN].CountryISO2A = dbo.CountryViewAccess.Country



